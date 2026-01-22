
SELECT distinct Patient_Identifier,
				Patient_Name,  
				Gender, 
				age_group, 
				Program_Status,
				drug_duration
FROM
(select distinct Id,Patient_Identifier, Patient_Name, Gender,age_group, Program_Status,drug_duration

	FROM
(
(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name",Gender, age_group, 'Initiated' AS 'Program_Status'
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group
									  

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 

							AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )
							AND patient.voided = 0 AND o.voided = 0
							AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age)

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name",Gender, age_group, 'Seen' AS 'Program_Status'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group
								  
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 
						AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						)		
				 AND patient.voided = 0 AND o.voided = 0

							)
AND Clients_Seen.Id not in (
							select distinct(o.person_id)
							from obs o
							where o.person_id in (
									-- FOLLOW UPS
										select firstquery.person_id
										from
										(
										select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
										from obs oss
													where oss.voided=0 
													and oss.concept_id=3752 
													and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
													group by oss.person_id) firstquery
										inner join (
													select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
													from obs os
													where concept_id = 3752
													and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													group by os.person_id
													having last_ap < 0
										) secondquery
										on firstquery.person_id = secondquery.person_id
							) and o.person_id in (
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2266
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
							)					
		)

AND Clients_Seen.Id not in 
					(
						select distinct(o.person_id)
						from obs o
						where o.person_id in (
								-- FOLLOW UPS
											select firstquery.person_id
											from
											(
											select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
											from obs oss
														where oss.voided=0 
														and oss.concept_id=3752 
														and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
														group by oss.person_id) firstquery
											inner join (
														select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
														from obs os
														where concept_id = 3752
														and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
														group by os.person_id
														having last_ap < 0
											) secondquery
											on firstquery.person_id = secondquery.person_id
						)
						and o.person_id in (
								-- Death
											select distinct p.person_id
											from person p
											where dead = 1
											and death_date <= CAST('#endDate#' AS DATE)		
						)
					)

ORDER BY Clients_Seen.patientName)

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier",ART_Number, patientName AS "Patient_Name", Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status'
FROM (
(select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   p.identifier as ART_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
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
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id	
								) as active_clients
								where active_clients.latest_follow_up >= cast('#endDate#' as date)
				
				
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
							select distinct(o.person_id)
							from obs o
							where o.person_id in (
									-- FOLLOW UPS
										select firstquery.person_id
										from
										(
										select oss.person_id, SUBSTRING(MAX(CONCAT(oss.value_datetime, oss.obs_id)), 20) AS observation_id, CAST(max(oss.value_datetime) AS DATE) as latest_followup_obs
										from obs oss
													where oss.voided=0 
													and oss.concept_id=3752 
													and CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -13 MONTH)
													group by oss.person_id) firstquery
										inner join (
													select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('#endDate#' AS DATE)) as last_ap
													from obs os
													where concept_id = 3752
													and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
													group by os.person_id
													having last_ap < 0
										) secondquery
										on firstquery.person_id = secondquery.person_id
							) and o.person_id in (
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2266
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
							)			
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages')	   
		   
) AS ARTCurrent_PrevMonths
 
ORDER BY ARTCurrent_PrevMonths.Age))previous

INNER JOIN

	(SELECT person_id, 
			CASE
				WHEN datediff(latest_follow_up, max_observation) >= 10 AND datediff(latest_follow_up, max_observation)< 28 THEN '2 weeks'
				WHEN datediff(latest_follow_up, max_observation) >=  28 AND datediff(latest_follow_up, max_observation)< 56 THEN '1 month'
				WHEN datediff(latest_follow_up, max_observation) >=  56 AND datediff(latest_follow_up, max_observation)< 84 THEN '2 months'
				WHEN datediff(latest_follow_up, max_observation) >=  84 AND datediff(latest_follow_up, max_observation)< 112 THEN '3 months'
				WHEN datediff(latest_follow_up, max_observation) >=  112 AND datediff(latest_follow_up, max_observation)< 140 THEN '4 months'
				WHEN datediff(latest_follow_up, max_observation) >=  140 AND datediff(latest_follow_up, max_observation)< 168 THEN '5 months'
				WHEN datediff(latest_follow_up, max_observation) >=  168 AND datediff(latest_follow_up, max_observation)< 196 THEN '6 months'
				WHEN datediff(latest_follow_up, max_observation) >=  196 AND datediff(latest_follow_up, max_observation)< 224 THEN '7 months'
				WHEN datediff(latest_follow_up, max_observation) >=  224 AND datediff(latest_follow_up, max_observation)< 252 THEN '8 months'
				WHEN datediff(latest_follow_up, max_observation) >=  252 AND datediff(latest_follow_up, max_observation)< 280 THEN '9 months'
				WHEN datediff(latest_follow_up, max_observation) >=  280 AND datediff(latest_follow_up, max_observation)< 308 THEN '10 months'
				WHEN datediff(latest_follow_up, max_observation) >=  308 AND datediff(latest_follow_up, max_observation)< 336 THEN '11 months'
				WHEN datediff(latest_follow_up, max_observation) >=  336 AND datediff(latest_follow_up, max_observation)< 364 THEN '12 months'
				WHEN datediff(latest_follow_up, max_observation)   >=   364   THEN '>1year'
				ELSE 'Other supply' 
			END as drug_duration,
			max_observation,
			latest_follow_up
	 FROM (
			select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up, max_observation
				from obs B
				inner join 
				(select person_id, Max(CAST(obs_datetime AS DATE)) as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
				from obs where concept_id = 3753
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as A
				on A.observation_id = B.obs_group_id
				where concept_id = 3752
				and A.observation_id = B.obs_group_id	
				and B.voided = 0
	 ) as latest_follow_up_obs
	 ) duration
	  ON previous.Id = duration.person_id)Total_MMD
	  where drug_duration not in ("2 weeks","1 month","2 months")