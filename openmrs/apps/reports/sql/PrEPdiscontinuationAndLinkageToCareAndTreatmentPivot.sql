
-- Add more filters to the reports. on all report groups

SELECT PREP_TOTALS_COLS_ROWS.AgeGroup
        , PREP_TOTALS_COLS_ROWS.Gender
        , PREP_TOTALS_COLS_ROWS.Stopped
		, PREP_TOTALS_COLS_ROWS.MissedWith28Days
		, PREP_TOTALS_COLS_ROWS.Defaulted
		, PREP_TOTALS_COLS_ROWS.LTFU 
        , PREP_TOTALS_COLS_ROWS.Initiated

FROM (

			(SELECT PREP_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					, PREP_STATUS_DRVD_ROWS.Gender
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'Stopped',1 , 0))) AS Stopped 
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'MissedWithin28Days' ,1 ,0))) AS MissedWith28Days
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'Defaulted',1 , 0))) AS Defaulted
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'LTFU',1 , 0))) AS LTFU		
                        , IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'Initiated',1 , 0))) AS Initiated		 
						, PREP_STATUS_DRVD_ROWS.sort_order
			FROM (

			SELECT Id, patientIdentifier , patientName , age_group, Age, Gender,Program_Status,cast(Date_Missed as DATE) as 'Date Missed' ,Contacts, Village,sort_order

        FROM 
        (
            -- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
        (SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, Date_Missed, 'MissedWithin28Days' AS 'Program_Status',Contacts,Village,sort_order
          FROM
                        (select distinct patient.patient_id AS Id,
          			                      patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Date_Missed,
                                pa.value as Contacts,
                                person_address.city_village AS Village,
                                observed_age_group.sort_order AS sort_order				

                        from obs o
                                -- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
                                INNER JOIN patient ON o.person_id = patient.patient_id
                                AND o.person_id in (

                                -- Latest followup date from the lastest prep followup form, exclude voided followup date
                                select active_clients.person_id
                                        from
                                        (  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
                                            from obs B
                                            inner join 
                                            (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                            from obs where concept_id = 5029
                                            and obs_datetime <= cast('#endDate#' as date)
                                            group by person_id) as A
                                            on A.observation_id = B.obs_group_id
                                            where B.concept_id = 3752
                                            and A.observation_id = B.obs_group_id
                                            and voided = 0	
                                            group by B.person_id
                                        ) as active_clients

                                        where active_clients.latest_follow_up < cast('#endDate#' as date)
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) > 0
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) <= 28
                        
                                        and active_clients.person_id not in (
                                            -- Exclude clients who stopped in the reporting period
                                            select distinct os.person_id
                                            from obs os
                                            where os.concept_id = 5005 and value_coded = 1
                                            AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                            )

                                        and active_clients.person_id not in (
                                
                                                select Stopped_clients.person_id
                                                from
                                                (select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
                                                    from obs B
                                                    inner join
                                                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                    from obs where concept_id = 5029
                                                    and obs_datetime <= cast('#endDate#' as date)
                                                    and voided = 0
                                                    group by person_id) as A
                                                    on A.observation_id = B.obs_group_id
                                                    where concept_id = 5068 and value_coded = 1
                                                    and A.observation_id = B.obs_group_id
                                                    and voided = 0
                                                    group by B.person_id
                                                ) as Stopped_clients
                                                
                                                where Stopped_clients.latest_consultation < cast('#endDate#' as date)
                                                and Stopped_clients.person_id NOT IN (
                                                            select person_id from obs -- stopped PrEP
                                                                where   
                                                                    MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                                    AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                                    and concept_id = 5005			
                                                        )
                                            )
                
                                            -- DEAD 
                                            and active_clients.person_id not in (
                                            select person_id 
                                            from person 
                                            where death_date <= cast('#endDate#' as date)
                                            and dead = 1
                                        )
                                )
                                
                                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                                LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters

        order by TwentyEightDayDefaulters.patientName)

        UNION 

        -- INCLUDE MISSED APPOINTMENTS WITH MORE THAN 28 AND LESS THAN 89 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
        (SELECT   distinct Id,patientIdentifier, patientName, Age, Gender, age_group, DOB, Date_Missed, 'Defaulted' AS 'Program_Status',Contacts,Village,sort_order
        FROM
                        (select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Date_Missed,
                                pa.value as Contacts,
                                person_address.city_village AS Village,		
                                observed_age_group.sort_order AS sort_order					

                        from obs o
                                -- CLIENTS WHO MISSED APPOINTMENTS 28 - 89 DAYS
                                INNER JOIN patient ON o.person_id = patient.patient_id
                                AND o.person_id in (

                                -- Latest followup date from the lastest prep followup form, exclude voided followup date
                                select active_clients.person_id
                                        from
                                        (  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
                                            from obs B
                                            inner join 
                                            (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                            from obs where concept_id = 5029
                                            and obs_datetime <= cast('#endDate#' as date)
                                            group by person_id) as A
                                            on A.observation_id = B.obs_group_id
                                            where B.concept_id = 3752
                                            and A.observation_id = B.obs_group_id
                                            and voided = 0	
                                            group by B.person_id
                                        ) as active_clients

                                        where active_clients.latest_follow_up < cast('#endDate#' as date)
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) > 28
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) <= 89
                        
                                        and active_clients.person_id not in (
                                            -- Exclude clients who stopped in the reporting period
                                            select distinct os.person_id
                                            from obs os
                                            where os.concept_id = 5005 and value_coded = 1
                                            AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                            )

                                        and active_clients.person_id not in (
                                
                                                select Stopped_clients.person_id
                                                from
                                                (select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
                                                    from obs B
                                                    inner join
                                                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                    from obs where concept_id = 5029
                                                    and obs_datetime <= cast('#endDate#' as date)
                                                    and voided = 0
                                                    group by person_id) as A
                                                    on A.observation_id = B.obs_group_id
                                                    where concept_id = 5068 and value_coded = 1
                                                    and A.observation_id = B.obs_group_id
                                                    and voided = 0
                                                    group by B.person_id
                                                ) as Stopped_clients
                                                
                                                where Stopped_clients.latest_consultation < cast('#endDate#' as date)
                                                and Stopped_clients.person_id NOT IN (
                                                            select person_id from obs -- stopped PrEP
                                                                where   
                                                                    MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                                    AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                                    and concept_id = 5005			
                                                        )
                                            )
                
                                            -- DEAD 
                                            and active_clients.person_id not in (
                                            select person_id 
                                            from person 
                                            where death_date <= cast('#endDate#' as date)
                                            and dead = 1
                                        )
                                )
                                
                                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                                LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters

        order by TwentyEightDayDefaulters.patientName)

        UNION 

        -- INCLUDE MISSED APPOINTMENTS WITH MORE THAN 89 ACCORDING TO THE NEW PEPFAR GUIDELINE
        (SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, Date_Missed, 'LTFU' AS 'Program_Status',Contacts,Village,sort_order
        FROM
                        (select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Date_Missed,
                                pa.value as Contacts,
                                person_address.city_village AS Village,		
                                observed_age_group.sort_order AS sort_order					

                        from obs o
                                -- CLIENTS WHO MISSED APPOINTMENTS > 89 DAYS
                                INNER JOIN patient ON o.person_id = patient.patient_id
                                AND o.person_id in (

                                -- Latest followup date from the lastest prep followup form, exclude voided followup date
                                select active_clients.person_id
                                        from
                                        (  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
                                            from obs B
                                            inner join 
                                            (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                            from obs where concept_id = 5029
                                            and obs_datetime <= cast('#endDate#' as date)
                                            group by person_id) as A
                                            on A.observation_id = B.obs_group_id
                                            where B.concept_id = 3752
                                            and A.observation_id = B.obs_group_id
                                            and voided = 0	
                                            group by B.person_id
                                        ) as active_clients

                                        where active_clients.latest_follow_up < cast('#endDate#' as date)
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) > 89
                        
                                        and active_clients.person_id not in (
                                            -- Exclude clients who stopped in the reporting period
                                            select distinct os.person_id
                                            from obs os
                                            where os.concept_id = 5005 and value_coded = 1
                                            AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                            )

                                        and active_clients.person_id not in (
                                
                                                select Stopped_clients.person_id
                                                from
                                                (select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
                                                    from obs B
                                                    inner join
                                                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                    from obs where concept_id = 5029
                                                    and obs_datetime <= cast('#endDate#' as date)
                                                    and voided = 0
                                                    group by person_id) as A
                                                    on A.observation_id = B.obs_group_id
                                                    where concept_id = 5068 and value_coded = 1
                                                    and A.observation_id = B.obs_group_id
                                                    and voided = 0
                                                    group by B.person_id
                                                ) as Stopped_clients
                                                
                                                where Stopped_clients.latest_consultation < cast('#endDate#' as date)
                                                and Stopped_clients.person_id NOT IN (
                                                            select person_id from obs -- stopped PrEP
                                                                where   
                                                                    MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                                    AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                                    and concept_id = 5005			
                                                        )
                                            )
                
                                            -- DEAD 
                                            and active_clients.person_id not in (
                                            select person_id 
                                            from person 
                                            where death_date <= cast('#endDate#' as date)
                                            and dead = 1
                                        )
                                )
                                
                                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                                LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters

        order by TwentyEightDayDefaulters.patientName)
        
        UNION
        
        (
            SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB,'' AS Date_Missed, Prep_Status as 'Program_Status',Contacts,Village,sort_order
                from
                (
                    (
                    select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                observed_age_group.name AS age_group,
                                'Stopped' as Prep_Status,
                                pa.value as Contacts,
                                person_address.city_village AS Village,		
                                observed_age_group.sort_order AS sort_order

                                from obs o
                                        -- CLIENTS THAT STOPPED PREP
                                        INNER JOIN patient ON o.person_id = patient.patient_id 
                                        AND o.concept_id = 5068 
                                        AND o.value_coded = 1 
                                        AND o.person_id IN (
                                            select person_id from obs 
                                                where concept_id = 5005
                                                AND MONTH(value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(value_datetime) = YEAR(CAST('#endDate#' AS DATE))						 
                                        )
                                        
                                        AND patient.voided = 0 AND o.voided = 0
                                                                
                                        INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                        INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                        INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                                        INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                        LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                                        LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                                        INNER JOIN reporting_age_group AS observed_age_group ON
                                        CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                        AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                                WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) Stopped_prep

                left outer join

                (
                    select person_id,CAST(value_datetime as DATE) AS Date_Stopped 
                    from obs 
                        where concept_id = 5005
                        AND MONTH(value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                        AND YEAR(value_datetime) = YEAR(CAST('#endDate#' AS DATE))	
                )STOPPED_DATE

                ON Stopped_prep.Id = STOPPED_DATE.person_id 
                )
        )

        UNION

          (     
             SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, DOB,'' AS Date_Missed, Prep_Status as 'Program_Status',Contacts,Village,sort_order
                from
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
                                        person.birthdate as DOB,
									   observed_age_group.name AS age_group,
                                       'Initiated' as Prep_Status, 
                                        pa.value as Contacts,
									   person_address.city_village AS Village,		
                                       observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON PREP
						inner join patient ON o.person_id = patient.patient_id 
						and o.concept_id = 4994
						and CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)

						and patient.voided = 0 
						and o.voided = 0

						and o.person_id not in 
						(
							 -- TRANSFER INN
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5070
								and os.value_coded = 2146
								and CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)	
						and o.person_id not in 
						(
							 -- HAS BEEN ON PrEP BEFORE
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5003
								and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
                          INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                          INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                          INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                          INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                          LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                          LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                          INNER JOIN reporting_age_group AS observed_age_group ON
                           CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    WHERE observed_age_group.report_group_name = 'Modified_Ages'
             )Newly_Initiated_Clients
         )

        )PREP_FOLLOW_UP

			) AS PREP_STATUS_DRVD_ROWS

			GROUP BY PREP_STATUS_DRVD_ROWS.age_group, PREP_STATUS_DRVD_ROWS.Gender
			ORDER BY PREP_STATUS_DRVD_ROWS.sort_order)
			
			
	UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					, 'All' AS 'Gender'
					, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'Stopped',1 , 0))) AS Stopped 
                    , IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'MissedWithin28Days' ,1 ,0))) AS MissedWith28Days
                    , IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'Defaulted',1 , 0))) AS Defaulted
                    , IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'LTFU',1 , 0))) AS LTFU	 
                    , IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'Initiated',1 , 0))) AS Initiated	 
					, 99 AS sort_order
		FROM (
            SELECT Id, patientIdentifier , patientName , age_group, Age, Gender,Program_Status,cast(Date_Missed as DATE) as 'Date Missed' ,Contacts, Village,sort_order

        FROM 
                (
            -- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
        (SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, Date_Missed, 'MissedWithin28Days' AS 'Program_Status',Contacts,Village,sort_order
        FROM
                        (select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Date_Missed,
                                pa.value as Contacts,
                                person_address.city_village AS Village,		
                                observed_age_group.sort_order AS sort_order					

                        from obs o
                                -- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
                                INNER JOIN patient ON o.person_id = patient.patient_id
                                AND o.person_id in (

                                -- Latest followup date from the lastest prep followup form, exclude voided followup date
                                select active_clients.person_id
                                        from
                                        (  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
                                            from obs B
                                            inner join 
                                            (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                            from obs where concept_id = 5029
                                            and obs_datetime <= cast('#endDate#' as date)
                                            group by person_id) as A
                                            on A.observation_id = B.obs_group_id
                                            where B.concept_id = 3752
                                            and A.observation_id = B.obs_group_id
                                            and voided = 0	
                                            group by B.person_id
                                        ) as active_clients

                                        where active_clients.latest_follow_up < cast('#endDate#' as date)
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) > 0
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) <= 28
                        
                                        and active_clients.person_id not in (
                                            -- Exclude clients who stopped in the reporting period
                                            select distinct os.person_id
                                            from obs os
                                            where os.concept_id = 5005 and value_coded = 1
                                            AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                            )

                                        and active_clients.person_id not in (
                                
                                                select Stopped_clients.person_id
                                                from
                                                (select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
                                                    from obs B
                                                    inner join
                                                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                    from obs where concept_id = 5029
                                                    and obs_datetime <= cast('#endDate#' as date)
                                                    and voided = 0
                                                    group by person_id) as A
                                                    on A.observation_id = B.obs_group_id
                                                    where concept_id = 5068 and value_coded = 1
                                                    and A.observation_id = B.obs_group_id
                                                    and voided = 0
                                                    group by B.person_id
                                                ) as Stopped_clients
                                                
                                                where Stopped_clients.latest_consultation < cast('#endDate#' as date)
                                                and Stopped_clients.person_id NOT IN (
                                                            select person_id from obs -- stopped PrEP
                                                                where   
                                                                    MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                                    AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                                    and concept_id = 5005			
                                                        )
                                            )
                
                                            -- DEAD 
                                            and active_clients.person_id not in (
                                            select person_id 
                                            from person 
                                            where death_date <= cast('#endDate#' as date)
                                            and dead = 1
                                        )
                                )
                                
                                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                                LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters

        order by TwentyEightDayDefaulters.patientName)

        UNION 

        -- INCLUDE MISSED APPOINTMENTS WITH MORE THAN 28 AND LESS THAN 89 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
        (SELECT   distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, Date_Missed, 'Defaulted' AS 'Program_Status',Contacts,Village,sort_order
        FROM
                        (select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Date_Missed,
                                pa.value as Contacts,
                                person_address.city_village AS Village,		
                                observed_age_group.sort_order AS sort_order					

                        from obs o
                                -- CLIENTS WHO MISSED APPOINTMENTS 28 - 89 DAYS
                                INNER JOIN patient ON o.person_id = patient.patient_id
                                AND o.person_id in (

                                -- Latest followup date from the lastest prep followup form, exclude voided followup date
                                select active_clients.person_id
                                        from
                                        (  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
                                            from obs B
                                            inner join 
                                            (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                            from obs where concept_id = 5029
                                            and obs_datetime <= cast('#endDate#' as date)
                                            group by person_id) as A
                                            on A.observation_id = B.obs_group_id
                                            where B.concept_id = 3752
                                            and A.observation_id = B.obs_group_id
                                            and voided = 0	
                                            group by B.person_id
                                        ) as active_clients

                                        where active_clients.latest_follow_up < cast('#endDate#' as date)
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) > 28
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) <= 89
                        
                                        and active_clients.person_id not in (
                                            -- Exclude clients who stopped in the reporting period
                                            select distinct os.person_id
                                            from obs os
                                            where os.concept_id = 5005 and value_coded = 1
                                            AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                            )

                                        and active_clients.person_id not in (
                                
                                                select Stopped_clients.person_id
                                                from
                                                (select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
                                                    from obs B
                                                    inner join
                                                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                    from obs where concept_id = 5029
                                                    and obs_datetime <= cast('#endDate#' as date)
                                                    and voided = 0
                                                    group by person_id) as A
                                                    on A.observation_id = B.obs_group_id
                                                    where concept_id = 5068 and value_coded = 1
                                                    and A.observation_id = B.obs_group_id
                                                    and voided = 0
                                                    group by B.person_id
                                                ) as Stopped_clients
                                                
                                                where Stopped_clients.latest_consultation < cast('#endDate#' as date)
                                                and Stopped_clients.person_id NOT IN (
                                                            select person_id from obs -- stopped PrEP
                                                                where   
                                                                    MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                                    AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                                    and concept_id = 5005			
                                                        )
                                            )
                
                                            -- DEAD 
                                            and active_clients.person_id not in (
                                            select person_id 
                                            from person 
                                            where death_date <= cast('#endDate#' as date)
                                            and dead = 1
                                        )
                                )
                                
                                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                                LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters

        order by TwentyEightDayDefaulters.patientName)

        UNION 

        -- INCLUDE MISSED APPOINTMENTS WITH MORE THAN 89 ACCORDING TO THE NEW PEPFAR GUIDELINE
        (SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, Date_Missed, 'LTFU' AS 'Program_Status',Contacts,Village,sort_order
         FROM
                        (select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Date_Missed,
                                pa.value as Contacts,
                                person_address.city_village AS Village,
                                observed_age_group.sort_order AS sort_order     					

                        from obs o
                                -- CLIENTS WHO MISSED APPOINTMENTS > 89 DAYS
                                INNER JOIN patient ON o.person_id = patient.patient_id
                                AND o.person_id in (

                                -- Latest followup date from the lastest prep followup form, exclude voided followup date
                                select active_clients.person_id
                                        from
                                        (  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
                                            from obs B
                                            inner join 
                                            (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                            from obs where concept_id = 5029
                                            and obs_datetime <= cast('#endDate#' as date)
                                            group by person_id) as A
                                            on A.observation_id = B.obs_group_id
                                            where B.concept_id = 3752
                                            and A.observation_id = B.obs_group_id
                                            and voided = 0	
                                            group by B.person_id
                                        ) as active_clients

                                        where active_clients.latest_follow_up < cast('#endDate#' as date)
                                        and DATEDIFF(CAST('#endDate#' AS DATE), active_clients.latest_follow_up) > 89
                        
                                        and active_clients.person_id not in (
                                            -- Exclude clients who stopped in the reporting period
                                            select distinct os.person_id
                                            from obs os
                                            where os.concept_id = 5005 and value_coded = 1
                                            AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                            )

                                        and active_clients.person_id not in (
                                
                                                select Stopped_clients.person_id
                                                from
                                                (select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
                                                    from obs B
                                                    inner join
                                                    (select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                    from obs where concept_id = 5029
                                                    and obs_datetime <= cast('#endDate#' as date)
                                                    and voided = 0
                                                    group by person_id) as A
                                                    on A.observation_id = B.obs_group_id
                                                    where concept_id = 5068 and value_coded = 1
                                                    and A.observation_id = B.obs_group_id
                                                    and voided = 0
                                                    group by B.person_id
                                                ) as Stopped_clients
                                                
                                                where Stopped_clients.latest_consultation < cast('#endDate#' as date)
                                                and Stopped_clients.person_id NOT IN (
                                                            select person_id from obs -- stopped PrEP
                                                                where   
                                                                    MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                                    AND YEAR(obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                                                    and concept_id = 5005			
                                                        )
                                            )
                
                                            -- DEAD 
                                            and active_clients.person_id not in (
                                            select person_id 
                                            from person 
                                            where death_date <= cast('#endDate#' as date)
                                            and dead = 1
                                        )
                                )
                                
                                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                                LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters

        order by TwentyEightDayDefaulters.patientName)
        
        UNION
        
        (
            SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB,'' AS Date_Missed, Prep_Status as 'Program_Status',Contacts,Village,sort_order
                from
                (
                    (
                    select distinct patient.patient_id AS Id,
                                                    patient_identifier.identifier AS patientIdentifier,
                                                    concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                                    person.birthdate as DOB,
                                                    person.gender AS Gender,
                                                    observed_age_group.name AS age_group,
                                                    'Stopped' as Prep_Status,
                                                    pa.value as Contacts,
                                                    person_address.city_village AS Village,		
                                                    observed_age_group.sort_order AS sort_order

                                from obs o
                                        -- CLIENTS THAT STOPPED PREP
                                        INNER JOIN patient ON o.person_id = patient.patient_id 
                                        AND o.concept_id = 5068 
                                        AND o.value_coded = 1 
                                        AND o.person_id IN (
                                            select person_id from obs 
                                                where concept_id = 5005
                                                AND MONTH(value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(value_datetime) = YEAR(CAST('#endDate#' AS DATE))						 
                                        )
                                        
                                        AND patient.voided = 0 AND o.voided = 0
                                                                
                                        INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                        INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                        INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                                        INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                        LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                                        LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                                        INNER JOIN reporting_age_group AS observed_age_group ON
                                        CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                        AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                                WHERE observed_age_group.report_group_name = 'Modified_Ages'
                ) Stopped_prep

                left outer join

                (
                    select person_id,CAST(value_datetime as DATE) AS Date_Stopped 
                    from obs 
                        where concept_id = 5005
                        AND MONTH(value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                        AND YEAR(value_datetime) = YEAR(CAST('#endDate#' AS DATE))	
                )STOPPED_DATE

                ON Stopped_prep.Id = STOPPED_DATE.person_id 
                )
        )

        UNION 

         (     
             SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, DOB,'' AS Date_Missed, Prep_Status as 'Program_Status',Contacts,Village,sort_order
                from
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
                                        person.birthdate as DOB,
									   observed_age_group.name AS age_group,
                                       'Initiated' as Prep_Status, 
                                        pa.value as Contacts,
									   person_address.city_village AS Village,		
                                       observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON PREP
						inner join patient ON o.person_id = patient.patient_id 
						and o.concept_id = 4994
						and CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)

						and patient.voided = 0 
						and o.voided = 0

						and o.person_id not in 
						(
							 -- TRANSFER INN
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5070
								and os.value_coded = 2146
								and CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)	
						and o.person_id not in 
						(
							 -- HAS BEEN ON PrEP BEFORE
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5003
								and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
                          INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                          INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                          INNER JOIN person_address ON person_address.person_id =  person.person_id AND person_address.voided = 0
                          INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                          LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                          LEFT OUTER JOIN person_attribute pa ON pa.person_id = person.person_id AND pa.person_attribute_type_id in (26) AND p.voided = 0
                          INNER JOIN reporting_age_group AS observed_age_group ON
                           CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    WHERE observed_age_group.report_group_name = 'Modified_Ages'
             )Newly_Initiated_Clients
         )

    )PREP_FOLLOW_UP
			) AS PREP_STATUS_DRVD_COLS
		)
		
	) AS PREP_TOTALS_COLS_ROWS
ORDER BY PREP_TOTALS_COLS_ROWS.sort_order
