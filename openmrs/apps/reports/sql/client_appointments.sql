select distinct Patient_Identifier,
				Patient_Name, 
				DOB,
				Age,
				Visit_Date,
				Appointment_Date

FROM
(
	(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB, Sex, 'Initiated' AS 'Program_Status'
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('2022-09-30' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						AND MONTH(o.value_datetime) = MONTH(CAST('2022-09-30' AS DATE)) 
						AND YEAR(o.value_datetime) = YEAR(CAST('2022-09-30' AS DATE))
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							 	-- TRANSFER IN
							
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							AND MONTH(os.obs_datetime) = MONTH(CAST('2022-09-30' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('2022-09-30' AS DATE))
						 )	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('2022-09-30' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_ART_Clients
				   where Age <=19
ORDER BY Newly_Initiated_ART_Clients.patientName)

	UNION

	(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB, Sex, 'Seen' AS 'Program_Status'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
								   p.identifier as ART_Number,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('2022-09-30' AS DATE), person.birthdate)/365) AS Age,
								   person.birthdate as DOB,
                                   person.gender AS Sex,
                                   observed_age_group.name AS age_group
								  
        from obs o
								-- CLIENTS SEEN FOR ART
                                  INNER JOIN patient ON o.person_id = patient.patient_id
                                  AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 AND MONTH(o.obs_datetime) = MONTH(CAST('2022-09-30' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('2022-09-30' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('2022-09-30' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 
						AND MONTH(o.value_datetime) = MONTH(CAST('2022-09-30' AS DATE)) 
						AND YEAR(o.value_datetime) = YEAR(CAST('2022-09-30' AS DATE))
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
													and CAST(oss.obs_datetime AS DATE) <= CAST('2022-09-30' AS DATE)
													and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('2022-09-30' AS DATE), INTERVAL -13 MONTH)
													group by oss.person_id) firstquery
										inner join (
													select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('2022-09-30' AS DATE)) as last_ap
													from obs os
													where concept_id = 3752
													and CAST(os.obs_datetime AS DATE) <= CAST('2022-09-30' AS DATE)
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
										having latest_transferout <= CAST('2022-09-30' AS DATE)
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
														and CAST(oss.obs_datetime AS DATE) <= CAST('2022-09-30' AS DATE)
														and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('2022-09-30' AS DATE), INTERVAL -13 MONTH)
														group by oss.person_id) firstquery
											inner join (
														select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('2022-09-30' AS DATE)) as last_ap
														from obs os
														where concept_id = 3752
														and CAST(os.obs_datetime AS DATE) <= CAST('2022-09-30' AS DATE)
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
											and death_date <= CAST('2022-09-30' AS DATE)		
						)
					)


 AND Clients_Seen.Id not in (
			select person_id 
			from person 
			where death_date <= CAST('2022-09-30' AS DATE)
			and dead = 1
 ) 	 

AND Age <= 19					
ORDER BY Clients_Seen.patientName)

	UNION

	(SELECT  Id,patientIdentifier , patientName, Age,DOB, Sex, 'Seen_Previous' AS 'Program_Status'
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('2022-09-30' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
					
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id-- , active_clients.latest_follow_up
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 3753
									and obs_datetime <= cast('2022-09-30' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id	
								) as active_clients
								where active_clients.latest_follow_up >= cast('2022-09-30' as date)

		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
							AND MONTH(os.obs_datetime) = MONTH(CAST('2022-09-30' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('2022-09-30' AS DATE))
							)						

						
		and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249
							AND MONTH(os.value_datetime) = MONTH(CAST('2022-09-30' AS DATE)) 
							AND YEAR(os.value_datetime) = YEAR(CAST('2022-09-30' AS DATE))
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
													and CAST(oss.obs_datetime AS DATE) <= CAST('2022-09-30' AS DATE)
													and CAST(oss.obs_datetime AS DATE) >= DATE_ADD(CAST('2022-09-30' AS DATE), INTERVAL -13 MONTH)
													group by oss.person_id) firstquery
										inner join (
													select os.person_id,datediff(CAST(max(os.value_datetime) AS DATE), CAST('2022-09-30' AS DATE)) as last_ap
													from obs os
													where concept_id = 3752
													and CAST(os.obs_datetime AS DATE) <= CAST('2022-09-30' AS DATE)
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
										having latest_transferout <= CAST('2022-09-30' AS DATE)
									) as TOUTS
							)			
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('2022-09-30' as date)
									and dead = 1
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('2022-09-30' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Seen_Previous_ART_Clients
				   where Age <= 19
ORDER BY Seen_Previous_ART_Clients.patientName)

UNION

(SELECT Id, patientIdentifier , patientName , Age, DOB, Sex, 'MissedWithin28Days' AS 'Program_Status'
FROM
                 (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('2022-09-30' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 28 DAYS
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
									and obs_datetime <= cast('2022-09-30' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as active_clients
								where active_clients.latest_follow_up < cast('2022-09-30' as date)
								and DATEDIFF(CAST('2022-09-30' AS DATE),latest_follow_up) <= 28

				and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
							AND MONTH(os.obs_datetime) = MONTH(CAST('2022-09-30' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('2022-09-30' AS DATE))
							)				
				
				and active_clients.person_id not in (
							select distinct os.person_id
							from obs os
							where concept_id = 2249 
							AND MONTH(os.obs_datetime) = MONTH(CAST('2022-09-30' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('2022-09-30' AS DATE))
							)

		and active_clients.person_id not in (
							
									-- TOUTS
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.obs_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2398
										group by os.person_id
										having latest_transferout <= CAST('2022-09-30' AS DATE)
									) as TOUTS
										
										)
			

		and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('2022-09-30' as date)
									and dead = 1
						 )
						 )
						 -- end
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('2022-09-30' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TwentyEightDayDefaulters
				   where Age <=19
				   order by TwentyEightDayDefaulters.patientName)

) previous

left outer JOIN
		-- Visit and Appointment Dates

	(select oss.person_id, SUBSTRING(CONCAT(oss.value_datetime, oss.obs_id), 20) AS observation_id, CAST(oss.value_datetime AS DATE) as Appointment_Date, CAST(oss.obs_datetime AS DATE) as Visit_Date
		from obs oss
		where oss.voided=0 
		and oss.concept_id=3752 
		AND CAST(oss.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		AND CAST(oss.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		order by Visit_Date desc
	)visit_date
	on visit_date.person_id = previous.ID
	order by Patient_Identifier, Visit_Date
