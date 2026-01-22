SELECT distinct Patient_Identifier, Patient_Name, DOB, Sex, Client_Outcome, Date_of_Outcome
FROM
(

SELECT distinct Patient_Identifier, Patient_Name, Age,DOB, Sex, Program_Status
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

-- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
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
)txcurr_2020Q4)
cohort_txcurr

left outer join 


 (Select patientIdentifier, Client_Outcome
 FROM( 
 (Select patientIdentifier, Client_Outcome
 FROM
 (select distinct patient_identifier.identifier AS patientIdentifier, 'Active' AS 'Client_Outcome'

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
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 3752
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id	
								) as active_clients
							where active_clients.latest_follow_up >= cast('#endDate#' as date)

		
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
		and active_clients.person_id not in (
										select o.person_id
											from obs o 
											INNER JOIN patient ON o.person_id = patient.patient_id
											INNER JOIN person ON patient.patient_id = person.person_id
											INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											where concept_id = 3634 and o.value_coded = 2095
											and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
											and o.voided = 0
							)
		AND active_clients.person_id not in  (
											select person_id
											from 
												(select o.person_id, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_datetime)), 20) AS latest_follow_up		
													from obs o		
													inner join 
														(select oss.person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
															from obs oss where concept_id = 3753
															and oss.obs_datetime <= cast('#startDate#' as date)
															and oss.voided = 0
															group by oss.person_id)followup_form
													on followup_form.observation_id = o.obs_group_id
													where o.concept_id = 3752
													and followup_form.observation_id = o.obs_group_id
													and o.obs_datetime < cast('#startDate#' as DATE)
													group by person_id
													having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) > 0) as NotActive_IIT
										)	
						 )
						 -- end
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id
						 AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 )active)
 
 UNION
 
  (Select patientIdentifier, 'Tranfer_Out' AS Client_Outcome
 FROM
 (
	select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier, person_id

				from 

		(select o.person_id
		from obs o
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND patient.voided = 0 AND o.voided = 0
				 AND o.person_id in (
					 -- Consider as T/Out after drug supply is depleted
						select person_id
						from 
							(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
							 from obs oss
							 inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
							 and oss.obs_datetime <= cast('#endDate#' as DATE)
							 group by p.person_id
							 having datediff(CAST(latest_follow_up as DATE), CAST('#endDate#' AS DATE)) < 0
							 ) as IIT
				 )

				 
				 AND o.person_id in (
					 -- Transfered Out to Another Site
						select distinct os.person_id 
						from obs os
						where os.concept_id = 4155 and os.value_coded = 2146
						AND os.obs_datetime <= CAST('#endDate#' AS DATE)
						
				 )

				  AND o.person_id not in (
					  -- NOT DEAD
						select distinct person_id 
						from person 
						where death_date <= CAST('#endDate#' AS DATE)
						and dead = 1
						
				 )

				 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
				 group by patient.patient_id) as not_active
				 INNER JOIN patient ON not_active.person_id = patient.patient_id
				 AND patient.voided = 0
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
				group by patient.patient_id
                                        
				)as touts)
				
			


UNION

(SELECT patientIdentifier, 'TransferIn' as 'Client_Outcome'
						FROM
						(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier
									from 

									(	
									select distinct o.person_id 
									from obs o 
									where o.person_id in		
										(	select o.person_id
											from obs o 
											INNER JOIN patient ON o.person_id = patient.patient_id
											INNER JOIN person ON patient.patient_id = person.person_id
											INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
											where concept_id = 3634 and o.value_coded = 2095
											and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
											and CAST(o.obs_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
											and o.voided = 0)
                                        
									) as transfer_in
									INNER JOIN patient ON transfer_in.person_id = patient.patient_id
									AND patient.voided = 0 
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id 
								 AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 )transfer_in)

UNION

(SELECT patientIdentifier, 'IIT' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier

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
														and oss.obs_datetime <= cast('#endDate#' as DATE)
														group by p.person_id
														having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 0) as NotActive_IIT
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
														having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 0) as NotActive_IIT
												)
												INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id


									) as IIT
									INNER JOIN patient ON IIT.person_id = patient.patient_id
									AND patient.voided = 0 
									 AND IIT.person_id in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 2249
											AND datediff(CAST('#endDate#' AS DATE), os.value_datetime) > 0						
									)
									-- NOT Transfered Out to Another Site
									AND IIT.person_id not in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 4155 and os.value_coded = 2146
											AND os.obs_datetime <= CAST('#endDate#' AS DATE)						
									)
									-- NOT DEAD
									AND IIT.person_id not in (
											select person_id 
											from person 
											where death_date <= CAST('#endDate#' AS DATE)
											and dead = 1
									)
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id 
								 AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
)IIT)

UNION

(SELECT patientIdentifier, 'Died' as 'Client_Outcome'
FROM
(select obs_ml_clients.person_id,  patient_identifier.identifier AS patientIdentifier
from obs os
inner join 
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
		) as obs_ml_clients on os.person_id = obs_ml_clients.person_id
		INNER JOIN person ON person.person_id = obs_ml_clients.person_id AND person.voided = 0
		INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
			WHERE obs_ml_clients.person_id in (
				select person_id 
				from person 
				where death_date <= CAST('#endDate#' AS DATE)
				and dead = 1
	 ))died)

UNION

(SELECT patientIdentifier,'Stopped Treatment' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier

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

									) as stopped
									INNER JOIN patient ON stopped.person_id = patient.patient_id
									AND patient.voided = 0 
									AND stopped.person_id in 
									(
										select distinct os.person_id 
									from obs os
									where os.concept_id = 3701 
									AND os.value_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
)stopped)

UNION

(SELECT patientIdentifier, 'Reinitiating Treatment' AS 'Client_Outcome'
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier

									from 

									(	


										select distinct o.person_id
										from obs o
										-- PATIENTS WITH NO CLINICAL CONTACT OR ARV PICK-UP 
										-- SINCE THEIR LAST EXPECTED CONTACT WHO RESTARTED ARVs WITHIN THE REPORTING PERIOD
										INNER JOIN patient ON o.person_id = patient.patient_id
										AND patient.voided = 0 AND o.voided = 0
										AND o.person_id in (
											select person_id
											from 
												(select o.person_id, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_datetime)), 20) AS latest_follow_up		
													from obs o		
													inner join 
														(select oss.person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
															from obs oss where concept_id = 3753
															and oss.obs_datetime <= cast('#startDate#' as date)
															and oss.voided = 0
															group by oss.person_id)followup_form
													on followup_form.observation_id = o.obs_group_id
													where o.concept_id = 3752
													and followup_form.observation_id = o.obs_group_id
													and o.obs_datetime < cast('#startDate#' as DATE)
													group by person_id
													having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) > 0) as NotActive_IIT
										)

										-- Client Seen: As either patient OR Treatment Buddy
										AND (						 
												o.person_id in (
														select distinct os.person_id
														from obs os
														where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
														AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												)
												
												-- Client Seen and Date Restarted picked 
												OR o.person_id in (
														select distinct os.person_id
														from obs os
														where os.concept_id = 3708 AND os.value_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												)
										)
										-- Still on treatment at the end of the reporting period, do not include missed 28 days
										AND o.person_id in (
											select person_id
											from 
												(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
												from obs oss
												inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
												and oss.obs_datetime >= cast('#startDate#' as DATE) and oss.obs_datetime <= cast('#endDate#' as DATE)
												group by p.person_id
												having datediff(CAST('#endDate#' AS DATE), latest_follow_up) <= 0) as Still_On_Treatment_End_Period
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
												where (os.concept_id = 2253 AND DATE(os.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
												AND os.voided = 0					
										)						 
										
										AND o.person_id not in (
													select person_id 
													from person 
													where death_date <= CAST('#endDate#' AS DATE)
													and dead = 1
										)
                                        
									) as reinitiating
									INNER JOIN patient ON reinitiating.person_id = patient.patient_id
									AND patient.voided = 0 
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
)reinitiating)

 )outcomes)All_outcomes
 ON All_outcomes.patientIdentifier = cohort_txcurr.Patient_Identifier

 left outer JOIN


(SELECT patientIdentifier, Date_of_Outcome
FROM
(
(Select patientIdentifier, Date_of_Outcome
FROM
(SELECT patientIdentifier, Date_Stopped 'Date_of_Outcome'
		FROM
		(select o.person_id,CAST(o.value_datetime AS DATE) as Date_Stopped, patient_identifier.identifier AS patientIdentifier
			from obs o 
			INNER JOIN patient ON o.person_id = patient.patient_id
			INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
			inner join patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
			where concept_id = 3701 and o.voided = 0
			and CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
			and CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
			and CAST(o.value_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH) 
			and o.person_id in (
					select os.person_id
					from obs os
					where os.concept_id=3767 and os.value_coded = 2297 and os.voided = 0)	
			
		)datestopped

)stopped)

UNION

(Select patientIdentifier, Date_of_Outcome
FROM
(SELECT patientIdentifier, Date_Died AS 'Date_of_Outcome'
		FROM
		(select distinct p.person_id, CAST(max(p.death_date) AS DATE) as Date_Died, patient_identifier.identifier AS patientIdentifier
			from person p
			inner join patient_identifier ON patient_identifier.patient_id = p.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
			where dead = 1
			and death_date >= CAST('#startDate#' AS DATE) and death_date <= CAST('#endDate#' AS DATE)
		)date_died
	)died)

UNION

	(SELECT patientIdentifier,Date_of_Outcome
	FROM
	
	(SELECT patientIdentifier, CAST(Date_TransferedOut AS DATE) AS 'Date_of_Outcome'
	FROM
	(
		select os.person_id, patient_identifier.identifier AS patientIdentifier, MAX(os.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(os.obs_datetime, os.value_datetime)), 20) AS Date_TransferedOut
		from obs os
		INNER JOIN patient ON os.person_id = patient.patient_id
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		inner join patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		where os.concept_id= 3752 and os.voided = 0
		and os.obs_datetime <= cast('#endDate#' as DATE)
		group by os.person_id
		having datediff(CAST(Date_TransferedOut as DATE), CAST('#endDate#' AS DATE)) < 0
	   )date_tout
	   
	   where date_tout.person_id in (
		   	select os.person_id
				from obs os
				INNER JOIN patient ON os.person_id = patient.patient_id
				INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				inner join patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
				where os.concept_id=2264 and os.voided = 0
				-- where os.concept_id=2266 and os.voided = 0
				and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
				group by os.person_id
	   )
	   )tout)

UNION

(	SELECT patientIdentifier,Date_of_Outcome
	FROM
	( SELECT patientIdentifier, Date_TransferedIn AS 'Date_of_Outcome'
	   FROM
	   (select os.person_id,  patient_identifier.identifier AS patientIdentifier,CAST(max(os.value_datetime) AS DATE) as Date_TransferedIn
		from obs os
		INNER JOIN patient ON os.person_id = patient.patient_id
		INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
		inner join patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
		where os.concept_id=2253 and os.voided = 0
        and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
		and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		and CAST(os.value_datetime AS DATE) >= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)
		and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		group by os.person_id)date_tin)t_ins
)

UNION

(Select patientIdentifier, Date_of_Outcome
FROM
(SELECT patientIdentifier, Date_IIT AS 'Date_of_Outcome'
	FROM											
	(select oss.person_id,patient_identifier.identifier AS patientIdentifier, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS Date_TransferedOut,
	CAST(MAX(oss.value_datetime) AS DATE) as Appointment_Date, CAST(DATE_ADD(CAST(MAX(oss.value_datetime) AS DATE), INTERVAL 1 DAY) as Date) as Date_IIT
			from obs oss
			INNER JOIN patient ON oss.person_id = patient.patient_id
			INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
			inner join patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
			where oss.voided=0 
			and oss.concept_id=3752
			and oss.obs_datetime <= CAST('#endDate#' AS DATE)
			group by oss.person_id
			-- having Appointment_Date >= CAST('#startDate#' AS DATE) and Appointment_Date <= CAST('#endDate#' AS DATE)

		)interrupted
		where interrupted.person_id in (
										select person_id 
										from
										(select o.person_id
										from obs o
												INNER JOIN patient ON o.person_id = patient.patient_id
												AND patient.voided = 0 AND o.voided = 0
												AND o.person_id in (
													select person_id
													from 
														(select oss.person_id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) AS latest_follow_up
														from obs oss
														inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
														and oss.obs_datetime <= cast('#endDate#' as DATE)
														group by p.person_id
														having datediff(CAST('#endDate#' AS DATE), latest_follow_up) > 0) as NotActive_IIT
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
														having datediff(CAST('#endDate#' AS DATE), latest_follow_up) >0) as NotActive_IIT
												)
												INNER JOIN patient_identifier ON patient_identifier.patient_id = patient.patient_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
										group by patient.patient_id)as IIT
										INNER JOIN patient ON IIT.person_id = patient.patient_id
										AND patient.voided = 0 
										AND IIT.person_id in (
											select distinct os.person_id 
											from obs os
											where os.concept_id = 2249
											AND datediff(CAST('#endDate#' AS DATE), os.value_datetime) > 0						
										 )
										 -- NOT Transfered Out to Another Site
										AND IIT.person_id not in (
												select distinct os.person_id 
												from obs os
												where os.concept_id = 4155 and os.value_coded = 2146
												AND os.obs_datetime <= CAST('#endDate#' AS DATE)						
										)
										-- NOT DEAD
										AND IIT.person_id not in (
												select person_id 
												from person 
												where death_date <= CAST('#endDate#' AS DATE)
												and dead = 1
										)
		)
		)X
)

UNION

(Select patientIdentifier, Date_of_Outcome
	FROM
	(SELECT patientIdentifier, Date_Reinitiated AS 'Date_of_Outcome'
			FROM
			(Select os.person_id, Cast(max(os.obs_datetime)as DATE) as Date_Reinitiated, patient_identifier.identifier AS patientIdentifier
				from obs os 
				INNER JOIN patient ON os.person_id = patient.patient_id
				INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				inner join patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
				where os.concept_id = 3843 AND os.value_coded in (3841,3842)
				AND os.obs_datetime >= CAST('#startDate#' AS DATE) 
				AND os.obs_datetime <= CAST('#endDate#' AS DATE)
				group by os.person_id 
				and os.person_id in (
						select person_id
											from 
												(select o.person_id, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_datetime)), 20) AS latest_follow_up		
													from obs o		
													inner join 
														(select oss.person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
															from obs oss where concept_id = 3753
															and oss.obs_datetime <= cast('#startDate#' as date)
															and oss.voided = 0
															group by oss.person_id)followup_form
													on followup_form.observation_id = o.obs_group_id
													where o.concept_id = 3752
													and followup_form.observation_id = o.obs_group_id
													and o.obs_datetime < cast('#startDate#' as DATE)
													group by person_id
													having datediff(CAST(DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -1 DAY) AS DATE), latest_follow_up) > 0) as NotActive_IIT
										)

	)date_reinitiated)reinitiated)	
	
)outcomedates)dates_of_outcomes
ON dates_of_outcomes.patientIdentifier = cohort_txcurr.Patient_Identifier
Order by Patient_Identifier




