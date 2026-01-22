(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Linked' AS 'Linkage Status', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND o.concept_id = 2165 AND o.value_coded = 1738
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT LINKED TO CARE
						 AND o.person_id in (
							select distinct os.person_id 
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2146
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_Status
ORDER BY HTSClients_HIV_Status.Age)

UNION

(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Not Linked' AS 'Linkage Status', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND o.concept_id = 2165 AND o.value_coded = 1738
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT NOT LINKED TO CARE
						 AND o.person_id in (
							select distinct os.person_id 
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2147
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_Status
ORDER BY HTSClients_HIV_Status.Age)

UNION

(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Referred' AS 'Linkage Status', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND o.concept_id = 2165 AND o.value_coded = 1738
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT REFERRED TO OTHER FACILITY
						 AND o.person_id in (
							select distinct os.person_id 
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2922
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_Status
ORDER BY HTSClients_HIV_Status.Age)
