SELECT HTS_TOTALS_COLS_ROWS.AgeGroup
            , HTS_TOTALS_COLS_ROWS.Gender
        	, HTS_TOTALS_COLS_ROWS.First_Visit
			, HTS_TOTALS_COLS_ROWS.Rescreened
			, HTS_TOTALS_COLS_ROWS.Treatment_Follow_up
			, HTS_TOTALS_COLS_ROWS.Cryotherapy_Treated
			, HTS_TOTALS_COLS_ROWS.LEEP_Treated
		
			, HTS_TOTALS_COLS_ROWS.Total
			
			
		   
		

FROM (

			(SELECT CANCER_SCREENED.age_group AS 'AgeGroup'
					, CANCER_SCREENED.Gender
						, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Visit_Type = 'First_Visit', 1, 0))) AS First_Visit
						, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Visit_Type = 'Rescreened', 1, 0))) AS Rescreened
						, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Visit_Type = 'Treatment_Follow_up', 1, 0))) AS Treatment_Follow_up
						, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Treatment = 'Cryotherapy', 1, 0))) AS Cryotherapy_Treated
						, IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Treatment = 'LEEP', 1, 0))) AS LEEP_Treated
						
				        , IF(CANCER_SCREENED.Id IS NULL, 0, SUM(IF(CANCER_SCREENED.Treatment = 'Cryotherapy' or CANCER_SCREENED.Treatment = 'LEEP', 1, 0))) as 'Total'
						, CANCER_SCREENED.sort_order
			FROM (

(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Cryotherapy' AS 'Treatment','First_Visit' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer via or pap smear or both
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)    
						   -- first visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						-- previous Treatment
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and (os.value_coded = 1016)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						
						-- cryotheraphy as treatment
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4533)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						
						 
					     INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
				   
ORDER BY Screened_For_Cancer.Age)

UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'LEEP' AS 'Treatment','First_Visit' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						
						 -- first visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						 -- previous Treatment
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and (os.value_coded = 1016)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
							-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- VIA lletz
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4534)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)


UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Cryotherapy' AS 'Treatment','Rescreened' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- via positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4533)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- second  visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						    
						-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						
						
						--   previous Treatment screened negative
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)

UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'LEEP' AS 'Treatment','Rescreened' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- LLtez
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4534)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- second  visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						--   Treatment screened negative
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
							-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)


UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Cryotherapy' AS 'Treatment','Treatment_Follow_up' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- cryotheraphy
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4533)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- second  visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						--   Treatment screened positive
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
							-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)

UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'LEEP' AS 'Treatment','Treatment_Follow_up' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- via posi
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							 where os.concept_id = 4535 and (os.value_coded = 4534)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- second  visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						--   Treatment screened positive
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
							-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						 AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)


					 
			
			) AS CANCER_SCREENED

			GROUP BY CANCER_SCREENED.age_group, CANCER_SCREENED.Gender
			ORDER BY CANCER_SCREENED.sort_order)
			

UNION ALL
		

			
			(SELECT 'Total' AS 'AgeGroup'
					, 'All' AS 'Gender'
						, IF(HTS_TOTALS_COLS.Id IS NULL, 0, SUM(IF(HTS_TOTALS_COLS.Visit_Type = 'First_Visit', 1, 0))) AS First_Visit
						, IF(HTS_TOTALS_COLS.Id IS NULL, 0, SUM(IF(HTS_TOTALS_COLS.Visit_Type = 'Rescreened', 1, 0))) AS Rescreened
						, IF(HTS_TOTALS_COLS.Id IS NULL, 0, SUM(IF(HTS_TOTALS_COLS.Visit_Type = 'Treatment_Follow_up', 1, 0))) AS Treatment_Follow_up
						, IF(HTS_TOTALS_COLS.Id IS NULL, 0, SUM(IF(HTS_TOTALS_COLS.Treatment = 'Cryotherapy', 1, 0))) AS Cryotherapy_Treated
						, IF(HTS_TOTALS_COLS.Id IS NULL, 0, SUM(IF(HTS_TOTALS_COLS.Treatment = 'LEEP', 1, 0))) AS LEEP_Treated
						
				        , IF(HTS_TOTALS_COLS.Id IS NULL, 0, SUM(IF(HTS_TOTALS_COLS.Treatment = 'Cryotherapy' or HTS_TOTALS_COLS.Treatment = 'LEEP', 1, 0))) as 'Total'
						, 99 AS sort_order

			
			      FROM
				  (
				  
				  
(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Cryotherapy' AS 'Treatment','First_Visit' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer via or pap smear or both
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)    
						   -- first visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						-- previous Treatment
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and (os.value_coded = 1016)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						
						-- cryotheraphy as treatment
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4533)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						
						 
					     INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
				   
ORDER BY Screened_For_Cancer.Age)

UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'LEEP' AS 'Treatment','First_Visit' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						
						 -- first visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						 -- previous Treatment
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and (os.value_coded = 1016)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
							-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- VIA lletz
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4534)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)


UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Cryotherapy' AS 'Treatment','Rescreened' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- via positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4533)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- second  visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						    
						-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						
						
						--   previous Treatment screened negative
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)

UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'LEEP' AS 'Treatment','Rescreened' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- LLtez
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4534)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- second  visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						--   Treatment screened negative
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
							-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						  AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)


UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Cryotherapy' AS 'Treatment','Treatment_Follow_up' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- cryotheraphy
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4535 and (os.value_coded = 4533)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- second  visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						--   Treatment screened positive
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
							-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)

UNION

(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'LEEP' AS 'Treatment','Treatment_Follow_up' AS 'Visit_Type', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						 ) 
						 AND patient.voided = 0 AND o.voided = 0
						 
						 
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
							
						AND o.person_id not in 
								(
						       select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- exclude treatment interruptions
						AND o.person_id not in
						        (
								
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4159 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								
						) 
						-- exclude LTFU
					
						AND o.person_id not in
						       (
							   
							   	select distinct os.person_id   
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 28		
						
						)
						-- screened for cancer
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4527 and (os.value_coded = 4757 or os.value_coded = 4525 or os.value_coded = 4526)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- via posi
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							 where os.concept_id = 4535 and (os.value_coded = 4534)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						-- second  visit
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
						--   Treatment screened positive
						AND o.person_id in
						
						    (
							
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						
						)
						
							-- VIA positive
						AND o.person_id in
						        
							(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 327 and (os.value_coded = 328)
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							
							
						)
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  
						 AND Gender = 'F' and observed_age_group.min_years >= 15 and observed_age_group.max_years < 200
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Screened_For_Cancer
ORDER BY Screened_For_Cancer.Age)

				   
				   
					  
				  ) AS HTS_TOTALS_COLS
			
			
			
			
			)
			
			
			) AS HTS_TOTALS_COLS_ROWS
ORDER BY HTS_TOTALS_COLS_ROWS.sort_order

