Select distinct Id, patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, sort_order, TB_Status-- , TB_diagnosis, Diagnosis_Results
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- TB Screened Clients
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3710
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_SCREENING
                        
-- TB status
left outer join
	(
	select distinct person_id, value_coded as Status_Code
	    from obs o
        where o.concept_id = 3710 and o.voided = 0
        AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	)Status
    inner join
	(
		select concept_id, name AS TB_Status
			from concept_name 
				where name in ('No signs', 'Suspected / Probable', 'On TB Treatment')
                
	) concept_name
	on concept_name.concept_id = Status.Status_Code 

    on Status.person_id = TB_SCREENING.Id 