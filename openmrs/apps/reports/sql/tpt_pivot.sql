SELECT age_group as 'AgeGroup',
IF(tpt_clients.Id IS NULL, 0, SUM(IF(Program_Status = 'TPT_Started' AND Sex = 'M', 1, 0))) AS TPT_Started_Males,
IF(tpt_clients.Id IS NULL, 0, SUM(IF(Program_Status = 'TPT_Started' AND Sex = 'F', 1, 0))) AS TPT_Started_Females,
IF(tpt_clients.Id IS NULL, 0, SUM(IF(Program_Status = 'TPT_Completed' AND Sex = 'M', 1, 0))) AS TPT_Completed_Males,
IF(tpt_clients.Id IS NULL, 0, SUM(IF(Program_Status = 'TPT_Completed' AND Sex = 'F', 1, 0))) AS TPT_Completed_Females,
IF(tpt_clients.Id IS NULL, 0, SUM(1))as 'Total'
  -- ahd_clients.sort_order
FROM
(SELECT Id, Patient_Identifier, Patient_Name, Age, age_group, Sex, Program_Status
FROM(
(SELECT DISTINCT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Sex,'TPT_Started' AS 'Program_Status'

FROM
        (
			SELECT distinct 
							patient.patient_id AS Id,
							p.identifier AS patientIdentifier,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age,
							ps.gender AS Sex,
							observed_age_group.name AS age_group

					FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									INNER JOIN person ps ON ps.person_id = patient.patient_id AND ps.voided = 0
									INNER JOIN person_name pn ON ps.person_id = pn.person_id AND pn.preferred = 1
									INNER JOIN patient_identifier p ON p.patient_id = ps.person_id AND p.identifier_type = 3 AND p.preferred=1
									AND o.person_id in
									(				
										select distinct person_id from obs o
										where concept_id = 2227 and value_coded = 2146
										AND CAST(o.obs_datetime AS DATE) >= CAST('#endDate#' AS DATE)
										AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
										
										) 								
									AND o.voided = 0
									INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(ps.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(ps.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Clients_started
ORDER BY 2)

UNION

(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Sex,'TPT_Completed' AS 'Program_Status'

FROM
        
			(SELECT distinct 
							patient.patient_id AS Id,
							p.identifier AS patientIdentifier,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age,
							ps.gender AS Sex,
							observed_age_group.name AS age_group
							
							FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									INNER JOIN person ps ON ps.person_id = patient.patient_id AND ps.voided = 0
									INNER JOIN person_name pn ON ps.person_id = pn.person_id AND pn.preferred = 1
									INNER JOIN patient_identifier p ON p.patient_id = ps.person_id AND p.identifier_type = 3 AND p.preferred=1
									AND o.person_id in
									(				
												
										select distinct os.person_id
										from obs os
										where os.concept_id = 4821 
										AND CAST(os.value_datetime AS DATE) >= CAST('#endDate#' AS DATE)
										AND CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														
									)				
									AND o.voided = 0
									INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(ps.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(ps.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Clients_completed
ORDER BY 2))all_patients
)tpt_clients
GROUP by tpt_clients.age_group

UNION ALL

(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'TPT_Started' AND Totals.Sex = 'M', 1, 0))) AS 'TPT_Started_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'TPT_Started' AND Totals.Sex = 'F', 1, 0))) AS 'TPT_Started_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'TPT_Completed' AND Totals.Sex = 'M', 1, 0))) AS 'TPT_Completed_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'TPT_Completed' AND Totals.Sex = 'F', 1, 0))) AS 'TPT_Completed_Females'
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		
FROM

		(SELECT Id, Patient_Identifier, Patient_Name, Age, age_group, Sex, Program_Status
FROM(
(SELECT DISTINCT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Sex,'TPT_Started' AS 'Program_Status'

FROM
        (
			SELECT distinct 
							patient.patient_id AS Id,
							p.identifier AS patientIdentifier,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age,
							ps.gender AS Sex,
							observed_age_group.name AS age_group

					FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									INNER JOIN person ps ON ps.person_id = patient.patient_id AND ps.voided = 0
									INNER JOIN person_name pn ON ps.person_id = pn.person_id AND pn.preferred = 1
									INNER JOIN patient_identifier p ON p.patient_id = ps.person_id AND p.identifier_type = 3 AND p.preferred=1
									AND o.person_id in
									(				
										select distinct person_id from obs o
										where concept_id = 2227 and value_coded = 2146
										AND CAST(o.obs_datetime AS DATE) >= CAST('#endDate#' AS DATE)
										AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
										
										) 								
									AND o.voided = 0
									INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(ps.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(ps.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Clients_started
ORDER BY 2)

UNION

(SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Sex,'TPT_Completed' AS 'Program_Status'

FROM
        
			(SELECT distinct 
							patient.patient_id AS Id,
							p.identifier AS patientIdentifier,
							concat(pn.given_name, ' ', pn.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age,
							ps.gender AS Sex,
							observed_age_group.name AS age_group
							
							FROM obs o
			
									INNER JOIN patient ON o.person_id = patient.patient_id
									INNER JOIN person ps ON ps.person_id = patient.patient_id AND ps.voided = 0
									INNER JOIN person_name pn ON ps.person_id = pn.person_id AND pn.preferred = 1
									INNER JOIN patient_identifier p ON p.patient_id = ps.person_id AND p.identifier_type = 3 AND p.preferred=1
									AND o.person_id in
									(				
												
										select distinct os.person_id
										from obs os
										where os.concept_id = 4821 
										AND CAST(os.value_datetime AS DATE) >= CAST('#endDate#' AS DATE)
										AND CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														
									)				
									AND o.voided = 0
									INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(ps.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(ps.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Clients_completed
ORDER BY 2))all_patients
)Totals
)


