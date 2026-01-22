SELECT Total_Aggregated_TxPVLS.AgeGroup
		, Total_Aggregated_TxPVLS.CD4_Below_200_Males
		, Total_Aggregated_TxPVLS.CD4_Below_200_Females
		, Total_Aggregated_TxPVLS.CD4_Above_200_Males
		, Total_Aggregated_TxPVLS.CD4_Above_200_Females		
		, Total_Aggregated_TxPVLS.Total

FROM (


	(SELECT TXPVLS_DETAILS.age_group AS 'AgeGroup'
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(IF(TXPVLS_DETAILS.CD4_Result < 200 AND TXPVLS_DETAILS.Gender = 'M', 1, 0))) AS CD4_Below_200_Males
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(IF(TXPVLS_DETAILS.CD4_Result < 200 AND TXPVLS_DETAILS.Gender = 'F', 1, 0))) AS CD4_Below_200_Females
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(IF(TXPVLS_DETAILS.CD4_Result >= 200 AND TXPVLS_DETAILS.Gender = 'M', 1, 0))) AS CD4_Above_200_Males
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(IF(TXPVLS_DETAILS.CD4_Result >= 200 AND TXPVLS_DETAILS.Gender = 'F', 1, 0))) AS CD4_Above_200_Females			
			, IF(TXPVLS_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, TXPVLS_DETAILS.sort_order
	 FROM (
				select distinct o.person_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   latest_numeric_cd4_result AS CD4_Result,
									   observed_age_group.sort_order AS sort_order

				from obs o 
					INNER JOIN
					(
						select oss.person_id, oss.obs_datetime, oss.value_numeric AS latest_numeric_cd4_result
						from obs oss
						where oss.concept_id = 1187 and oss.voided=0
						and oss.obs_datetime BETWEEN cast('#startDate#' as date) AND cast(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY) as date)
						group by oss.person_id
					) as obs_cd4_numeric_latest on o.person_id = obs_cd4_numeric_latest.person_id and o.obs_datetime = obs_cd4_numeric_latest.obs_datetime
					INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
					INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				WHERE observed_age_group.report_group_name = 'Modified_Ages'
				GROUP BY o.person_id
	) AS TXPVLS_DETAILS
	GROUP BY TXPVLS_DETAILS.age_group
	ORDER BY TXPVLS_DETAILS.sort_order)
	
	
	UNION ALL


	(SELECT 'Total' AS AgeGroup
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(IF(TXPVLS_TOTALS.CD4_Result < 200 AND TXPVLS_TOTALS.Gender = 'M', 1, 0))) AS CD4_Below_200_Males
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(IF(TXPVLS_TOTALS.CD4_Result < 200 AND TXPVLS_TOTALS.Gender = 'F', 1, 0))) AS CD4_Below_200_Females
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(IF(TXPVLS_TOTALS.CD4_Result >= 200 AND TXPVLS_TOTALS.Gender = 'M', 1, 0))) AS CD4_Above_200_Males
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(IF(TXPVLS_TOTALS.CD4_Result >= 200 AND TXPVLS_TOTALS.Gender = 'F', 1, 0))) AS CD4_Above_200_Females	
			, IF(TXPVLS_TOTALS.Id IS NULL, 0, SUM(1)) as 'Total'
			, 99 AS 'sort_order'
			
	 FROM (
				select distinct o.person_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   latest_numeric_cd4_result AS CD4_Result,
									   observed_age_group.sort_order AS sort_order

				from obs o 
					INNER JOIN
					(
						select oss.person_id, oss.obs_datetime, oss.value_numeric AS latest_numeric_cd4_result
						from obs oss
						where oss.concept_id = 1187 and oss.voided=0
						and oss.obs_datetime BETWEEN cast('#startDate#' as date) AND cast(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL 1 DAY) as date)
						group by oss.person_id
					) as obs_cd4_numeric_latest on o.person_id = obs_cd4_numeric_latest.person_id and o.obs_datetime = obs_cd4_numeric_latest.obs_datetime
					INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
					INNER JOIN person_name ON person.person_id = person_name.person_id
					INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
					INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
				WHERE observed_age_group.report_group_name = 'Modified_Ages'
				GROUP BY o.person_id
	  ) AS TXPVLS_TOTALS)
) AS Total_Aggregated_TxPVLS
ORDER BY Total_Aggregated_TxPVLS.sort_order