SELECT Total_Aggregated_TxCurr.AgeGroup
		, Total_Aggregated_TxCurr.Initiated_Males
		, Total_Aggregated_TxCurr.Initiated_Females
		, Total_Aggregated_TxCurr.Total

FROM

(
	(SELECT TXCURR_DETAILS.age_group AS 'AgeGroup'
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.Program_Status = 'TX_NEW' AND TXCURR_DETAILS.Gender = 'M', 1, 0))) AS Initiated_Males
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(IF(TXCURR_DETAILS.Program_Status = 'TX_NEW' AND TXCURR_DETAILS.Gender = 'F', 1, 0))) AS Initiated_Females
			, IF(TXCURR_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, TXCURR_DETAILS.sort_order
			
	FROM

	(
	
(SELECT Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Gender, age_group, 'TX_NEW' AS 'Program_Status',sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    	    AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
				
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') as newly_initiated
			
			)
	) AS TXCURR_DETAILS

	GROUP BY TXCURR_DETAILS.age_group
	ORDER BY TXCURR_DETAILS.sort_order)
	
	
UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'TX_NEW' AND Totals.Gender = 'M', 1, 0))) AS 'Initiated_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'TX_NEW' AND Totals.Gender = 'F', 1, 0))) AS 'Initiated_Females'
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_TxCurr.Id
					, Total_TxCurr.patientIdentifier AS "Patient Identifier"
					, Total_TxCurr.patientName AS "Patient Name"
					, Total_TxCurr.Age
					, Total_TxCurr.Gender
					, Total_TxCurr.Program_Status
				
		FROM

		(

		(SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, 'TX_NEW' AS 'Program_Status',sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    	    AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
				
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') as newly_initiated)
		) AS Total_TxCurr
  ) AS Totals
 )
) AS Total_Aggregated_TxCurr
ORDER BY Total_Aggregated_TxCurr.sort_order

