SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, HIV_Age_Group
FROM
	(select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS HIV_Age_Group

	from obs o
			 INNER JOIN patient ON o.person_id = patient.patient_id AND (o.concept_id = 2165 AND o.value_coded = 1738 AND DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
			 AND  o.location_id in (105, 106) AND patient.voided = 0 AND o.voided = 0
			 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
			 INNER JOIN person_name ON person.person_id = person_name.person_id
			 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.preferred = 1
			 INNER JOIN reporting_age_group AS observed_age_group ON
					  DATE(o.obs_datetime) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
					  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
	   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age;
