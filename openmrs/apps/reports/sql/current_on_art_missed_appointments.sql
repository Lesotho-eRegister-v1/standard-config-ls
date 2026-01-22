SELECT Patient_MissedAppointments.age_group AS 'Age Group',
       IF(Patient_MissedAppointments.patient_id IS NULL, 0, SUM(IF(Patient_MissedAppointments.patient_gender = 'M', 1, 0))) as 'Male',
       IF(Patient_MissedAppointments.patient_id IS NULL, 0, SUM(IF(Patient_MissedAppointments.patient_gender = 'F', 1, 0))) as 'Female'

FROM
	(
		SELECT distinct patient.patient_id,
						   observed_age_group.name AS age_group,
						   observed_age_group.id as age_group_id,
						   o.obs_datetime AS obs_datetime,
						   person.gender AS patient_gender,
						   observed_age_group.sort_order AS sort_order
		FROM obs o 
					INNER JOIN patient ON o.person_id = patient.patient_id and o.concept_id = 3752 and o.value_datetime in 
						  (select max(value_datetime) from obs os
							where os.concept_id = 3752
							group by os.person_id
							having datediff(CAST('#endDate#' AS DATE), max(value_datetime)) > 0 and datediff(CAST('#endDate#' AS DATE), max(value_datetime)) <= 7)
					INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
					RIGHT OUTER JOIN reporting_age_group AS observed_age_group ON
									  DATE(o.obs_datetime) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
		
		WHERE observed_age_group.report_group_name = 'HIV_ages') AS Patient_MissedAppointments

GROUP BY Patient_MissedAppointments.age_group
ORDER BY Patient_MissedAppointments.sort_order
