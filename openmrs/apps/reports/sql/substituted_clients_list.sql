SELECT Patient_Identifier, Patient_Name, Age, Gender, age_group
FROM (

		(SELECT patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, sort_order
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
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 
								) AS substituted
								ORDER BY substituted.Age)

) AS substituted_clients

ORDER BY substituted_clients.sort_order
			, substituted_clients.Gender
