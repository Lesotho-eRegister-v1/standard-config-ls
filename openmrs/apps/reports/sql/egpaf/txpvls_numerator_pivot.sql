SELECT Total_Aggregated_TxPVLS.AgeGroup
		, Total_Aggregated_TxPVLS.Routine_Males
		, Total_Aggregated_TxPVLS.Routine_Females
		, Total_Aggregated_TxPVLS.Targeted_Males
		, Total_Aggregated_TxPVLS.Targeted_Females
		, Total_Aggregated_TxPVLS.Total

FROM (


	(SELECT TXPVLS_DETAILS.age_group AS 'AgeGroup'
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(IF(TXPVLS_DETAILS.Indication = 'Routine' AND TXPVLS_DETAILS.Gender = 'M', 1, 0))) AS Routine_Males
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(IF(TXPVLS_DETAILS.Indication = 'Routine' AND TXPVLS_DETAILS.Gender = 'F', 1, 0))) AS Routine_Females
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(IF(TXPVLS_DETAILS.Indication = 'Targeted' AND TXPVLS_DETAILS.Gender = 'M', 1, 0))) AS Targeted_Males
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(IF(TXPVLS_DETAILS.Indication = 'Targeted' AND TXPVLS_DETAILS.Gender = 'F', 1, 0))) AS Targeted_Females
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, TXPVLS_DETAILS.sort_order
	 FROM (
				select Id, patientIdentifier, patientName, Age, Gender, age_group, VL_Result, Indication, encounter_date, sort_order
				from 
					(select distinct o.person_id AS Id,
										patient_identifier.identifier AS patientIdentifier,
										concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
										person.gender AS Gender,
										observed_age_group.name AS age_group,
										IF(latest_vl_result = 4264, 'LessThan20', IF(latest_vl_result = 4263, 'Undetectable', latest_numeric_vl_result)) AS VL_Result,
										IF(latest_indication_vl = 4281, 'Routine', 'Targeted') as Indication,
										cast(obs_vl_latest.max_observation as DATE) as encounter_date,
										observed_age_group.sort_order AS sort_order

					from obs o 
						INNER JOIN
						(
							select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS latest_vl_result
							from obs oss
							where oss.concept_id = 4266 and oss.voided=0
							and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
							group by oss.person_id
						) as obs_vl_latest on o.person_id = obs_vl_latest.person_id
						INNER JOIN
						(
							select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS latest_indication_vl
							from obs oss
							where oss.concept_id = 4280 and oss.voided=0
							and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
							group by oss.person_id
						) as obs_routine_latest_vl on o.person_id = obs_routine_latest_vl.person_id
						LEFT JOIN
						(
							select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) AS latest_numeric_vl_result
							from obs oss
							where oss.concept_id = 2254 and oss.voided=0
							and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
							group by oss.person_id
							having latest_numeric_vl_result < 1000
						) as obs_vl_numeric_latest on o.person_id = obs_vl_numeric_latest.person_id	
						INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
							CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
					WHERE observed_age_group.report_group_name = 'Modified_Ages') as suppressed_vl_results
				where VL_Result is not null
				group by Id
	) AS TXPVLS_DETAILS
	GROUP BY TXPVLS_DETAILS.age_group
	ORDER BY TXPVLS_DETAILS.sort_order)
	
	
	UNION ALL


	(SELECT 'Total' AS AgeGroup
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(IF(TXPVLS_TOTALS.Indication = 'Routine' AND TXPVLS_TOTALS.Gender = 'M', 1, 0))) AS 'Routine_Males'
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(IF(TXPVLS_TOTALS.Indication = 'Routine' AND TXPVLS_TOTALS.Gender = 'F', 1, 0))) AS 'Routine_Females'
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(IF(TXPVLS_TOTALS.Indication = 'Targeted' AND TXPVLS_TOTALS.Gender = 'M', 1, 0))) AS 'Targeted_Males'
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(IF(TXPVLS_TOTALS.Indication = 'Targeted' AND TXPVLS_TOTALS.Gender = 'F', 1, 0))) AS 'Targeted_Females'
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(1)) as 'Total'
			, 99 AS 'sort_order'
			
	 FROM (
				select Id, patientIdentifier, patientName, Age, Gender, age_group, VL_Result, Indication, encounter_date, sort_order
				from 
					(select distinct o.person_id AS Id,
										patient_identifier.identifier AS patientIdentifier,
										concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
										floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
										person.gender AS Gender,
										observed_age_group.name AS age_group,
										IF(latest_vl_result = 4264, 'LessThan20', IF(latest_vl_result = 4263, 'Undetectable', latest_numeric_vl_result)) AS VL_Result,
										IF(latest_indication_vl = 4281, 'Routine', 'Targeted') as Indication,
										cast(obs_vl_latest.max_observation as DATE) as encounter_date,
										observed_age_group.sort_order AS sort_order

					from obs o 
						INNER JOIN
						(
							select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS latest_vl_result
							from obs oss
							where oss.concept_id = 4266 and oss.voided=0
							and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
							group by oss.person_id
						) as obs_vl_latest on o.person_id = obs_vl_latest.person_id
						INNER JOIN
						(
							select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS latest_indication_vl
							from obs oss
							where oss.concept_id = 4280 and oss.voided=0
							and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
							group by oss.person_id
						) as obs_routine_latest_vl on o.person_id = obs_routine_latest_vl.person_id
						LEFT JOIN
						(
							select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_numeric)), 20) AS latest_numeric_vl_result
							from obs oss
							where oss.concept_id = 2254 and oss.voided=0
							and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
							group by oss.person_id
							having latest_numeric_vl_result < 1000
						) as obs_vl_numeric_latest on o.person_id = obs_vl_numeric_latest.person_id	
						INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
							CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
					WHERE observed_age_group.report_group_name = 'Modified_Ages') as suppressed_vl_results
				where VL_Result is not null
				group by Id
	  ) AS TXPVLS_TOTALS)
) AS Total_Aggregated_TxPVLS
ORDER BY Total_Aggregated_TxPVLS.sort_order