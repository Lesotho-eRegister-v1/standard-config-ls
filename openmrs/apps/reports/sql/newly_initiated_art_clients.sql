SELECT Newly_Initiated_ART_Clients.age_group AS 'Age Group',
       IF(Newly_Initiated_ART_Clients.patient_id IS NULL, 0, SUM(IF(Newly_Initiated_ART_Clients.patient_gender = 'M', 1, 0))) as 'Males',
       IF(Newly_Initiated_ART_Clients.patient_id IS NULL, 0, SUM(IF(Newly_Initiated_ART_Clients.patient_gender = 'F', 1, 0))) as 'Females'
FROM
		(select distinct patient.patient_id,
							   observed_age_group.name AS age_group,
							   observed_age_group.id as age_group_id,
							   o.obs_datetime AS obs_datetime,
							   person.gender AS patient_gender,
							   observed_age_group.sort_order AS sort_order

		from obs o
				 INNER JOIN patient ON o.person_id = patient.patient_id AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				 AND o.location_id in (19, 22, 23, 24) AND patient.voided = 0 AND o.voided = 0 
				 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				 RIGHT OUTER JOIN reporting_age_group AS observed_age_group ON
												  DATE(o.obs_datetime) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
												  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
		   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
GROUP BY Newly_Initiated_ART_Clients.age_group
ORDER BY Newly_Initiated_ART_Clients.sort_order;
