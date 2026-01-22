	(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age , Gender, age_group, TB_Treatment_History,HIV_STATUS
							 
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

					)