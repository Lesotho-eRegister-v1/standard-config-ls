-- updated
SELECT TOTALS_COLS_ROWS.AgeGroup 
		, TOTALS_COLS_ROWS.Received

FROM (
 
(SELECT viral_load_clients_DRVD_rows.age_group AS 'AgeGroup'                  
						, IF(viral_load_clients_DRVD_rows.Id IS NULL, 0, SUM(IF(viral_load_clients_DRVD_rows.VL_Results_Status = 'Received' , 1, 0))) AS Received
						, viral_load_clients_DRVD_rows.sort_order
			FROM (  
				

-- CLIENTS WITH DETECTABLE VL
(SELECT DISTINCT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Received' AS 'VL_Results_Status', sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
                                               o.value_datetime AS Date_Specimen_Collected,
											   observed_age_group.sort_order AS sort_order

						from obs o

						      
                                 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4266
                                 AND patient.voided = 0 AND o.voided = 0

								--  CLients with with viral load results
								 AND o.person_id in (
                                    Select Id
                                    from(
                                    select Id, max_observation,latest_vl_result
                                    from
                                    (
                                        select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS latest_vl_result
                                        from obs oss
                                        where oss.concept_id = 4266 -- VL test result
                                        and oss.voided=0
                                        and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('#endDate#' as datetime), interval 1 day)
                                        group by oss.person_id
                                    )As VL_result

                                    UNION

                                    select Id, max_observation,latest_vl_result
                                    from(select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.concept_id)), 20) AS latest_vl_result
                                                    from obs oss
                                                    where oss.concept_id = 5485 and oss.voided=0 -- from DISA
                                                    and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('#endDate#' as datetime), interval 1 day)
                                                    and oss.value_numeric < 1000
                                                    group by oss.person_id

                                    ) As Lab_Copies

                                    UNION

                                    select Id, max_observation,latest_vl_result
                                    from(select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.concept_id)), 20) AS latest_vl_result
                                                    from obs oss
                                                    where oss.concept_id = 5489 and oss.voided=0 -- from DISA
                                                    and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('#endDate#' as datetime), interval 1 day)
                                                    group by oss.person_id

                                    ) As LDL
                                    )all_results
                                 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS viral_loadClients_status
		ORDER BY viral_loadClients_status.Age)  

) AS viral_load_clients_DRVD_rows

GROUP by viral_load_clients_DRVD_rows.age_group
ORDER BY viral_load_clients_DRVD_rows.sort_order)

UNION ALL

(SELECT 'Total Blood Results' AS 'AgeGroup'                                  
						, IF(viral_load_clients.Id IS NULL, 0, SUM(IF(viral_load_clients.VL_Results_Status = 'Received' , 1, 0))) AS Received 
						, 99 AS sort_order
			FROM (				

-- CLIENTS WITH DETECTABLE VL
(SELECT DISTINCT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Received' AS 'VL_Results_Status', sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
                                               o.value_datetime AS Date_Specimen_Collected,
											   observed_age_group.sort_order AS sort_order

						from obs o

						      
                                 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4266
                                 AND patient.voided = 0 AND o.voided = 0

								--  CLients with with viral load results
								 AND o.person_id in (
                                    Select Id
                                    from(
                                    select Id, max_observation,latest_vl_result
                                    from
                                    (
                                        select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS latest_vl_result
                                        from obs oss
                                        where oss.concept_id = 4266 -- VL test result
                                        and oss.voided=0
                                        and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('#endDate#' as datetime), interval 1 day)
                                        group by oss.person_id
                                    )As VL_result

                                    UNION

                                    select Id, max_observation,latest_vl_result
                                    from(select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.concept_id)), 20) AS latest_vl_result
                                                    from obs oss
                                                    where oss.concept_id = 5485 and oss.voided=0 -- from DISA
                                                    and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('#endDate#' as datetime), interval 1 day)
                                                    and oss.value_numeric < 1000
                                                    group by oss.person_id

                                    ) As Lab_Copies

                                    UNION

                                    select Id, max_observation,latest_vl_result
                                    from(select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.concept_id)), 20) AS latest_vl_result
                                                    from obs oss
                                                    where oss.concept_id = 5489 and oss.voided=0 -- from DISA
                                                    and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('#endDate#' as datetime), interval 1 day)
                                                    group by oss.person_id

                                    ) As LDL
                                    )all_results
                                 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS viral_loadClients_status
		ORDER BY viral_loadClients_status.Age )  
				
        ) AS viral_load_clients
    )

) AS TOTALS_COLS_ROWS

ORDER BY TOTALS_COLS_ROWS.sort_order
