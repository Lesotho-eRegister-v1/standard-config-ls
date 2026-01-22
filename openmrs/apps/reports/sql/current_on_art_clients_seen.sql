SELECT Total_ART_Clients.AgeGroup as 'Age Group', Total_ART_Clients.Male, Total_ART_Clients.Female, Total_ART_Clients.Total

FROM
(

	(SELECT ART_Clients_Seen.age_group AS 'AgeGroup',
			   IF(ART_Clients_Seen.patient_id IS NULL, 0, SUM(IF(ART_Clients_Seen.patient_gender = 'M', 1, 0))) as 'Male',
			   IF(ART_Clients_Seen.patient_id IS NULL, 0, SUM(IF(ART_Clients_Seen.patient_gender = 'F', 1, 0))) as 'Female',
			   IF(ART_Clients_Seen.patient_id IS NULL, 0, SUM(1)) as 'Total',
			   ART_Clients_Seen.sort_order

	FROM
					(select distinct patient.patient_id,
									 observed_age_group.name AS age_group,
									 observed_age_group.id as age_group_id,
									 o.obs_datetime AS obs_datetime,
									 person.gender AS patient_gender,
									 observed_age_group.sort_order AS sort_order

					from obs o
									INNER JOIN patient ON o.person_id = patient.patient_id
									AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
									AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
									AND o.location_id in (19) AND patient.voided = 0 AND o.voided = 0
									INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
									INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.preferred = 1
									RIGHT OUTER JOIN reporting_age_group AS observed_age_group ON
									DATE(o.obs_datetime) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))                                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
					WHERE observed_age_group.report_group_name = 'HIV_ages') AS ART_Clients_Seen
	GROUP BY ART_Clients_Seen.age_group
	ORDER BY ART_Clients_Seen.sort_order)

	UNION ALL

	(SELECT 'Total' as 'AgeGroup',
					IF(Total_clients_seen.patient_id IS NULL, 0, SUM(IF(Total_clients_seen.patient_gender = 'M', 1, 0))) as 'Male',
					IF(Total_clients_seen.patient_id IS NULL, 0, SUM(IF(Total_clients_seen.patient_gender = 'F', 1, 0))) as 'Female',
					IF(Total_clients_seen.patient_id IS NULL, 0, SUM(1)) as 'Total',
					99 as 'sort_order'

	FROM
					(select distinct patient.patient_id,
													 person.gender AS patient_gender

									from obs o
																	 INNER JOIN patient ON o.person_id = patient.patient_id
																	 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
																	 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
																	 AND patient.voided = 0 AND o.voided = 0
																	 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0

					) AS Total_clients_seen)
) AS Total_ART_Clients
ORDER BY Total_ART_Clients.sort_order;
