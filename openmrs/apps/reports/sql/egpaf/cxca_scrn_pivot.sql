SELECT CXCA_TOTALS_COLS_ROWS.AgeGroup
            , CXCA_TOTALS_COLS_ROWS.VIA_Test
        	, CXCA_TOTALS_COLS_ROWS.PapSmear
			, CXCA_TOTALS_COLS_ROWS.Vili_Test
			, CXCA_TOTALS_COLS_ROWS.HPV_Test
FROM (

			(SELECT CANCER_SCREENED.age_group AS 'AgeGroup'
			, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Screening_Type = 'Cervical VIA Test', 1, 0))) AS VIA_Test
			, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Screening_Type = 'Pap Smear', 1, 0))) AS PapSmear
			, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Screening_Type = 'Vili Test', 1, 0))) AS Vili_Test
			, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Screening_Type = 'Cervical HPV Test', 1, 0))) AS HPV_Test
			, CANCER_SCREENED.sort_order
			
	FROM (
			SELECT Id, patientIdentifier, patientName, Age,DOB, Gender, Screening_Type, age_group,sort_order
    		FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   pi.identifier as File_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order
									  

                         from obs o

						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0
                          and o.person_id in (
                                select active_clients.person_id -- Active on ART
                                        from
                                        (select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
                                                from obs B
                                                inner join 
                                                (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                from obs where concept_id = 3753
                                                and obs_datetime <= cast('#endDate#' as date)
                                                and voided = 0
                                                group by person_id) as A
                                                on A.observation_id = B.obs_group_id
                                                where concept_id = 3752
                                                and A.observation_id = B.obs_group_id
                                                and voided = 0	
                                                group by B.person_id
                                        ) as active_clients
                                        where active_clients.latest_follow_up >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -28 DAY)
		
                                and active_clients.person_id not in (
                                        select person_id -- Dead
                                        from person 
                                        where death_date <= cast('#endDate#' as date)
                                        and dead = 1 and voided = 0
                                        
                                        )

		                and active_clients.person_id not in(
                                                                -- Visitors
                                        select person_id 
                                        FROM
                                        (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                        from obs where concept_id = 5416 
                                        and value_coded = 1 and voided = 0
                                        and cast(obs_datetime as date) <= cast('#endDate#' as date)
                                        and voided = 0
                                        group by person_id)visitor
					)

                          )
						  
                inner join  
                (
                select distinct B.person_id
                from obs B
                inner join 
                (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                from obs where concept_id = 4511 -- Cervical Cancer Screening Register
                AND CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                AND CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                group by person_id) as A
                on A.observation_id = B.obs_group_id
                where concept_id = 4521 and value_coded = 1738 -- Positive HIV Status
                and A.observation_id = B.obs_group_id
                and voided = 0	
                group by B.person_id
		) as hiv_pos
                on hiv_pos.person_id = o.person_id

                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11
                INNER JOIN reporting_age_group AS observed_age_group ON
                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Cervical_Cancer_Screened

-- inner join 
left outer join 
(
        select distinct os.person_id,
       case
       -- Screening Type
           when os.value_coded = 4757 then "Cervical VIA Test"
           when os.value_coded = 4525 then "Pap Smear"
           when os.value_coded = 5500 then "Vili Test"
		   when os.value_coded = 6114 then "Cervical HPV Test"
           else ""
       end AS Screening_Type
       from obs os 
       where os.concept_id = 4527
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)screening_type
on screening_type.person_id = Cervical_Cancer_Screened.Id
) AS CANCER_SCREENED

GROUP BY CANCER_SCREENED.age_group
ORDER BY CANCER_SCREENED.sort_order)
			
UNION ALL

(SELECT 'Total' AS 'AgeGroup'					
		, IF(CXCA_Screening_COLS.Id IS NULL, 0, SUM(IF(CXCA_Screening_COLS.Screening_Type = 'Cervical VIA Test', 1, 0))) AS VIA_Test
		, IF(CXCA_Screening_COLS.Id IS NULL, 0, SUM(IF(CXCA_Screening_COLS.Screening_Type = 'Pap Smear', 1, 0))) AS PapSmear
		, IF(CXCA_Screening_COLS.Id IS NULL, 0, SUM(IF(CXCA_Screening_COLS.Screening_Type = 'Vili Test', 1, 0))) AS Vili_Test
		, IF(CXCA_Screening_COLS.Id IS NULL, 0, SUM(IF(CXCA_Screening_COLS.Screening_Type = 'Cervical HPV Test', 1, 0))) AS HPV_Test
		, 99 AS sort_order
			FROM (
			
(
	SELECT Id, patientIdentifier, patientName, Age,DOB, Gender, Screening_Type, age_group,sort_order
    		FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   pi.identifier as File_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order
									  

                         from obs o

						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0
                          and o.person_id in (
                                select active_clients.person_id -- Active on ART
                                        from
                                        (select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
                                                from obs B
                                                inner join 
                                                (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                from obs where concept_id = 3753
                                                and obs_datetime <= cast('#endDate#' as date)
                                                and voided = 0
                                                group by person_id) as A
                                                on A.observation_id = B.obs_group_id
                                                where concept_id = 3752
                                                and A.observation_id = B.obs_group_id
                                                and voided = 0	
                                                group by B.person_id
                                        ) as active_clients
                                        where active_clients.latest_follow_up >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -28 DAY)
		
                                and active_clients.person_id not in (
                                        select person_id -- Dead
                                        from person 
                                        where death_date <= cast('#endDate#' as date)
                                        and dead = 1 and voided = 0
                                        
                                        )

		                and active_clients.person_id not in(
                                                                -- Visitors
                                        select person_id 
                                        FROM
                                        (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                        from obs where concept_id = 5416 
                                        and value_coded = 1 and voided = 0
                                        and cast(obs_datetime as date) <= cast('#endDate#' as date)
                                        and voided = 0
                                        group by person_id)visitor
					)

                          )
						  
                inner join  
                (
                select distinct B.person_id
                from obs B
                inner join 
                (select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                from obs where concept_id = 4511 -- Cervical Cancer Screening Register
                AND CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                AND CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                group by person_id) as A
                on A.observation_id = B.obs_group_id
                where concept_id = 4521 and value_coded = 1738 -- Positive HIV Status
                and A.observation_id = B.obs_group_id
                and voided = 0	
                group by B.person_id
		) as hiv_pos
                on hiv_pos.person_id = o.person_id

                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11
                INNER JOIN reporting_age_group AS observed_age_group ON
                CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Cervical_Cancer_Screened

-- inner join 
left outer join 
(
        select distinct os.person_id,
       case
       -- Screening Type
           when os.value_coded = 4757 then "Cervical VIA Test"
           when os.value_coded = 4525 then "Pap Smear"
           when os.value_coded = 5500 then "Vili Test"
		   when os.value_coded = 6114 then "Cervical HPV Test"
           else ""
       end AS Screening_Type
       from obs os 
       where os.concept_id = 4527
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)screening_type
on screening_type.person_id = Cervical_Cancer_Screened.Id	
			
)
	)CXCA_Screening_COLS	
) 
) AS CXCA_TOTALS_COLS_ROWS
ORDER BY CXCA_TOTALS_COLS_ROWS.sort_order

