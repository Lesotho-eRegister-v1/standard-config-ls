SELECT TotalPatientAppointmentStatus.AgeGroup
		, TotalPatientAppointmentStatus.MIssedWithin28days_Males
		, TotalPatientAppointmentStatus.MIssedWithin28days_Females
		, TotalPatientAppointmentStatus.Total
FROM 

(

(SELECT PatientAppointmentStatus.age_group AS 'AgeGroup'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'MIssedWithin28days' AND PatientAppointmentStatus.Gender = 'M', 1, 0))) AS 'MIssedWithin28days_Males'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'MIssedWithin28days' AND PatientAppointmentStatus.Gender = 'F', 1, 0))) AS 'MIssedWithin28days_Females'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(1)) as 'Total'
		, PatientAppointmentStatus.sort_order
FROM

(SELECT  Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, age_group, Gender, App_Status, sort_order

FROM
        (
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						'MIssedWithin28days' AS App_Status,
						observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (

						  -- Latest followup date from the lastest followup form, exclude voided followup date
						select active_clients.person_id
								from
								(  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 0
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <= 28
				
				
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
                                    AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
						
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where concept_id = 2249
                                    AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )

		                        and active_clients.person_id not in (
							
							        -- TOUTS
                                   select tout_clients.person_id
										from
										(select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
											from obs B
											inner join
											(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 2403
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as A
											on A.observation_id = B.obs_group_id
											where concept_id = 2398
											and A.observation_id = B.obs_group_id
											and voided = 0
											group by B.person_id
										) as tout_clients
										where tout_clients.latest_consultation < cast('#endDate#' as date)
                                                
                                                )
			
                            -- DEAD
                                    and active_clients.person_id not in (
                                    select person_id 
                                    from person 
                                    where death_date <= cast('#endDate#' as date)
                                    and dead = 1
                                )
						 )
						 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type = 5 AND p.voided = 0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'
		) AS Patient_MissedAppointments
		
) AS PatientAppointmentStatus

GROUP BY PatientAppointmentStatus.age_group
ORDER BY PatientAppointmentStatus.sort_order)

UNION ALL


(SELECT 'Total' AS 'AgeGroup'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'MIssedWithin28days' AND PatientAppointmentStatus.Gender = 'M', 1, 0))) AS 'MIssedWithin28days_Males'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'MIssedWithin28days' AND PatientAppointmentStatus.Gender = 'F', 1, 0))) AS 'MIssedWithin28days_Females'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
FROM

(SELECT  Total_MissedAppointments.Id
			, Total_MissedAppointments.patientIdentifier AS "Patient Identifier"
			, Total_MissedAppointments.patientName AS "Patient Name"
			, Total_MissedAppointments.Age
			, Total_MissedAppointments.Gender
			, Total_MissedAppointments.App_Status
FROM
        (
			select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						'MIssedWithin28days' AS App_Status,
						observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (

						  -- Latest followup date from the lastest followup form, exclude voided followup date
						select active_clients.person_id
								from
								(  select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 0
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) <= 28
				
				
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
                                    AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )
						
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where concept_id = 2249
                                    AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                    )

		                        and active_clients.person_id not in (
							
							        -- TOUTS
                                    select tout_clients.person_id
										from
										(select B.person_id, B.obs_group_id, B.obs_datetime AS latest_consultation
											from obs B
											inner join
											(select person_id, max(obs_datetime), SUBSTRING(max(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 2403
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as A
											on A.observation_id = B.obs_group_id
											where concept_id = 2398
											and A.observation_id = B.obs_group_id
											and voided = 0
											group by B.person_id
										) as tout_clients
										where tout_clients.latest_consultation < cast('#endDate#' as date)
                                                
                                                )
			
                            -- DEAD
                                    and active_clients.person_id not in (
                                    select person_id 
                                    from person 
                                    where death_date <= cast('#endDate#' as date)
                                    and dead = 1
                                )
						 )
						 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type = 5 AND p.voided = 0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages'
		) AS Total_MissedAppointments
) AS PatientAppointmentStatus)

) AS TotalPatientAppointmentStatus

ORDER BY TotalPatientAppointmentStatus.sort_order;
