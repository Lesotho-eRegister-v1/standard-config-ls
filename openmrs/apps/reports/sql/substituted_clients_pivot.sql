SELECT distinct substitute_COLS_ROWS.AgeGroup
            , substitute_COLS_ROWS.Gender
			, substitute_COLS_ROWS.Total

FROM (

			(SELECT substitute_DRVD_ROWS.age_group AS 'AgeGroup', substitute_DRVD_ROWS.Gender
						, IF(substitute_DRVD_ROWS.Id IS NULL, 0, SUM(IF(substitute_DRVD_ROWS.Treatment_substituted = 'substituted', 1, 0))) as 'Total'
						, substitute_DRVD_ROWS.sort_order
			FROM (

					(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'substituted' AS 'Treatment_substituted', sort_order
					FROM
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,						
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   observed_age_group.sort_order AS sort_order

								 from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND o.concept_id = 2273 and o.value_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)

								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 5
								INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages') AS substituted_clients
						
					
									   
					ORDER BY substituted_clients.Age
					)

			) AS substitute_DRVD_ROWS

			GROUP BY substitute_DRVD_ROWS.age_group, substitute_DRVD_ROWS.Gender
			ORDER BY substitute_DRVD_ROWS.sort_order
			)
		
			
	 UNION ALL

			(SELECT 'Total' AS 'AgeGroup', 'All' AS Gender
						, IF(substitute_DRVD_COLS.Id IS NULL, 0, SUM(IF(substitute_DRVD_COLS.Treatment_substituted = 'substituted', 1, 0))) as 'Total'
						, 99 AS sort_order
			FROM (

					(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", 'substituted' AS 'Treatment_substituted'
							
					FROM
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age
														   

								 from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND o.concept_id = 2273 and o.value_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)

								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 5
					  ) AS substituted_clients_Total
					)



			) AS substitute_DRVD_COLS
		)
		
	) AS substitute_COLS_ROWS
ORDER BY substitute_COLS_ROWS.sort_order

