(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1034 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3816
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1034
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic test", "Rifampicin_resistance" as "GeneXpert results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1034 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin resistance
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3817
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1034
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)

		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility_Intermediate" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1034 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility intermediate
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3818
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1034
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)

		UNION ALL


	(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1084 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3816
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1084
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic test", "Rifampicin_resistance" as "GeneXpert results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1084 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin resistance
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3817
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1084
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)

		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility_Intermediate" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1084 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility intermediate
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3818
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1084
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)

		UNION ALL

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1037 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3816
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1037
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic test", "Rifampicin_resistance" as "GeneXpert results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1037 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin resistance
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3817
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1037
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)


														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)

		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Restarted On FirstLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility_Intermediate" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1037 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Restarted On FirstLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3807
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility intermediate
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3818
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1037
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)


														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION ALL

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1034 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3816
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1034
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)


														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic test", "Rifampicin_resistance" as "GeneXpert results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1034 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin resistance
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3817
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1034
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)

		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility_Intermediate" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1034 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility intermediate
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3818
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1034
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION ALL
		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1084 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3816
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1084
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic test", "Rifampicin_resistance" as "GeneXpert results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1084 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin resistance
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3817
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1084
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)

		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility_Intermediate" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1084 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility intermediate
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3818
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1084
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION ALL
		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1037 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3816
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1037
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)

														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)
		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic test", "Rifampicin_resistance" as "GeneXpert results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1037 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin resistance
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3817
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1037
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)


														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)

		UNION

		(Select patientIdentifier as "Patient Identifier", patientName as "Patient Name", Age, age_group as "Age_Group", Gender, HistoryOfTreatment, "Started On SecondLine" as "Actions Taken For Treatment Failures", "GeneXpert" as "Genotypic Test", "Rifampicin_Susceptibility_Intermediate" as "GeneXpert Results", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1037 and concept_name_type='FULLY_SPECIFIED') AS HistoryOfTreatment,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- Action taken for treatment Failures (Started On SecondLine Drugs)
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3806  and o.value_coded = 3808
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- Rifampicin susceptibility intermediate
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3787 and os.value_coded = 3818
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 3785 and os.value_coded = 1037
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)


														
						Group by o.person_id) As Treatment_History
						ORDER BY Treatment_History.Age)