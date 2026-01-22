SELECT CurrentonARTSeen_Prev1or2months.age_group AS 'Age Group',
       IF(CurrentonARTSeen_Prev1or2months.patient_id IS NULL, 0, SUM(IF(CurrentonARTSeen_Prev1or2months.patient_gender = 'M', 1, 0))) as 'Males',
       IF(CurrentonARTSeen_Prev1or2months.patient_id IS NULL, 0, SUM(IF(CurrentonARTSeen_Prev1or2months.patient_gender = 'F', 1, 0))) as 'Females'
	  
FROM	  
        (select distinct patient.patient_id,
					   observed_age_group.name AS age_group,
					   observed_age_group.id as age_group_id,
					   o.obs_datetime AS obs_datetime,
					   person.gender AS patient_gender,
					   observed_age_group.sort_order AS sort_order
        from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177)) AND o.location_id IN (105,106)
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 RIGHT OUTER JOIN reporting_age_group AS observed_age_group ON
                                                  DATE(o.obs_datetime) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'HIV_ages'

UNION

		select distinct patient.patient_id,
					   observed_age_group.name AS age_group,
					   observed_age_group.id as age_group_id,
					   o.obs_datetime AS obs_datetime,
					   person.gender AS patient_gender,
					   observed_age_group.sort_order AS sort_order
		from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) AND patient.voided = 0 AND o.voided = 0 AND o.concept_id = 4174 and o.value_coded = 4177 AND o.location_id IN (105,106)
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                 RIGHT OUTER JOIN reporting_age_group AS observed_age_group ON
                                                  DATE(o.obs_datetime) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                                  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'HIV_ages') AS CurrentonARTSeen_Prev1or2months
GROUP BY CurrentonARTSeen_Prev1or2months.age_group
ORDER BY CurrentonARTSeen_Prev1or2months.sort_order;
