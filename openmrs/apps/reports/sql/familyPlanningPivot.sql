
(
 		SELECT distinct DRVD_ROWS.FP_Visit as 'FP Attendance'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age < 15, 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 15 AND DRVD_ROWS.Age < 20, 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 20 AND DRVD_ROWS.Age < 25, 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 25, 1, 0))) AS CHAR)AS '25+ years' 					
		
		FROM (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender,       
                             CASE
                                WHEN code = 2093 THEN 'New'
                                WHEN code = 4539 THEN 'Revisit'
                                WHEN code = 2303 THEN 'Restarted'
                             ELSE 'typeOfFpVisit'
                             END AS 'FP_Visit', sort_order
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,
                                               o.value_coded as 'code'

						from obs o
								-- FP Attendance 

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4538 and o.value_coded IN (2093,4539,2303)
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
						) AS new_fp
		    ORDER BY new_fp.sort_order desc
			
			)DRVD_ROWS 
			GROUP BY DRVD_ROWS.FP_Visit
			ORDER BY DRVD_ROWS.FP_Visit desc
					
)
                                            
UNION ALL

(
		SELECT 
        distinct DRVD_ROWS.OnART as 'On ART'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age < 15, 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 15 AND DRVD_ROWS.Age < 20, 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 20 AND DRVD_ROWS.Age < 25, 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 25, 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, 'On ART' as OnART
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                               person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order  
                                                
						    from obs o
								-- FP Attendance on ART 
                                 INNER JOIN patient ON o.person_id = patient.patient_id 
                                 and o.concept_id = 2403
								 AND patient.voided = 0 AND o.voided = 0 
                                 AND CAST(o.obs_datetime AS DATE) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
                                 and o.person_id in (
                                        select person_id from obs 
                                        where concept_id = 4538 and value_coded IN (2093,4539,2303)
								        AND voided = 0
								        AND CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		        AND CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                 )
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
						) prep
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.OnART
				ORDER BY DRVD_ROWS.OnART desc
)

UNION ALL

(
		SELECT 
        distinct DRVD_ROWS.OnPrEP as 'On PrEP'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age < 15, 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 15 AND DRVD_ROWS.Age < 20, 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 20 AND DRVD_ROWS.Age < 25, 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 25, 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender,'On PrEP' as OnPrEP
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order

						        from obs o
								-- FP attendacnce On PrEP

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 5204 								 
								 AND patient.voided = 0 AND o.voided = 0 
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                 and o.person_id in (
                                        select person_id from obs 
                                        where concept_id = 4538 and value_coded IN (2093,4539,2303)
								        AND voided = 0
								        AND CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		        AND CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                 )						
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								 CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
						) On_PrEP
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.OnPrEP
				ORDER BY DRVD_ROWS.OnPrEP desc
)

UNION ALL 
(	SELECT 'FP Method Issued','---------------' ,'---------------' ,'---------------' ,'---------------'  FROM reporting_age_group limit 1)
 
                                          
UNION ALL

(
		SELECT 
        distinct DRVD_ROWS.FP_Method as 'Family Planning Method Issued'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age < 15, 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 15 AND DRVD_ROWS.Age < 20, 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 20 AND DRVD_ROWS.Age < 25, 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 25, 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier",FP_Method, patientName AS "Patient_Name", Age, age_group, Gender
		        FROM
						(
							select distinct method_provided.person_id AS Id,
											    patient_identifier.identifier AS patientIdentifier,
											    concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											    floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											    observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											    observed_age_group.sort_order AS sort_order,
												case 
												WHEN value_coded = 5205 THEN 'Progestrone only pill' 
												WHEN value_coded = 5206 THEN 'Combined oral contraceptive' 
												WHEN value_coded = 5207 THEN 'Depo medroxy progestrone acetate subcutatneous (DMPA-SC)' 
												WHEN value_coded = 5208 THEN 'Depo medroxy progestrone acetate intramusc' 
												WHEN value_coded = 5209 THEN 'Noristrate (NTE)' 
												WHEN value_coded = 2314 THEN 'Implant' 
												WHEN value_coded = 4551 THEN 'Jadelle' 
												WHEN value_coded = 5212 THEN 'Norplant' 
												WHEN value_coded = 4441 THEN 'Lactational Amenorrhea Method' 
												WHEN value_coded = 4552 THEN 'Copper T380A' 
												WHEN value_coded = 5214 THEN 'Intra Uterine Contraceptive Device(IUCD)' 
												WHEN value_coded = 4440 THEN 'Bilateral Tubal Ligation (BTL)' 
												WHEN value_coded = 2497 THEN 'Vasectomy' 
												WHEN value_coded = 4229 THEN 'Male Condoms' 
												WHEN value_coded = 4230 THEN 'Female Condoms' 
												WHEN value_coded = 4553 THEN 'Standard Days Method' 
												WHEN value_coded = 5215 THEN 'Emegency Pill' 
												WHEN value_coded = 1154 THEN 'None' 
												ELSE ''
										end AS FP_Method

								from
									
									(select B.person_id, B.obs_group_id, B.obs_datetime AS latest_fp_method,value_coded
									from obs B
									inner join 
										(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
										from obs where concept_id = 5225 -- Pick from method provided section
										and obs_datetime <= cast('#endDate#' as date)
										and voided = 0
										group by person_id) as A
										on A.observation_id = B.obs_group_id
										where concept_id = 2481
										and A.observation_id = B.obs_group_id
										and voided = 0	
										AND CAST(B.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
										AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									
								 )method_provided	
								 inner join patient_identifier ON patient_identifier.patient_id = method_provided.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN person_name ON method_provided.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN person ON method_provided.person_id = person.person_id AND person.voided = 0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								 CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   		 WHERE observed_age_group.report_group_name = 'Modified_Ages'
						) FP_Method
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.FP_Method
				ORDER BY DRVD_ROWS.FP_Method desc
)

UNION ALL 

(	SELECT 'Services Provided','---------------' ,'---------------' ,'---------------' ,'---------------'  FROM reporting_age_group limit 1)

UNION ALL

(
		SELECT 
        distinct DRVD_ROWS.TB_SCREENING
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age < 15, 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 15 AND DRVD_ROWS.Age < 20, 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 20 AND DRVD_ROWS.Age < 25, 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 25, 1, 0))) AS CHAR)AS '25+ years' 
										
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, 'TB Screening' as TB_SCREENING
		        FROM
						(select distinct tb_screening.person_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order
									
							from 		
								-- FP attendacnce FP service TB Screening
								(
								select B.person_id, B.obs_group_id, B.obs_datetime AS fp_tb_screening,value_coded
								from obs B
								inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 4544 -- Pick from Exams, Screens and Removals
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 4447 -- TB Screening
									and A.observation_id = B.obs_group_id
									and voided = 0	
									AND CAST(B.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								)tb_screening
								 inner join patient_identifier ON patient_identifier.patient_id = tb_screening.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN person_name ON tb_screening.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN person ON tb_screening.person_id = person.person_id AND person.voided = 0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								 CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   		 WHERE observed_age_group.report_group_name = 'Modified_Ages'

						) TB_SCREENING
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.TB_SCREENING
				ORDER BY DRVD_ROWS.TB_SCREENING desc
)

UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.STI_SCREENING
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age < 15, 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 15 AND DRVD_ROWS.Age < 20, 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 20 AND DRVD_ROWS.Age < 25, 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 25, 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, 'STI Screening' as STI_SCREENING
		        FROM
						(select distinct screening.person_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order
									
								from 
								(
									select B.person_id, B.obs_group_id, B.obs_datetime AS sti_screening, value_coded
									from obs B
									inner join 
										(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
										from obs where concept_id = 4544 -- Pick from Exams, Screens and Removals
										and obs_datetime <= cast('#endDate#' as date)
										and voided = 0
										group by person_id) as A
										on A.observation_id = B.obs_group_id
										where concept_id = 4443 -- STI Screening
										and A.observation_id = B.obs_group_id
										and voided = 0	
										AND CAST(B.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
										AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								)screening
								 inner join patient_identifier ON patient_identifier.patient_id = screening.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN person_name ON screening.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN person ON screening.person_id = person.person_id AND person.voided = 0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								 CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   		 WHERE observed_age_group.report_group_name = 'Modified_Ages'
						) sti_screening
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.STI_SCREENING
				ORDER BY DRVD_ROWS.STI_SCREENING desc
)

UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.STI_TREATMENT
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age < 15, 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 15 AND DRVD_ROWS.Age < 20, 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 20 AND DRVD_ROWS.Age < 25, 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 25, 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, 'STI Treatment' as STI_TREATMENT
		        FROM
						(select distinct treatment.person_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order
									
								from 
								(
									select B.person_id, B.obs_group_id, B.obs_datetime AS sti_treatment, value_coded
									from obs B
									inner join 
										(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
										from obs where concept_id = 4544 -- Pick from Exams, Screens and Removals
										and obs_datetime <= cast('#endDate#' as date)
										and voided = 0
										group by person_id) as A
										on A.observation_id = B.obs_group_id
										where concept_id = 5191 -- STI Treatment
										and A.observation_id = B.obs_group_id
										and voided = 0	
										AND CAST(B.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
										AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								)treatment
								 inner join patient_identifier ON patient_identifier.patient_id = treatment.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN person_name ON treatment.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN person ON treatment.person_id = person.person_id AND person.voided = 0
								 INNER JOIN reporting_age_group AS observed_age_group ON
								 CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   		 WHERE observed_age_group.report_group_name = 'Modified_Ages'
						) sti_treatment
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.STI_TREATMENT
				ORDER BY DRVD_ROWS.STI_TREATMENT desc
)

UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.HIV_Testing
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age < 15, 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 15 AND DRVD_ROWS.Age < 20, 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 20 AND DRVD_ROWS.Age < 25, 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.Age >= 25, 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, 'HIV Testing' as HIV_Testing
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order 
								from obs o
								-- FP Attendance 

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 5202 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
						) hiv_testing
				)DRVD_ROWS
				GROUP BY DRVD_ROWS.HIV_Testing
				ORDER BY DRVD_ROWS.HIV_Testing desc
)

