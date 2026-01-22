SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, Outcome
FROM
(
			(SELECT Id, PatientIdentifier, patientName, Age, Gender, age_group, 'DIED' AS Outcome, sort_order
			FROM
							(select obs_ml_clients.person_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   observed_age_group.name AS age_group,
												   observed_age_group.sort_order AS sort_order
								from
								(
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.person_id in (
														select person_id
														from 
															(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
															 from obs oss
															 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
															 and oss.obs_datetime < cast('#startDate#' as DATE)
															 group by p.person_id
															 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 29) as On_ART_Beginning_Quarter
												 )
				
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
										UNION
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
												
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
								) as obs_ml_clients
								INNER JOIN person ON person.person_id = obs_ml_clients.person_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
									 AND obs_ml_clients.person_id in (
											select person_id 
											from person 
											where cast(death_date as date) >= CAST('#startDate#' AS DATE)
                                            and cast(death_date as date) <= CAST('#endDate#' AS DATE)
											and dead = 1
									 )
									 AND obs_ml_clients.person_id not in (
											-- Visitors
											select distinct os.person_id from obs os
											where os.concept_id = 5416
											AND os.value_coded = 1 and os.voided = 0
											AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									 )

							    GROUP BY obs_ml_clients.person_id
							   ) AS TxMLClients
							  ORDER BY TxMLClients.Age)
							  
			UNION

			(
				SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, 'TOUT' AS Outcome, sort_order
			FROM
							(select obs_ml_clients.person_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   observed_age_group.name AS age_group,
												   observed_age_group.sort_order AS sort_order
								from
								(
										select distinct o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.person_id in (
														select person_id
														from 
															(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
															 from obs oss
															 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
															 and oss.obs_datetime < cast('#startDate#' as DATE)
															 group by p.person_id
															 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 1) as On_ART_Beginning_Quarter
												 )
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 0) as Missed_Greater_Than_0Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
										UNION
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 0) as Missed_Greater_Than_0Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
								) as obs_ml_clients
								INNER JOIN person ON person.person_id = obs_ml_clients.person_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
									 -- Transfered Out to Another Site
									 AND obs_ml_clients.person_id in (
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
											where tout_clients.latest_consultation <= cast('#endDate#' as date)					
									 )
									 -- NOT DEAD
									 AND obs_ml_clients.person_id not in (
											select person_id 
											from person 
											where death_date <= CAST('#endDate#' AS DATE)
											and dead = 1
									 )
									 AND obs_ml_clients.person_id not in (
											-- Visitors
											select distinct os.person_id from obs os
											where os.concept_id = 5416
											AND os.value_coded = 1 and os.voided = 0
											AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									 )
							    GROUP BY obs_ml_clients.person_id

							   ) AS TxRttClients
							  ORDER BY TxRttClients.Age
			)		  

			UNION

			(SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, 'STOPPED' AS Outcome, sort_order
			FROM
							(select obs_ml_clients.person_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   observed_age_group.name AS age_group,
												   observed_age_group.sort_order AS sort_order
								from
								(
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.person_id in (
														select person_id
														from 
															(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
															 from obs oss
															 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
															 and oss.obs_datetime < cast('#startDate#' as DATE)
															 group by p.person_id
															 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 29) as On_ART_Beginning_Quarter
												 )
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
										UNION
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
								) as obs_ml_clients
								INNER JOIN person ON person.person_id = obs_ml_clients.person_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
									 -- ART TREATMENT INTERRUPTION/REFUSED OR STOPPED
									 AND obs_ml_clients.person_id in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 3701 
											AND os.value_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)						
									 )
									 AND obs_ml_clients.person_id not in (
											-- Visitors
											select distinct os.person_id from obs os
											where os.concept_id = 5416
											AND os.value_coded = 1 and os.voided = 0
											AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									 )
							    GROUP BY obs_ml_clients.person_id
							   ) AS TxMLClients
							  ORDER BY TxMLClients.Age)

			UNION

			(SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, 'IIT<3m' AS Outcome, sort_order
			FROM
							(select obs_ml_clients.person_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   observed_age_group.name AS age_group,
												   observed_age_group.sort_order AS sort_order
								from
								(
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.person_id in (
														select person_id
														from 
															(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
															 from obs oss
															 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
															 and oss.obs_datetime < cast('#startDate#' as DATE)
															 group by p.person_id
															 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 29) as On_ART_Beginning_Quarter
												 )
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
										UNION
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
								) as obs_ml_clients
								INNER JOIN person ON person.person_id = obs_ml_clients.person_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
									 -- INITIATED ON ART LESS THAN 3 MONTHS AGO
									 AND obs_ml_clients.person_id in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 2249
											AND datediff(CAST('#endDate#' AS DATE), os.value_datetime) BETWEEN 0 AND 90						
									 )
									 -- NOT Transfered Out to Another Site
									 AND obs_ml_clients.person_id not in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 4155 and os.value_coded = 2146
											AND os.obs_datetime <= CAST('#endDate#' AS DATE)						
									 )
									 -- NOT DEAD
									 AND obs_ml_clients.person_id not in (
											select person_id 
											from person 
											where death_date <= CAST('#endDate#' AS DATE)
											and dead = 1
									 )
									 AND obs_ml_clients.person_id not in (
											-- Visitors
											select distinct os.person_id from obs os
											where os.concept_id = 5416
											AND os.value_coded = 1 and os.voided = 0
											AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									 )
							    GROUP BY obs_ml_clients.person_id
							   ) AS TxMLClients
							  ORDER BY TxMLClients.Age)
					  
			UNION

			(SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, 'IIT3-5m' AS Outcome, sort_order
			FROM
							(select obs_ml_clients.person_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   observed_age_group.name AS age_group,
												   observed_age_group.sort_order AS sort_order
								from
								(
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.person_id in (
														select person_id
														from 
															(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
															 from obs oss
															 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
															 and oss.obs_datetime < cast('#startDate#' as DATE)
															 group by p.person_id
															 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 29) as On_ART_Beginning_Quarter
												 )
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
										UNION
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
								) as obs_ml_clients
								INNER JOIN person ON person.person_id = obs_ml_clients.person_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
									 -- INITIATED ON ART 3-5 MONTHS AGO
									 AND obs_ml_clients.person_id in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 2249
											AND datediff(CAST('#endDate#' AS DATE), os.value_datetime) BETWEEN 89 AND 180							
									 )
									 -- NOT Transfered Out to Another Site
									 AND obs_ml_clients.person_id not in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 4155 and os.value_coded = 2146
											AND os.obs_datetime <= CAST('#endDate#' AS DATE)						
									 )
									 -- NOT DEAD
									 AND obs_ml_clients.person_id not in (
											select person_id 
											from person 
											where death_date <= CAST('#endDate#' AS DATE)
											and dead = 1
									 )
									 AND obs_ml_clients.person_id not in (
											-- Visitors
											select distinct os.person_id from obs os
											where os.concept_id = 5416
											AND os.value_coded = 1 and os.voided = 0
											AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									 )
							    GROUP BY obs_ml_clients.person_id
							   ) AS TxMLClients
							  ORDER BY TxMLClients.Age)

			UNION 

			(SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, 'IIT6+m' AS Outcome, sort_order
			FROM
							(select obs_ml_clients.person_id AS Id,
												   patient_identifier.identifier AS patientIdentifier,
												   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
												   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
												   person.gender AS Gender,
												   observed_age_group.name AS age_group,
												   observed_age_group.sort_order AS sort_order
								from
								(
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.person_id in (
														select person_id
														from 
															(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
															 from obs oss
															 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
															 and oss.obs_datetime < cast('#startDate#' as DATE)
															 group by p.person_id
															 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) < 29) as On_ART_Beginning_Quarter
												 )
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
										UNION
										select o.person_id
										from obs o
												 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND patient.voided = 0 AND o.voided = 0
												 AND o.concept_id = 2249 and cast(o.value_datetime as date) >= cast('#startDate#' as DATE) and cast(o.value_datetime as date) <= cast('#endDate#' as DATE)
												 AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														 from obs oss
														 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														 and oss.obs_datetime <= cast('#endDate#' as DATE)
														 group by p.person_id
														 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 28) as Missed_Greater_Than_28Days
												 )
												 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id
								) as obs_ml_clients
								INNER JOIN person ON person.person_id = obs_ml_clients.person_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
									 -- INITIATED ON ART 6+ MONTHS AGO
									 AND obs_ml_clients.person_id in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 2249
											AND datediff(CAST('#endDate#' AS DATE), os.value_datetime) >= 180						
									 )
									 -- NOT Transfered Out to Another Site
									 AND obs_ml_clients.person_id not in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 4155 and os.value_coded = 2146
											AND os.obs_datetime <= CAST('#endDate#' AS DATE)						
									 )
									 -- NOT DEAD
									 AND obs_ml_clients.person_id not in (
											select person_id 
											from person 
											where death_date <= CAST('#endDate#' AS DATE)
											and dead = 1
									 )
									 AND obs_ml_clients.person_id not in (
											-- Visitors
											select distinct os.person_id from obs os
											where os.concept_id = 5416
											AND os.value_coded = 1 and os.voided = 0
											AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
									 )
							    GROUP BY obs_ml_clients.person_id
							   ) AS TxMLClients
							  ORDER BY TxMLClients.Age)
) AS treatment_mortality_and_loss
GROUP BY treatment_mortality_and_loss.Id