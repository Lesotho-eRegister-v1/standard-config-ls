SELECT  patientIdentifier , patientName , Age, Gender,Program_Status,Why_stopped_prep,Event_date ,Contacts, Village
FROM 
   (
    select  patientIdentifier , patientName , Age, Gender,Program_Status,Why_stopped_prep,cast(Event_date as DATE) as 'Event_date' ,Contacts, Village
    from 
    (
       (
             -- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
        (SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, Event_date, 'MissedWithin28Days' AS 'Program_Status',Contacts,Village
        FROM
                        (select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Event_date,
                                pa.value as Contacts,
                                person_address.city_village AS Village					

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
                                            AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
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
        (SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, Event_date, 'Defaulted' AS 'Program_Status',Contacts,Village
        FROM
                        (select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Event_date,
                                pa.value as Contacts,
                                person_address.city_village AS Village					

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
                                            AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
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
        (SELECT  distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, Event_date, 'LTFU' AS 'Program_Status',Contacts,Village
        FROM
                        (select distinct patient.patient_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                observed_age_group.name AS age_group,
                                person.birthdate as DOB,
                                person.gender AS Gender,
                                cast(max(value_datetime) as date) as Event_date,
                                pa.value as Contacts,
                                person_address.city_village AS Village					

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
                                            AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                            AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
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
            
            SELECT distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB, stopped_date AS Event_date, Prep_Status as 'Program_Status',Contacts,Village
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
                                                    observed_age_group.sort_order AS sort_order,
                                                    CAST(o.obs_datetime as date) as stopped_date

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
                    select person_id,CAST(value_datetime as DATE) AS Date_Stopped from obs 
                                                where concept_id = 5005
                                                AND MONTH(value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                                AND YEAR(value_datetime) = YEAR(CAST('#endDate#' AS DATE))	
                )STOPPED_DATE

                ON Stopped_prep.Id = STOPPED_DATE.person_id 
                )
        )

        UNION 

         (     
             SELECT distinct Id, patientIdentifier, patientName, Age, Gender, age_group, DOB,Initiated_date AS Event_date, Prep_Status as 'Program_Status',Contacts,Village
                from
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
                                        person.birthdate as DOB,
									   observed_age_group.name AS age_group,
                                       'Initiated' as Prep_Status, 
                                        cast(o.value_datetime as DATE) AS Initiated_date,
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
								where os.concept_id = 5003 and os.value_coded = 1
								and CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
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
       )followupData

        LEFT OUTER JOIN
        
        (
                select distinct patient.patient_id,
                            CASE WHEN o.value_coded = 4997 THEN 'Patients Decision'
                                 WHEN o.value_coded = 4998 THEN 'Poor Adherence'
                                 WHEN o.value_coded = 4999 THEN 'New HIV status'
                                 WHEN o.value_coded = 5000 THEN 'Patient no longer being at high risk for HVI infection'
                                 WHEN o.value_coded = 5001 THEN 'Significant side effects'
                            END AS 'Why_stopped_prep'

                from obs o
						-- CLIENTS NEWLY INITIATED ON PREP
						inner join patient ON o.person_id = patient.patient_id 
						and o.concept_id = 4996
						and CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)

						and patient.voided = 0 
						and o.voided = 0

						
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
        )why_stopped

        ON followupData.Id = why_stopped.patient_id
    )
             
)FINAL_DATA
ORDER BY FINAL_DATA.Program_Status