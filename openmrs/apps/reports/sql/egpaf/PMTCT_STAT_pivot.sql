SELECT distinct HTS_TOTALS_COLS_ROWS.AgeGroup
		    , HTS_TOTALS_COLS_ROWS.Positives
	    	, HTS_TOTALS_COLS_ROWS.Negatives
			, HTS_TOTALS_COLS_ROWS.Known_Negatives
			, HTS_TOTALS_COLS_ROWS.Known_Positives
			, HTS_TOTALS_COLS_ROWS.Total

FROM (

			(SELECT HTS_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.Visit = 'first' AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Positive', 1, 0))) AS Positives
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.Visit = 'first' AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'Negative', 1, 0))) AS Negatives
							, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.Visit = 'first' AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'kn', 1, 0))) AS Known_Negatives
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.Visit = 'first' AND HTS_STATUS_DRVD_ROWS.HIV_Status = 'kp', 1, 0))) AS Known_Positives
					
						, IF(HTS_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_ROWS.Visit = 'first', 1, 0))) as 'Total'
						, HTS_STATUS_DRVD_ROWS.sort_order
			FROM (

					SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, age_group, HIV_Status, Visit, sort_order
FROM (

		(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status,Visit, sort_order
		FROM
						(select patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   "kp" as "HIV_Status",
											   "first" as "Visit",
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
								 -- HIV_Pos						 
							 AND o.person_id in (
											    select distinct os.person_id 
												from obs os
											    where os.concept_id=4427 

												AND value_coded=1738)
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_KNOWN_POS
								 Group by Id
		)
		UNION

			(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status,Visit, sort_order
		FROM
						(select  patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											  
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   "kn" as "HIV_Status",
											   "first" as "Visit",
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
								 -- HIV Neg							 
							 AND o.person_id in (
											    select distinct os.person_id 
												from obs os
											    where os.concept_id=4427 
												AND os.obs_group_id in (
												     select oss.obs_id 
													 from obs oss 
													 where oss.concept_id=4655
													 )
												AND value_coded=1016)
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_KNOWN_NEG
								 Group by Id
		)

		UNION
		
		
		(SELECT  Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status,Visit, sort_order
		FROM
						(select  patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											 
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   "Positive" as "HIV_Status",
											   "first" as "Visit",
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )

								 	-- TESTED Positive
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 1740 and os.value_coded = 1738
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_NEW_POS
								 Group by Id
		)
		
		
		UNION
		
		(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status,Visit, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											 
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   "Negative" as "HIV_Status",
											   "first" as "Visit",
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )

								 	-- TESTED NEGATIVE
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 1740 and os.value_coded = 1016
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_NEW_NEG
								 Group by Id
		)
		

) AS ANC_Status_Detailed




			) AS HTS_STATUS_DRVD_ROWS

			GROUP BY HTS_STATUS_DRVD_ROWS.age_group, HTS_STATUS_DRVD_ROWS.Gender
			ORDER BY HTS_STATUS_DRVD_ROWS.sort_order
			)
			
			
	 UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.Visit = 'first' AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Positive', 1, 0))) AS Positives
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.Visit = 'first' AND HTS_STATUS_DRVD_COLS.HIV_Status = 'Negative', 1, 0))) AS Negatives
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.Visit = 'first' AND HTS_STATUS_DRVD_COLS.HIV_Status = 'kn', 1, 0))) AS Known_Negatives
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.Visit = 'first' AND HTS_STATUS_DRVD_COLS.HIV_Status = 'kp', 1, 0))) AS Known_Positives
						, IF(HTS_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HTS_STATUS_DRVD_COLS.Visit = 'first', 1, 0))) as 'Total'
						, 99 AS sort_order
			FROM (

					SELECT distinct Id,Patient_Identifier, Patient_Name, Age, Gender, age_group, HIV_Status, Visit, sort_order
FROM (

		(SELECT distinct Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status,Visit, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											 
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   "kp" as "HIV_Status",
											   "first" as "Visit",
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
								 -- HIV Pos						 
							 AND o.person_id in (
											    select distinct os.person_id 
												from obs os
											    where os.concept_id=4427 
												
												AND value_coded=1738)
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_KNOWN_POS
								 Group by Id
		)
		UNION

			(SELECT distinct Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status,Visit, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											 
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   "kn" as "HIV_Status",
											   "first" as "Visit",
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
								 -- HIV Neg						 
							 AND o.person_id in (
											    select distinct os.person_id 
												from obs os
											    where os.concept_id=4427 
												AND os.obs_group_id in (
												     select oss.obs_id 
													 from obs oss 
													 where oss.concept_id=4655
													 )
												AND value_coded=1016)
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_KNOWN_NEG
								 Group by Id
		)

		UNION
		
		
		(SELECT distinct Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status,Visit, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											 
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   "Positive" as "HIV_Status",
											   "first" as "Visit",
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )

								 	-- TESTED Positive
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 1740 and os.value_coded = 1738
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_NEW_POS
								 Group by Id
		)
		
		
		UNION
		
		(SELECT distinct Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, HIV_Status,Visit, sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											 
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   "Negative" as "HIV_Status",
											   "first" as "Visit",
											   observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 
							 -- ANC FIRST VISIT
								 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id = 4658 and os.value_coded =  4659
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )

								 	-- TESTED NEGATIVE
								 AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 1740 and os.value_coded = 1016
									AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
									AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									AND patient.voided = 0 AND o.voided = 0
								 )
							 
							 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- Observations inside the ANC PROGRAM Form
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id = 4663
								 )) AS ANC_NEW_NEG
								 Group by Id
		)
		

) AS ANC_Status_Detailed



			) AS HTS_STATUS_DRVD_COLS
		)
		
	) AS HTS_TOTALS_COLS_ROWS
ORDER BY HTS_TOTALS_COLS_ROWS.sort_order

