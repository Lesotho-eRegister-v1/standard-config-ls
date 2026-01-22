SELECT Total_Aggregated_PPR.AgeGroup
		, Total_Aggregated_PPR.Scheduled_Male
		, Total_Aggregated_PPR.Scheduled_Female
		, Total_Aggregated_PPR.Seen_Male 
		, Total_Aggregated_PPR.Seen_Female
		, Total_Aggregated_PPR.Missed_Male
		, Total_Aggregated_PPR.Missed_Female
		, Total_Aggregated_PPR.NewlyDiagnosed_Male
		, Total_Aggregated_PPR.NewlyDiagnosed_Female
		, Total_Aggregated_PPR.NLIC_Male
		, Total_Aggregated_PPR.NLIC_Female
		, Total_Aggregated_PPR.TransferIns_Male
		, Total_Aggregated_PPR.TransferIns_Female
		, Total_Aggregated_PPR.Deceased_Male
		, Total_Aggregated_PPR.Deceased_Female
		, Total_Aggregated_PPR.Initiated_Male
		, Total_Aggregated_PPR.Initiated_Female
		, Total_Aggregated_PPR.Total

FROM

(
	(SELECT PPR_DETAILS.age_group AS 'AgeGroup'
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Appointment_Scheduled' AND PPR_DETAILS.Gender = 'M', 1, 0))) AS Scheduled_Male
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Appointment_Scheduled' AND PPR_DETAILS.Gender = 'F', 1, 0))) AS Scheduled_Female
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Seen' AND PPR_DETAILS.Gender = 'M', 1, 0))) AS Seen_Male
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Seen' AND PPR_DETAILS.Gender = 'F', 1, 0))) AS Seen_Female
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Missed_Appointment' AND PPR_DETAILS.Gender = 'M', 1, 0))) AS Missed_Male
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Missed_Appointment' AND PPR_DETAILS.Gender = 'F', 1, 0))) AS Missed_Female
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Newly_Diagnosed' AND PPR_DETAILS.Gender = 'M', 1, 0))) AS NewlyDiagnosed_Male
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Newly_Diagnosed' AND PPR_DETAILS.Gender = 'F', 1, 0))) AS NewlyDiagnosed_Female
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'NLIC_Clients' AND PPR_DETAILS.Gender = 'M', 1, 0))) AS NLIC_Male
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'NLIC_Clients' AND PPR_DETAILS.Gender = 'F', 1, 0))) AS NLIC_Female
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Transfered_In' AND PPR_DETAILS.Gender = 'M', 1, 0))) AS TransferIns_Male
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Transfered_In' AND PPR_DETAILS.Gender = 'F', 1, 0))) AS TransferIns_Female
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Deceased' AND PPR_DETAILS.Gender = 'M', 1, 0))) AS Deceased_Male
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status = 'Deceased' AND PPR_DETAILS.Gender = 'F', 1, 0))) AS Deceased_Female
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status in ('Newly_Diagnosed','NLIC_Clients','Transfered_In') AND PPR_DETAILS.Gender = 'M', 1, 0))) AS Initiated_Male
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(IF(PPR_DETAILS.Status in ('Newly_Diagnosed','NLIC_Clients','Transfered_In') AND PPR_DETAILS.Gender = 'F', 1, 0))) AS Initiated_Female
			, IF(PPR_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, PPR_DETAILS.sort_order
			
	FROM

	(
select distinct         patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Appointment_Scheduled" as "Status",
						observed_age_group.sort_order AS sort_order 
					from obs o
                        -- Appointment Scheduled
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
						AND o.concept_id = 3751  and o.value_coded = 2146
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0

UNION ALL

 (SELECT Id, patientIdentifier , ART_Number, patientName AS Full_Name , Age, age_group, Gender, 'Missed_Appointment' AS 'Status', sort_order
FROM
                 (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS DURING THE PERIOD
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 0
								AND latest_follow_up >= CAST('#startDate#' as date)
                				AND latest_follow_up < CAST('#endDate#' as date)
								AND patient.voided = 0 AND o.voided = 0
								AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				
				
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    	AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							and os.voided = 0
							)
						
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    	AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							and os.voided = 0
							)

		and active_clients.person_id not in (
							
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.obs_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2398 and os.voided = 0
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
										
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
									
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TwentyEightDayDefaulters
				   order by TwentyEightDayDefaulters.patientName)
UNION ALL

 (select distinct 		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Newly_Diagnosed" as "Status",
						observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY DIAGNOSED ON ART
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
						AND patient.voided = 0 AND o.voided = 0
						 AND (o.concept_id = 2249 

						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							and os.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )	
						 )
UNION ALL


select 	distinct		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"NLIC_Clients" as "Status",
						observed_age_group.sort_order AS sort_order
from obs o
-- NLIC Clients
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
						AND patient.voided = 0 AND o.voided = 0
						AND o.person_id in (
							select person_id
							from 
								(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
								 from obs oss
								 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
								 and oss.obs_datetime < cast('#startDate#' as DATE)
								 group by p.person_id
								 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) > 91) as Missed_Greater_Than_91Days
						 )

						 -- Client Seen: As either patient OR Treatment Buddy
						 AND (						 
								 o.person_id in (
										select distinct os.person_id
										from obs os
										where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
										AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
										AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 )
								 
								 -- Client Seen and Date Restarted picked 
								 OR o.person_id in (
										select distinct os.person_id
										from obs os
										where os.concept_id = 3708 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
													AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 )
						 )
						 -- Still on treatment at the end of the reporting period
						 AND o.person_id in (
							select person_id
							from 
								(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
								 from obs oss
								 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
								 and cast(oss.obs_datetime as date) >= cast('#startDate#' as DATE) and cast(oss.obs_datetime as date) <= cast('#endDate#' as DATE)
								 group by p.person_id
								 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) <= 28) as Still_On_Treatment_End_Period
						 )
						 
						 -- Transfered Out to Another Site during thier latest encounter before the start date
						 AND o.person_id not in (
							select person_id
							from 
								(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS last_obs_tout
								 from obs oss
								 inner join person p on oss.person_id=p.person_id and oss.concept_id = 4155 and oss.voided=0
								 and oss.obs_datetime < cast('#startDate#' as DATE)
								 group by p.person_id
								 having last_obs_tout = 2146) as Transfered_Out_In_Last_Encounter
						 )
						 
						-- NOT Transfered In from another Site
						 AND o.person_id not in (
								select os.person_id 
								from obs os
								where (os.concept_id = 2253 AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
													AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE))
								AND os.voided = 0					
						 )						 
						 
						 AND o.person_id not in (
									select person_id 
									from person 
									where death_date <= CAST('#endDate#' AS DATE)
									and dead = 1
						 )

UNION ALL

select distinct 		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Transfered_In" as "Status",
						observed_age_group.sort_order AS sort_order 
					from obs o
                        -- Transfered Ins
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
						AND o.concept_id = 2396
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)					
						AND patient.voided = 0 AND o.voided = 0
UNION ALL

select distinct 		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Seen" as "Status",
						observed_age_group.sort_order AS sort_order 
					from obs o
                        -- Clients Seen
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
						AND o.concept_id = 3843 AND o.value_coded in (3841,3842)
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)				
						AND patient.voided = 0 AND o.voided = 0
UNION ALL

select distinct 		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Deceased" as "Status",
						observed_age_group.sort_order AS sort_order 
					from obs o
                        -- Deceased Clients
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
						AND o.person_id in (
									select person_id 
									from person 
									where death_date <= CAST('#endDate#' AS DATE)
									and dead = 1
						 )
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)				
						AND patient.voided = 0 AND o.voided = 0
		
	) AS PPR_DETAILS

	GROUP BY PPR_DETAILS.age_group
	ORDER BY PPR_DETAILS.sort_order)
	
	
UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Appointment_Scheduled' AND Totals.Gender = 'M', 1, 0))) AS 'Scheduled_Male'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Appointment_Scheduled' AND Totals.Gender = 'F', 1, 0))) AS 'Scheduled_Female'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Seen' AND Totals.Gender = 'M', 1, 0))) AS 'Seen_Male'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Seen' AND Totals.Gender = 'F', 1, 0))) AS 'Seen_Female'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Missed_Appointment' AND Totals.Gender = 'M', 1, 0))) AS 'Missed_Male'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Missed_Appointment' AND Totals.Gender = 'F', 1, 0))) AS 'Missed_Female'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Newly_Diagnosed' AND Totals.Gender = 'M', 1, 0))) AS 'NewlyDiagnosed_Male'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Newly_Diagnosed' AND Totals.Gender = 'F', 1, 0))) AS 'NewlyDiagnosed_Female'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'NLIC_Clients' AND Totals.Gender = 'M', 1, 0))) AS 'NLIC_Male'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'NLIC_Clients' AND Totals.Gender = 'F', 1, 0))) AS 'NLIC_Female'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Transfered_In' AND Totals.Gender = 'M', 1, 0))) AS 'TransferIns_Male'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Transfered_In' AND Totals.Gender = 'F', 1, 0))) AS 'TransferIns_Female'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Deceased' AND Totals.Gender = 'M', 1, 0))) AS 'Deceased_Male'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status = 'Deceased' AND Totals.Gender = 'F', 1, 0))) AS 'Deceased_Female'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status in ('Newly_Diagnosed','NLIC_Clients','Transfered_In') AND Totals.Gender = 'M', 1, 0))) AS 'Initiated_Male'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Status in ('Newly_Diagnosed','NLIC_Clients','Transfered_In') AND Totals.Gender = 'F', 1, 0))) AS 'Initiated_Female'
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_PPR.Id
					, Total_PPR.patientIdentifier AS "Patient Identifier"
					, Total_PPR.Full_Name AS "Patient Name"
					, Total_PPR.Age
					, Total_PPR.Gender
					, Total_PPR.Status
				
		FROM

		(
			 select distinct         patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Appointment_Scheduled" as "Status",
						observed_age_group.sort_order AS sort_order 
					from obs o
                        -- Appointment Scheduled
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
						AND o.concept_id = 3751  and o.value_coded = 2146
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0

UNION ALL

 (SELECT Id, patientIdentifier , ART_Number, patientName AS Full_Name , Age, age_group, Gender, 'Missed_Appointment' AS 'Status', sort_order
FROM
                 (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS DURING THE PERIOD
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 0
								AND latest_follow_up >= CAST('#startDate#' as date)
                				AND latest_follow_up < CAST('#endDate#' as date)
								AND patient.voided = 0 AND o.voided = 0
								AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				
				
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    	AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							and os.voided = 0
							)
						
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    	AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							and os.voided = 0
							)

		and active_clients.person_id not in (
							
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.obs_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2398 and os.voided = 0
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
										
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
									
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TwentyEightDayDefaulters
				   order by TwentyEightDayDefaulters.patientName)
UNION ALL

 (select distinct 		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Newly_Diagnosed" as "Status",
						observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY DIAGNOSED ON ART
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
						AND patient.voided = 0 AND o.voided = 0
						 AND (o.concept_id = 2249 

						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							and os.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )	
						 )
UNION ALL


select 	distinct		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"NLIC_Clients" as "Status",
						observed_age_group.sort_order AS sort_order
from obs o
-- NLIC Clients
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
						AND patient.voided = 0 AND o.voided = 0
						AND o.person_id in (
							select person_id
							from 
								(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
								 from obs oss
								 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
								 and oss.obs_datetime < cast('#startDate#' as DATE)
								 group by p.person_id
								 having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) > 91) as Missed_Greater_Than_91Days
						 )

						 -- Client Seen: As either patient OR Treatment Buddy
						 AND (						 
								 o.person_id in (
										select distinct os.person_id
										from obs os
										where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
										AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
										AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 )
								 
								 -- Client Seen and Date Restarted picked 
								 OR o.person_id in (
										select distinct os.person_id
										from obs os
										where os.concept_id = 3708 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
													AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								 )
						 )
						 -- Still on treatment at the end of the reporting period
						 AND o.person_id in (
							select person_id
							from 
								(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
								 from obs oss
								 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
								 and cast(oss.obs_datetime as date) >= cast('#startDate#' as DATE) and cast(oss.obs_datetime as date) <= cast('#endDate#' as DATE)
								 group by p.person_id
								 having datediff(CAST('#endDate#' AS DATE), latest_follow_up) <= 28) as Still_On_Treatment_End_Period
						 )
						 
						 -- Transfered Out to Another Site during thier latest encounter before the start date
						 AND o.person_id not in (
							select person_id
							from 
								(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS last_obs_tout
								 from obs oss
								 inner join person p on oss.person_id=p.person_id and oss.concept_id = 4155 and oss.voided=0
								 and oss.obs_datetime < cast('#startDate#' as DATE)
								 group by p.person_id
								 having last_obs_tout = 2146) as Transfered_Out_In_Last_Encounter
						 )
						 
						-- NOT Transfered In from another Site
						 AND o.person_id not in (
								select os.person_id 
								from obs os
								where (os.concept_id = 2253 AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
													AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE))
								AND os.voided = 0					
						 )						 
						 
						 AND o.person_id not in (
									select person_id 
									from person 
									where death_date <= CAST('#endDate#' AS DATE)
									and dead = 1
						 )

UNION ALL

select distinct 		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Transfered_In" as "Status",
						observed_age_group.sort_order AS sort_order 
					from obs o
                        -- Transfered Ins
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
						AND o.concept_id = 2396
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)					
						AND patient.voided = 0 AND o.voided = 0
UNION ALL

select distinct 		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Seen" as "Status",
						observed_age_group.sort_order AS sort_order 
					from obs o
                        -- Clients Seen
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
						AND o.concept_id = 3843 AND o.value_coded in (3841,3842)
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)				
						AND patient.voided = 0 AND o.voided = 0
UNION ALL

select distinct 		patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						p.identifier as ART_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS Full_Name,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						"Deceased" as "Status",
						observed_age_group.sort_order AS sort_order 
					from obs o
                        -- Deceased Clients
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
						AND o.person_id in (
									select person_id 
									from person 
									where death_date <= CAST('#endDate#' AS DATE)
									and dead = 1
						 )
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)				
						AND patient.voided = 0 AND o.voided = 0		) AS Total_PPR
  ) AS Totals
 )
) AS Total_Aggregated_PPR
ORDER BY Total_Aggregated_PPR.sort_order

