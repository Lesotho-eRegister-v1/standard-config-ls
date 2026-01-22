select distinct o.person_id AS Id,
					   patient_identifier.identifier AS patientIdentifier,
					   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
					   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
					   person.gender AS Gender,
					   observed_age_group.name AS age_group,
					   IF(latest_vl_result = 4264, 'LessThan20', IF(latest_vl_result = 4263, 'Undetectable', latest_numeric_vl_result)) AS VL_Result,
					   cast(o.obs_datetime as DATE) as encounter_date,
					   observed_age_group.sort_order AS sort_order

from obs o 
	INNER JOIN
	(
		select oss.person_id, oss.obs_datetime, oss.value_coded AS latest_vl_result
		from obs oss
		where oss.concept_id = 4266 and oss.voided=0
		and oss.obs_datetime BETWEEN cast('#startDate#' as date) AND cast(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY) as date)
		group by oss.person_id
	) as obs_vl_latest on o.person_id = obs_vl_latest.person_id and o.obs_datetime = obs_vl_latest.obs_datetime
	LEFT JOIN
	(
		select oss.person_id, oss.obs_datetime, oss.value_numeric AS latest_numeric_vl_result
		from obs oss
		where oss.concept_id = 2254 and oss.voided=0
		and oss.obs_datetime BETWEEN cast('#startDate#' as date) AND cast(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY) as date)
		group by oss.person_id
	) as obs_vl_numeric_latest on o.person_id = obs_vl_numeric_latest.person_id	and o.obs_datetime = obs_vl_numeric_latest.obs_datetime
	INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
	INNER JOIN person_name ON person.person_id = person_name.person_id
	INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
	INNER JOIN reporting_age_group AS observed_age_group ON
		CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
		AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
WHERE observed_age_group.report_group_name = 'Modified_Ages'
GROUP BY o.person_id