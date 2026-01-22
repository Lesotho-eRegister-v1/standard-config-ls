SELECT Total_Aggregated_TBStatus.AgeGroup
		, Total_Aggregated_TBStatus.New_KnownNegMales
		, Total_Aggregated_TBStatus.New_KnownNegFemales
		, Total_Aggregated_TBStatus.New_KnownPosMales
		, Total_Aggregated_TBStatus.New_KnownPosFemales
		, Total_Aggregated_TBStatus.Relapsed_KnownNegMales
		, Total_Aggregated_TBStatus.Relapsed_KnownNegFemales
		, Total_Aggregated_TBStatus.Relapsed_KnownPosMales
		, Total_Aggregated_TBStatus.Relapsed_KnownPosFemales
		, Total_Aggregated_TBStatus.Total

FROM

(
	(SELECT TBStatus_DETAILS.age_group AS 'AgeGroup'
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(IF(TBStatus_DETAILS.TB_Treatment_History = 'New_Patient' AND TBStatus_DETAILS.HIV_STATUS ='Known_Negative' AND TBStatus_DETAILS.Gender ="M", 1, 0))) AS New_KnownNegMales
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(IF(TBStatus_DETAILS.TB_Treatment_History = 'New_Patient' AND TBStatus_DETAILS.HIV_STATUS ='Known_Negative' AND TBStatus_DETAILS.Gender ="F", 1, 0))) AS New_KnownNegFemales
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(IF(TBStatus_DETAILS.TB_Treatment_History = 'New_Patient' AND TBStatus_DETAILS.HIV_STATUS ='Known_Positive' AND TBStatus_DETAILS.Gender ="M", 1, 0))) AS New_KnownPosMales
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(IF(TBStatus_DETAILS.TB_Treatment_History = 'New_Patient' AND TBStatus_DETAILS.HIV_STATUS ='Known_Positive' AND TBStatus_DETAILS.Gender ="F", 1, 0))) AS New_KnownPosFemales
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(IF(TBStatus_DETAILS.TB_Treatment_History = 'Relapsed_Patient' AND TBStatus_DETAILS.HIV_STATUS ="Known_Negative" AND TBStatus_DETAILS.Gender ="M", 1, 0))) AS Relapsed_KnownNegMales
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(IF(TBStatus_DETAILS.TB_Treatment_History = 'Relapsed_Patient' AND TBStatus_DETAILS.HIV_STATUS ="Known_Negative" AND TBStatus_DETAILS.Gender ="F", 1, 0))) AS Relapsed_KnownNegFemales
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(IF(TBStatus_DETAILS.TB_Treatment_History = 'Relapsed_Patient' AND TBStatus_DETAILS.HIV_STATUS ="Known_Positive" AND TBStatus_DETAILS.Gender ="M", 1, 0))) AS Relapsed_KnownPosMales
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(IF(TBStatus_DETAILS.TB_Treatment_History = 'Relapsed_Patient' AND TBStatus_DETAILS.HIV_STATUS ="Known_Positive" AND TBStatus_DETAILS.Gender ="F", 1, 0))) AS Relapsed_KnownPosFemales
			, IF(TBStatus_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, TBStatus_DETAILS.sort_order
			
	FROM

	(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, TB_Treatment_History,HIV_STATUS,sort_order
							 
					FROM(
					
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											         	 
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														  "Known_Negative"as 'HIV_STATUS',
														   observed_age_group.sort_order AS sort_order,
														   case
														   when o.value_coded = 1034 then "New_Patient"
														   when o.value_coded = 1084 then "Relapsed_Patient"
														   else "N/A"
														   end as TB_Treatment_History
  
									from obs o

										   -- New_Patients TB
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											  AND o.concept_id = 3785

											  -- Known Negative HIV Status 
											   AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4666 and os.value_coded = 4324
												AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											    AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND os.voided = 0
											 )
											  AND patient.voided = 0 AND o.voided = 0
											  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											  AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									     WHERE observed_age_group.report_group_name = 'Modified_Ages') 
					UNION
					(
						select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											         	 
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   "Known_Positive" as HIV_STATUS,
														   observed_age_group.sort_order AS sort_order,
														   case
														   when o.value_coded = 1034 then "New_Patient"
														   when o.value_coded = 1084 then "Relapsed_Patient"
														   else "N/A"
														   end as TB_Treatment_History
  
									from obs o

										   -- New_Patients TB
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											  AND o.concept_id = 3785
											  AND patient.voided = 0 AND o.voided = 0
											  -- Known Positive HIV Status 
											   AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4666 and os.value_coded = 4323
												AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											    AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND os.voided = 0
											 )
											  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											  AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									     WHERE observed_age_group.report_group_name = 'Modified_Ages') 
					)AS HTSClients_HIV_STATUS
ORDER BY HTSClients_HIV_STATUS.Age

					) AS TBStatus_DETAILS

	GROUP BY TBStatus_DETAILS.age_group
	ORDER BY TBStatus_DETAILS.sort_order)
	
	
UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Treatment_History = 'New_Patient' AND Totals.HIV_STATUS ="Known_Negative" AND Totals.Gender = "M", 1, 0))) AS 'New_KnownNegMales'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Treatment_History = 'New_Patient' AND Totals.HIV_STATUS ="Known_Negative" AND Totals.Gender = "F", 1, 0))) AS 'New_KnownNegFemales'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Treatment_History = 'New_Patient' AND Totals.HIV_STATUS ="Known_Positive" AND Totals.Gender = "M", 1, 0))) AS 'New_KnownPosMales'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Treatment_History = 'New_Patient' AND Totals.HIV_STATUS ="Known_Positive" AND Totals.Gender = "F", 1, 0))) AS 'New_KnownPosFemales'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Treatment_History = 'Relapsed_Patient' AND Totals.HIV_STATUS ="Known_Negative" AND Totals.Gender = "M", 1, 0))) AS 'Relapsed_KnownNegMales'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Treatment_History = 'Relapsed_Patient' AND Totals.HIV_STATUS ="Known_Negative" AND Totals.Gender = "F", 1, 0))) AS 'Relapsed_KnownNegFemales'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Treatment_History = 'Relapsed_Patient' AND Totals.HIV_STATUS ="Known_Positive" AND Totals.Gender = "M", 1, 0))) AS 'Relapsed_KnownPosMales'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Treatment_History = 'Relapsed_Patient' AND Totals.HIV_STATUS ="Known_Positive" AND Totals.Gender = "F", 1, 0))) AS 'Relapsed_KnownPosFemales'
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_TBStatus.Id
					, Total_TBStatus.patientIdentifier AS "Patient Identifier"
					, Total_TBStatus.patientName AS "Patient Name"
					, Total_TBStatus.Age
					, Total_TBStatus.Gender
					,Total_TBStatus.TB_Treatment_History
					,Total_TBStatus.HIV_STATUS
				
				
		FROM

		(

		(SELECT Id,patientIdentifier, patientName , Age , Gender, age_group, " New_Patient"AS "TB_Treatment_History"," Known_Negative"AS "HIV_STATUS",sort_order
							 
					FROM
					
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											         	 
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   observed_age_group.sort_order AS sort_order
  
									from obs o

										   -- New_Patients TB
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											  AND o.concept_id = 3785 and o.value_coded = 1034
											  AND patient.voided = 0 AND o.voided = 0
											  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											  AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											
											 -- Known_Negative HIV Status 
											   AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4666 and os.value_coded = 4324
												AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											    AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND os.voided = 0
											 )
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									     WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_STATUS
					ORDER BY HTSClients_HIV_STATUS.Age)
UNION
(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, " New_Patient"AS "TB_Treatment_History"," Known_Positive"AS "HIV_STATUS",sort_order
							 
					FROM
					
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											         	 
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   observed_age_group.sort_order AS sort_order
  
									from obs o

										   -- New_Patients TB
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											  AND o.concept_id = 3785 and o.value_coded = 1034
											  AND patient.voided = 0 AND o.voided = 0
											  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											  AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											
											 -- Known_Positive HIV Status 
											   AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4666 and os.value_coded = 4323
												AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											  AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND os.voided = 0
											 )
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									     WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_STATUS
					ORDER BY HTSClients_HIV_STATUS.Age)
UNION
(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, " Relapsed_Patient"AS "TB_Treatment_History"," Known_Negative"AS "HIV_STATUS",sort_order
							 
					FROM
					
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											         	 
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   observed_age_group.sort_order AS sort_order
  
									from obs o

										   -- New and Relapse Patients TB
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											  AND o.concept_id = 3785 and o.value_coded = 1084
											  AND patient.voided = 0 AND o.voided = 0
											  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											  AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											
											 -- Known HIV Status 
											   AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4666 and os.value_coded = 4324
												AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											    AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND os.voided = 0
											 )
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									     WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_STATUS
					ORDER BY HTSClients_HIV_STATUS.Age)
UNION
(SELECT Id,patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, " Relapsed_Patient"AS "TB_Treatment_History"," Known_Positive"AS "HIV_STATUS",sort_order
							 
					FROM
					
									(select distinct patient.patient_id AS Id,
														   patient_identifier.identifier AS patientIdentifier,
														   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
														   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											         	 
														   person.gender AS Gender,
														   observed_age_group.name AS age_group,
														   observed_age_group.sort_order AS sort_order
  
									from obs o

										   -- Relapse Patients TB
											 INNER JOIN patient ON o.person_id = patient.patient_id 
											  AND o.concept_id = 3785 and o.value_coded = 1084
											  AND patient.voided = 0 AND o.voided = 0
											  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											  AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											
											 -- Known_Positive HIV Status 
											   AND o.person_id in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4666 and os.value_coded = 4323
												AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											  AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
												AND patient.voided = 0 AND os.voided = 0
											 )
											 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
											 INNER JOIN person_name ON person.person_id = person_name.person_id
											 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											 INNER JOIN reporting_age_group AS observed_age_group ON
											  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
											  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									     WHERE observed_age_group.report_group_name = 'Modified_Ages') AS HTSClients_HIV_STATUS
					ORDER BY HTSClients_HIV_STATUS.Age)



		) AS Total_TBStatus
  ) AS Totals
 )
) AS Total_Aggregated_TBStatus
ORDER BY Total_Aggregated_TBStatus.sort_order

