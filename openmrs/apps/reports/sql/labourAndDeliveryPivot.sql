
(
 		SELECT distinct DRVD_ROWS.mode_of_delivery as ' ===>  Mode of Delivery'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender,       
											CASE
												WHEN code = 1925 THEN 'Normal Vertex Delivery'
												WHEN code = 1926 THEN 'Assisted Vaginal Delivery'
												WHEN code = 1927 THEN 'Cesarean Section'
												WHEN code = 5364 THEN 'Vaginal Breech Delivery'
												WHEN code = 4288 THEN 'Normal Vertex Delivery and Cesarean Section'
												ELSE 'no selection made'
											END AS 'mode_of_delivery', sort_order
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
												-- [A] Institutional Deliveries sectin : Intergrated facility report

												INNER JOIN patient ON o.person_id = patient.patient_id 
												AND o.concept_id = 5363 and o.value_coded IN (1925,1926,1927,5364,4288)
												AND patient.voided = 0 AND o.voided = 0
												AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
												AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											
												INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
												INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
												INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
												
												INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY		
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.mode_of_delivery
						ORDER BY DRVD_ROWS.mode_of_delivery desc
					
)

UNION ALL 
(	SELECT '==>   Gestation Age Period','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)
                                               
UNION ALL
(
		SELECT 
        distinct DRVD_ROWS.gestation_age_admission as 'DeliveryData'
		    ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
			,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,gestation_age_admission
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                            CASE
                                                                WHEN (o.value_numeric <= 36) THEN '< 37 GA'
                                                                WHEN (o.value_numeric >= 37 AND o.value_numeric <= 43) THEN '37 - 42 GA'
                                                                WHEN (o.value_numeric > 43) THEN '> 42 GA'
                                                                ELSE 'no gestation selection'
                                                            END AS 'gestation_age_admission'

										from obs o
													-- Gestation Age at Admission
                                                INNER JOIN patient ON o.person_id = patient.patient_id 
                                                AND o.concept_id = 1923 and (o.value_numeric >= 1) 
                                                AND patient.voided = 0 AND o.voided = 0
                                                AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)	
												INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
												INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
												INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
												
												INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.gestation_age_admission
                        ORDER BY DRVD_ROWS.gestation_age_admission desc
)

UNION ALL 

(	SELECT '==>   ANC Attendance','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(

		SELECT 
          distinct  DRVD_ROWS.anc_attendance as 'DeliveryData'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,anc_attendance
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,      
                                                            CASE
                                                                WHEN (o.value_numeric < 8) THEN '< 8 visits'
                                                                WHEN (o.value_numeric > 7) THEN ' 8+ visits'
                                                                WHEN (o.value_numeric = 0) THEN 'Not Attend ANC'
                                                                ELSE 'no attendance provided'
                                                            END AS 'anc_attendance' 

										from obs o
													--  ANC ATTENDANCE
                                                INNER JOIN patient ON o.person_id = patient.patient_id 
                                                AND o.concept_id = 5106 and (o.value_numeric >= 0)  
                                                AND patient.voided = 0 AND o.voided = 0
                                                AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)	
												INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
												INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
												INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
												
												INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.anc_attendance
                        ORDER BY DRVD_ROWS.anc_attendance desc
)
UNION ALL 

(	SELECT '==>   HIV Status ANC','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(

		SELECT 
          distinct  DRVD_ROWS.hiv_status as 'DeliveryData'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,hiv_status
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                            CASE
                                                                WHEN o.value_coded = 1738 THEN 'Positive from Obstetric Record'
                                                                WHEN o.value_coded = 1016 THEN 'Negative from Obstetric Record'
                                                                WHEN o.value_coded = 4324 THEN 'Known Negative from Obstetric Record'
                                                                WHEN o.value_coded = 4323 THEN 'Known Positive from Obstetric Record'
                                                                WHEN o.value_coded = 1739 THEN 'Unknown'
                                                                ELSE 'no status provided'
                                                            END AS 'hiv_status' 

                                                        from obs o
                                                                -- Get the HIV status of the clients at ANC
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 1741 and o.value_coded IN (1738,1016,4324,4323,1739)
                                                                    AND patient.voided = 0 AND o.voided = 0
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)	
                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.hiv_status
                        ORDER BY DRVD_ROWS.hiv_status desc
)

UNION ALL 

(	SELECT '==>   ARV Regimen','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(


		SELECT 
          distinct  DRVD_ROWS.ANC_arv_received as 'ARV Regimen' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs' , 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs' , 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs' , 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs' , 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,ANC_arv_received
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                            CASE
                                                                WHEN o.value_coded = 2146 THEN 'ART received at ANC' -- Yes
                                                                WHEN o.value_coded = 2147 THEN 'No' 
                                                                WHEN o.value_coded = 1975 THEN 'Not Applicable' 
                                                                ELSE 'no status provided'
                                                            END AS 'ANC_arv_received' 

                                                        from obs o
                                                                -- Client receiving ART regimen at ANC
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 5119 and o.value_coded IN (2146,2147,1975)
                                                                    AND patient.voided = 0 AND o.voided = 0 
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)	
                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.ANC_arv_received
                        ORDER BY DRVD_ROWS.ANC_arv_received desc
)

UNION ALL 

(	SELECT '==>   Initiated ART','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(


		SELECT 
          distinct  DRVD_ROWS.ANC_InitiatedART_at_LAD as 'ART Initiation - LAD' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs' AND DRVD_ROWS.ANC_InitiatedART_at_LAD = 'Initiated on ART at Labour and Delivery Ward', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs' AND DRVD_ROWS.ANC_InitiatedART_at_LAD = 'Initiated on ART at Labour and Delivery Ward', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs' AND DRVD_ROWS.ANC_InitiatedART_at_LAD = 'Initiated on ART at Labour and Delivery Ward', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs' AND DRVD_ROWS.ANC_InitiatedART_at_LAD = 'Initiated on ART at Labour and Delivery Ward', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,ANC_InitiatedART_at_LAD
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
															CASE
																	WHEN o.value_coded = 2146 THEN 'Initiated on ART at Labour and Delivery Ward' -- Yes'
																	WHEN o.value_coded = 2147 THEN 'No'
																	WHEN o.value_coded = 4341 THEN 'Already on ART' 
																	WHEN o.value_coded = 1975 THEN 'Not Applicable' 
																	ELSE 'no status provided'
															END AS 'ANC_InitiatedART_at_LAD' 

                                                        from obs o

                                                                -- Client initiated on ART at Labour and Delivery
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 5120 and o.value_coded IN (2146,2147,4341,1975)
                                                                    AND patient.voided = 0 AND o.voided = 0
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)	
                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.ANC_InitiatedART_at_LAD
                                                ORDER BY DRVD_ROWS.ANC_InitiatedART_at_LAD desc

)
UNION ALL 

(	SELECT '==>   Number of foetus','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(
	 

		SELECT 
          distinct  DRVD_ROWS.number_of_feotus as 'Number of foetus'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,number_of_feotus
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                            CASE
                                                                WHEN o.value_coded = 5125 THEN 'Singleton'
                                                                WHEN o.value_coded = 5126 THEN 'Twins'
                                                                WHEN o.value_coded = 5127 THEN 'Triplets' 
                                                                WHEN o.value_coded = 1033 THEN 'Quadtriples +' 
                                                                ELSE 'no status provided'
                                                            END AS 'number_of_feotus'

                                                        from obs o
                                                                    -- Client number of foetus
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 5124 and o.value_coded IN (5125,5126,5127,1033)
                                                                    AND patient.voided = 0 AND o.voided = 0
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.number_of_feotus
                        ORDER BY DRVD_ROWS.number_of_feotus desc
)
UNION ALL 

(	SELECT '==>   Doula','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(

		SELECT 
          distinct  DRVD_ROWS.doula as 'Doula'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,doula
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                           	CASE
                                                                WHEN o.value_coded = 1 THEN 'Yes'
                                                                WHEN o.value_coded = 2 THEN 'No'
                                                                ELSE 'N/A'
                                                            END AS 'doula' 

                                                        from obs o
                                                                    -- Doula
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 5128 and o.value_coded IN (1,2)
                                                                    AND patient.voided = 0 AND o.voided = 0
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.doula
                        ORDER BY DRVD_ROWS.doula desc
)

UNION ALL 

(	SELECT '==>    Intrapartum Complications','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(

		SELECT 
          distinct  DRVD_ROWS.intrapartum_complications as 'Intrapartum Complications'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,intrapartum_complications
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                           CASE
                                                                WHEN o.value_coded = 4368 THEN 'No complications'
                                                                WHEN o.value_coded = 5131 THEN 'Prolonged rapture of membranes'
                                                                WHEN o.value_coded = 5132 THEN 'Prolonged labour'
                                                                WHEN o.value_coded = 926 THEN 'Obstructed labour'
                                                                WHEN o.value_coded = 5108 THEN 'Pregnanc Induced Hypertension'
                                                                WHEN o.value_coded = 5133 THEN 'Postpartum hemorrhage'
                                                                WHEN o.value_coded = 4374 THEN 'Malpresentation'
                                                                WHEN o.value_coded = 1958 THEN '3rd degree perineal laceration'
                                                                WHEN o.value_coded = 5134 THEN '4th degree pereneal laceration'
                                                                WHEN o.value_coded = 5135 THEN 'Retention of the placenta'
                                                                WHEN o.value_coded = 5136 THEN 'Abruption of the Placenta'
                                                                WHEN o.value_coded = 5137 THEN 'Placenta praevia'
                                                                WHEN o.value_coded = 4408 THEN 'Infection'
                                                                WHEN o.value_coded = 5138 THEN 'Rapture of the urerus'
                                                                WHEN o.value_coded = 1033 THEN 'Other'
                                                                ELSE 'N/A'
                                                            END AS 'intrapartum_complications' 

                                                        from obs o
                                                                   -- Postpartum complications
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 5130 and o.value_coded IN 
                                                                                        (
                                                                                            4368, 5134, 5132, 926, 
                                                                                            5108, 5133, 4374, 1958,
                                                                                            5134, 5135, 5136, 5137,
                                                                                            4408, 5138, 1033  
                                                                                        )
                                                                    AND patient.voided = 0 AND o.voided = 0
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.intrapartum_complications
                        ORDER BY DRVD_ROWS.intrapartum_complications desc
)

UNION ALL 

(	SELECT '==>   Intrapartum Interventions ','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(

		SELECT 
          distinct  DRVD_ROWS.intrapartum_inverventions as 'Intrapartum Interventions'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,intrapartum_inverventions
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                         	CASE
                                                                WHEN o.value_coded = 5140 THEN 'No complications'
                                                                WHEN o.value_coded = 1653 THEN 'Oxytocin'
                                                                WHEN o.value_coded = 1955 THEN 'Episiotomy on mother'
                                                                WHEN o.value_coded = 5141 THEN 'Repair of tears'
                                                                WHEN o.value_coded = 5142 THEN 'Manual removal of placenta'
                                                                WHEN o.value_coded = 1963 THEN 'Delivery Note, Blood transfusion provided'
                                                                WHEN o.value_coded = 5143 THEN 'AnitiD'
                                                                WHEN o.value_coded = 5144 THEN 'IV fluids'
                                                                WHEN o.value_coded = 5146 THEN 'Oxygen'
                                                                WHEN o.value_coded = 5147 THEN 'Vacuum extraction'
                                                                WHEN o.value_coded = 1033 THEN 'Other'
                                                                WHEN o.value_coded = 5145 THEN 'Antibiotics'
                                                                ELSE 'N/A'
                                                            END AS 'intrapartum_inverventions' 

                                                        from obs o
                                                                  
                                                                -- Postpartum INTERVENTIONS
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 5139 and o.value_coded IN 
                                                                                        (
                                                                                            5140, 1653, 1955, 5141, 5142,
                                                                                            1963, 5143, 5144, 5145, 5146, 5147,1033  
                                                                                        )
                                                                    AND patient.voided = 0 AND o.voided = 0
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.intrapartum_inverventions
                        ORDER BY DRVD_ROWS.intrapartum_inverventions desc
)

UNION ALL 

(	SELECT '==>   Live Births','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(

		SELECT 
          distinct  DRVD_ROWS.live_birth as 'Live Births'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,live_birth
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                         	CASE
                                                                WHEN o.value_numeric < 2500 THEN 'weight < 2500g' 
                                                                WHEN o.value_numeric >= 2500  THEN 'weight >= 2500g'
                                                                ELSE 'N/A'
                                                            END AS 'live_birth' 

                                                        from obs o
                                                                  
                                                                    -- LIVE BIRTHS WEIGHT							
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 5247
                                                                    AND patient.voided = 0 AND o.voided = 0
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.live_birth
                        ORDER BY DRVD_ROWS.live_birth desc
)

UNION ALL 

(	SELECT '==>   Child Sex','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(
		SELECT 
          distinct  DRVD_ROWS.child_sex as 'Sex'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,child_sex
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                         	CASE
                                                                WHEN o.value_coded = 1033  THEN 'Other'
                                                                WHEN o.value_coded = 1087 THEN 'Male' 
                                                                WHEN o.value_coded = 1088  THEN 'Female'
                                                                ELSE 'N/A'
                                                            END AS 'child_sex' 

                                                        from obs o
                                                                  
                                                                   -- CHILD SEX							
                                                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                                                    AND o.concept_id = 5236 and o.value_coded in (1087, 1088, 1033)
                                                                    AND patient.voided = 0 AND o.voided = 0
                                                                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                                    
                                                                    INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.child_sex
                        ORDER BY DRVD_ROWS.child_sex desc
)
UNION ALL 

(	SELECT '==>   Maternal Deaths','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(


		SELECT 
          distinct  DRVD_ROWS.Death as 'Death'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,Death
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                            CASE
                                                                WHEN o.value_coded = 5153  THEN 'Live/Maternal Death'
                                                                WHEN o.value_coded = 5154 THEN 'Fresh still birth' 
                                                                WHEN o.value_coded = 5155  THEN 'Macerated still birth'
                                                                ELSE 'N/A'
                                                            END AS 'Death' 

                                                        from obs o
                                                                  
                                                            -- MATERNAL CHILD DEATH							
                                                            INNER JOIN patient ON o.person_id = patient.patient_id 
                                                            AND o.concept_id = 5152 and o.value_coded in (5153, 5154, 5155)
                                                            AND patient.voided = 0 AND o.voided = 0
                                                            AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                            AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
                                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                            
                                                            INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.Death
                        ORDER BY DRVD_ROWS.Death desc
)

UNION ALL 

(	SELECT '==>   Newborn maturity','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(


		SELECT 
          distinct  DRVD_ROWS.Newborth_Maturity as 'Newborn maturity(excluding still birth)'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,Newborth_Maturity
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                          	CASE
                                                                WHEN o.value_coded = 4290  THEN 'Term'
                                                                WHEN o.value_coded = 4289 THEN 'Preterm' 
                                                                WHEN o.value_coded = 4291  THEN 'Post Term'
                                                                ELSE 'N/A'
                                                            END AS 'Newborth_Maturity' 

                                                        from obs o
                                                                  
                                                                -- NEWBORN MARTURITY							
                                                            INNER JOIN patient ON o.person_id = patient.patient_id 
                                                            AND o.concept_id = 5249 and o.value_coded in (4289, 4290, 4291)
                                                            AND patient.voided = 0 AND o.voided = 0
                                                            AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                            AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
                                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                            
                                                            INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.Newborth_Maturity
                        ORDER BY DRVD_ROWS.Newborth_Maturity desc
)
UNION ALL 

(	SELECT '==>   HIV Exposed Infants','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(	

		SELECT 
          distinct  DRVD_ROWS.HIE_Prophylaxis as 'HIV exposed infants'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,HIE_Prophylaxis
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                          	CASE
                                                                WHEN o.value_coded = 5261  THEN 'No prophylaxis given'
                                                                WHEN o.value_coded = 4261 THEN 'Nevirapine' 
                                                                WHEN o.value_coded = 5262  THEN 'NVP and AZT'
                                                                WHEN o.value_coded = 4321  THEN 'Declined'
                                                                WHEN o.value_coded = 5263  THEN 'HIV Negative mother/baby died'
                                                                ELSE 'N/A'
                                                            END AS 'HIE_Prophylaxis' 

                                                        from obs o
                                                                  
                                                          -- HIV EXPOSURE							
                                                            INNER JOIN patient ON o.person_id = patient.patient_id 
                                                            AND o.concept_id = 5260 and o.value_coded in (5261, 4261, 4321, 5262, 5263)
                                                            AND patient.voided = 0 AND o.voided = 0
                                                            AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                            AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
                                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                            
                                                            INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.HIE_Prophylaxis
                        ORDER BY DRVD_ROWS.HIE_Prophylaxis desc
)
UNION ALL 

(	SELECT '==>   Feeding Options','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(	

		SELECT 
          distinct  DRVD_ROWS.feeding_options as 'Feeding Options'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,feeding_options
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                          	CASE
                                                                WHEN o.value_coded = 4731  THEN 'Exclusice Breastfeeding'
                                                                WHEN o.value_coded = 4732 THEN 'Exclusive Replacement Feeding' 
                                                                WHEN o.value_coded = 4733  THEN 'Mixed Feeding'
                                                                WHEN o.value_coded = 1975  THEN 'Not Applicable'
                                                                ELSE 'N/A'
                                                            END AS 'feeding_options' 
                                                        from obs o
                                                                  
                                                          -- INFANT FEEDING OPTIONS							
                                                            INNER JOIN patient ON o.person_id = patient.patient_id 
                                                            AND o.concept_id = 5276 and o.value_coded in (4731, 4732, 4733, 1975)
                                                            AND patient.voided = 0 AND o.voided = 0
                                                            AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                            AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
                                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                            
                                                            INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.feeding_options
                        ORDER BY DRVD_ROWS.feeding_options desc	
)
UNION ALL 

(	SELECT '==>   Breast Feeding Initiation ','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(	
		SELECT 
          distinct  DRVD_ROWS.breast_feeding_initiation as 'Breast Feeding Initiation'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,breast_feeding_initiation
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                                                          	CASE
                                                                WHEN o.value_coded = 5282  THEN 'Within 1 hour'
                                                                WHEN o.value_coded = 5284 THEN 'More than 1 hour' 
                                                                WHEN o.value_coded = 1975  THEN 'Not Applicable'
                                                                ELSE 'N/A'
                                                            END AS 'breast_feeding_initiation' 
                                                        from obs o
                                                                  
                                                         -- INFANT FEEDING INITIATION							
                                                            INNER JOIN patient ON o.person_id = patient.patient_id 
                                                            AND o.concept_id = 5280 and o.value_coded in (5282, 5284, 1975)
                                                            AND patient.voided = 0 AND o.voided = 0
                                                            AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                            AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
                                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                            
                                                            INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
																		
						)DRVD_ROWS
						GROUP BY DRVD_ROWS.breast_feeding_initiation
                        ORDER BY DRVD_ROWS.breast_feeding_initiation desc	
)

UNION ALL 

(	SELECT '==>   Immunization','----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------' ,'----------------------------------------------'  FROM reporting_age_group limit 1)

UNION ALL

(	


		SELECT 
          distinct  DRVD_ROWS.Immunization as 'Immunization'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = 'Under 15yrs', 1, 0))) AS CHAR)AS 'Under 15 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '15-19yrs', 1, 0))) AS CHAR)AS '15-19 years' 
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '20-24yrs', 1, 0))) AS CHAR)AS '20-24 years'
                ,CAST(IF(DRVD_ROWS.Id IS NULL, 0, SUM(IF(DRVD_ROWS.age_group = '25+yrs', 1, 0))) AS CHAR)AS '25+ years' 
					
		
		FROM (
			SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender, sort_order,Immunization
								FROM
										(select distinct patient.patient_id AS Id,
															patient_identifier.identifier AS patientIdentifier,
															concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
															floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
															observed_age_group.name AS age_group,
															person.gender AS Gender,
															observed_age_group.sort_order AS sort_order,
                              CASE
                                WHEN o.value_coded = 4454  THEN 'Polio(OPV)'
                                WHEN o.value_coded = 4453 THEN 'BCG' 
                                WHEN o.value_coded = 5160  THEN 'BCG and Polio 0'
                                WHEN o.value_coded = 1975  THEN 'Not Applicable'
                                ELSE 'N/A'
                              END AS 'Immunization'  
                                                        from obs o
                                                                  
                                                        -- INFANT IMMUNIZATION							
                                                            INNER JOIN patient ON o.person_id = patient.patient_id 
                                                            AND o.concept_id = 5287 and o.value_coded in (4454, 4453, 5160, 1975)
                                                            AND patient.voided = 0 AND o.voided = 0
                                                            AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                                                            AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
                                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
                                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                                            
                                                            INNER JOIN reporting_age_group AS observed_age_group ON
												CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
										WHERE observed_age_group.report_group_name = 'Delivery_ages'
										) AS CLIENT_DELIVERY
			)DRVD_ROWS
						GROUP BY DRVD_ROWS.Immunization
            ORDER BY DRVD_ROWS.Immunization desc
)