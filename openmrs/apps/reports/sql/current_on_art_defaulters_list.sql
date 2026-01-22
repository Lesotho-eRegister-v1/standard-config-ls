SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, HIV_Age_Group, App_Status

FROM
	(
		SELECT distinct patient.patient_id AS Id,
						   patient_identifier.identifier AS patientIdentifier,
						   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						   person.gender AS Gender,
						   observed_age_group.name AS HIV_Age_Group,
						   'Defaulted' AS App_Status
		FROM obs o 
					INNER JOIN patient ON o.person_id = patient.patient_id and o.concept_id = 3752 and o.value_datetime in 
						  (select max(value_datetime) from obs os
							where os.concept_id = 3752
							group by os.person_id
							having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 7 and datediff(CAST('#endDate#' AS DATE), max(value_datetime)) < 90)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.preferred = 1
					 INNER JOIN reporting_age_group AS observed_age_group ON
													  DATE(o.obs_datetime) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
													  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
			   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Patient_MissedAppointments

ORDER BY Patient_MissedAppointments.Age;
