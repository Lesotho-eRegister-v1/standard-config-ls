SELECT AHD_TOTALS_COLS_ROWS.AgeGroup
		, AHD_TOTALS_COLS_ROWS.Gender
		, AHD_TOTALS_COLS_ROWS.Positive_CrAg_Started_Preemptive_Fluc
		, AHD_TOTALS_COLS_ROWS.Negative_CrAg_Started_Preemptive_Fluc
		, AHD_TOTALS_COLS_ROWS.Positive_CrAg_Started_Crypto_Men
		, AHD_TOTALS_COLS_ROWS.Negative_CrAg_Started_Crypto_Men

FROM (

			(SELECT AHD_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					, AHD_STATUS_DRVD_ROWS.Gender
						, IF(AHD_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(AHD_STATUS_DRVD_ROWS.Fluconazole_Preemptive_Treatment = 'Started' 
							AND AHD_STATUS_DRVD_ROWS.CrAg_Test = 'Positive', 1, 0))) AS Positive_CrAg_Started_Preemptive_Fluc
						, IF(AHD_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(AHD_STATUS_DRVD_ROWS.Fluconazole_Preemptive_Treatment = 'Started'			
							AND AHD_STATUS_DRVD_ROWS.CrAg_Test = 'Negative', 1, 0))) AS Negative_CrAg_Started_Preemptive_Fluc
						, IF(AHD_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(AHD_STATUS_DRVD_ROWS.CrAg_Test = 'Positive' AND AHD_STATUS_DRVD_ROWS.Cryptoccocal_Meningitis_Treatment = 'Repeat', 1, 0))) AS Positive_CrAg_Started_Crypto_Men				
						, IF(AHD_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(AHD_STATUS_DRVD_ROWS.CrAg_Test = 'Negative' AND AHD_STATUS_DRVD_ROWS.Cryptoccocal_Meningitis_Treatment = 'Repeat', 1, 0))) AS Negative_CrAg_Started_Crypto_Men
						, AHD_STATUS_DRVD_ROWS.sort_order
			FROM (

					Select Id, Patient_Identifier, ART_Number, Patient_Name, Age, Age_Group, Gender, CrAg_Test, Fluconazole_Preemptive_Treatment, Cryptoccocal_Meningitis_Treatment, sort_order
from(
		(Select Id,patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Started" as "Fluconazole_Preemptive_Treatment", "Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with positive CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1738
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2146
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded = 4954
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION
		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Started" as "Fluconazole_Preemptive_Treatment", "Not Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with positive CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1738
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2146
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD Not started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded in (4955,4956)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Started" as "Fluconazole_Preemptive_Treatment", "Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
			From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with negative CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1016
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2146
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded = 4954
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)

		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Started" as "Fluconazole_Preemptive_Treatment", "Not Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
			From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with negative CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1016
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2146
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD Not started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded in (4955,4956)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Not Started" as "Fluconazole_Preemptive_Treatment", "Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
			From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with positive CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1738
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD Not started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2147
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded = 4954
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Not Started" as "Fluconazole_Preemptive_Treatment", "Not Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
			From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with positive CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1738
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD Not started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2147
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD Not started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded in (4955,4956)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Not Started" as "Fluconazole_Preemptive_Treatment", "Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with negative CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1016
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD Not started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2147
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded = 4954
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Not Started" as "Fluconazole_Preemptive_Treatment", "Not Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with negative CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1016
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD Not started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2147
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD Not started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded in (4955,4956)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
) As AHD_Status_Detailed
ORDER BY AHD_Status_Detailed.Fluconazole_Preemptive_Treatment
			, AHD_Status_Detailed.Cryptoccocal_Meningitis_Treatment
			, AHD_Status_Detailed.Gender
			, AHD_Status_Detailed.CrAg_Test


			) AS AHD_STATUS_DRVD_ROWS

			GROUP BY AHD_STATUS_DRVD_ROWS.age_group, AHD_STATUS_DRVD_ROWS.Gender
			ORDER BY AHD_STATUS_DRVD_ROWS.sort_order)
			
			
	UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					, 'All' AS 'Gender'
						, IF(AHD_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(AHD_STATUS_DRVD_COLS.Fluconazole_Preemptive_Treatment = 'Started' 
							AND AHD_STATUS_DRVD_COLS.CrAg_Test = 'Positive', 1, 0))) AS Positive_CrAg_Started_Preemptive_Fluc
						, IF(AHD_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(AHD_STATUS_DRVD_COLS.Fluconazole_Preemptive_Treatment = 'Started'			
							AND AHD_STATUS_DRVD_COLS.CrAg_Test = 'Negative', 1, 0))) AS Negative_CrAg_Started_Preemptive_Fluc
						, IF(AHD_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(AHD_STATUS_DRVD_COLS.CrAg_Test = 'Positive' AND AHD_STATUS_DRVD_COLS.Cryptoccocal_Meningitis_Treatment = 'Repeat', 1, 0))) AS Positive_CrAg_Started_Crypto_Men				
						, IF(AHD_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(AHD_STATUS_DRVD_COLS.CrAg_Test = 'Negative' AND AHD_STATUS_DRVD_COLS.Cryptoccocal_Meningitis_Treatment = 'Repeat', 1, 0))) AS Negative_CrAg_Started_Crypto_Men
						, 99 AS sort_order
			FROM (

					Select Id, Patient_Identifier, ART_Number, Patient_Name, Age, Age_Group, Gender, CrAg_Test, Fluconazole_Preemptive_Treatment, Cryptoccocal_Meningitis_Treatment,sort_order
from(
		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Started" as "Fluconazole_Preemptive_Treatment", "Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with positive CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1738
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2146
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded = 4954
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION
		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Started" as "Fluconazole_Preemptive_Treatment", "Not Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with positive CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1738
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2146
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD Not started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded in (4955,4956)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Started" as "Fluconazole_Preemptive_Treatment", "Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
			From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with negative CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1016
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2146
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded = 4954
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)

		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Started" as "Fluconazole_Preemptive_Treatment", "Not Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
			From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with negative CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1016
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2146
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD Not started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded in (4955,4956)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Not Started" as "Fluconazole_Preemptive_Treatment", "Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
			From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with positive CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1738
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD Not started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2147
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded = 4954
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Not Started" as "Fluconazole_Preemptive_Treatment", "Not Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
			From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1738 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with positive CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1738
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD Not started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2147
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD Not started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded in (4955,4956)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Not Started" as "Fluconazole_Preemptive_Treatment", "Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with negative CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1016
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD Not started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2147
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded = 4954
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
		UNION

		(Select Id, patientIdentifier as "Patient_Identifier", ART_Number, patientName as "Patient_Name", Age, age_group as "Age_Group", Gender, CrAg_Test, "Not Started" as "Fluconazole_Preemptive_Treatment", "Not Started" as "Cryptoccocal_Meningitis_Treatment", sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						(select name from concept_name cn where cn.concept_id = 1016 and concept_name_type='FULLY_SPECIFIED') AS CrAg_Test,
						observed_age_group.sort_order AS sort_order 
					from obs o
					-- AHD with negative CrAg test
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4939  and o.value_coded = 1016
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						AND patient.voided = 0 AND o.voided = 0
						-- AHD Not started on fluconazole preemptive treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4941 and os.value_coded = 2147
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						-- AHD Not started on Cryptoccocal Meningitis treatment
						AND o.person_id in (
											select distinct os.person_id
											from obs os
											where os.concept_id = 4953 and os.value_coded in (4955,4956)
											AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											AND patient.voided = 0 AND os.voided = 0
										)
						Group by o.person_id) As AHD_Clients_CrAg_Status
						ORDER BY AHD_Clients_CrAg_Status.CrAg_Test, AHD_Clients_CrAg_Status.Age)
) As AHD_Status_Detailed
ORDER BY AHD_Status_Detailed.Fluconazole_Preemptive_Treatment
			, AHD_Status_Detailed.Cryptoccocal_Meningitis_Treatment
			, AHD_Status_Detailed.Gender
			, AHD_Status_Detailed.CrAg_Test

			) AS AHD_STATUS_DRVD_COLS
		)
		
	) AS AHD_TOTALS_COLS_ROWS
ORDER BY AHD_TOTALS_COLS_ROWS.sort_order

