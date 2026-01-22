Select Patient_Identifier, Patient_Name,age_group, Program_Status, CD4, Viral_Load, Suppression_Status, LTFU
FROM(
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Initiated' AS 'Program_Status'
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 
						AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							 	-- TRANSFER IN
							
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.patientName)-- AS Tx_New

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Tx_Curr' AS 'Program_Status'
	FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
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
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Seen_Previous_ART_Clients
ORDER BY Seen_Previous_ART_Clients.patientName)

UNION

-- INCLUDE MISSED APPOINTMENTS WITHIN 28 DAYS ACCORDING TO THE NEW PEPFAR GUIDELINE
(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Missed' AS 'Program_Status'
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
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
                                    select distinct(person_id)
                                    from
                                    (
                                        select os.person_id, CAST(max(os.obs_datetime) AS DATE) as latest_transferout
                                        from obs os
                                        where os.concept_id=2398
                                        group by os.person_id
                                        having latest_transferout <= CAST('#endDate#' AS DATE)
                                    ) as TOUTS
                                                
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
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS TwentyEightDayDefaulters
order by TwentyEightDayDefaulters.patientName)

UNION

(SELECT Id,patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age,DOB,age_group, Sex, 'Defaulter/LTFU' AS 'Program_Status'
FROM
                 (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
								       person.birthdate as DOB,
									   person.gender AS Sex,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order
                from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS < 89 DAYS
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND o.person_id in (
						 -- begin
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
								and DATEDIFF(CAST('#endDate#' AS DATE),latest_follow_up) > 28
				
				
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
									select distinct(person_id)
									from
									(
										select os.person_id, CAST(max(os.obs_datetime) AS DATE) as latest_transferout
										from obs os
										where os.concept_id=2398
										group by os.person_id
										having latest_transferout <= CAST('#endDate#' AS DATE)
									) as TOUTS
										
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
						LEFT OUTER JOIN patient_identifier p ON p.patient_id = patient.patient_id AND p.identifier_type in (5,12) AND p.voided = 0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages'and cast(value_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 3752 Group  BY patientIdentifier) AS MoreThanEightyNineDayDefaulters
order by MoreThanEightyNineDayDefaulters.patientName)
)as all_patients

inner join 
-- left outer join

(select o.person_id, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.obs_id)), 20) AS observation_id, o.value_numeric as CD4
from obs o 
	where o.concept_id = 1187 and o.voided = 0  and o.value_numeric < 200
    and MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
	and YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
    group by o.person_id
	
)as cd4
on all_patients.Id = cd4.person_id

left outer join 

(
	select os.person_id, os.value_numeric as Viral_Load
	from obs os	
	-- Virally unsuppressed
	where os.concept_id = 2254 and os.value_numeric > 999
	and os.voided = 0
	and MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
	and YEAR(os.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
) as unsuppressed
on all_patients.Id = unsuppressed.person_id

left outer JOIN
-- Virally unsupressed with CD4 less than 200
	(select o.person_id, 'Virally Unsupressed, CD4 < 200' As 'Suppression_Status'  
	-- CD4 less than 200
	from obs o
	where o.concept_id = 1187 and o.value_numeric < 200
	and MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
	and YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
	and o.voided = 0
	and o.person_id in(
		select os.person_id
		from obs os	
		-- Virally unsuppressed
		where os.concept_id = 2254 and os.value_numeric > 999
		and os.voided = 0
		and MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
		and YEAR(os.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
		))as unsuppressed_cd4_lessthan_200
on all_patients.Id = unsuppressed_cd4_lessthan_200.person_id

left outer JOIN

    (select distinct o.person_id, 'LTFU' AS 'LTFU'
				from obs o
						-- CLIENTS WHO MISSED APPOINTMENTS > 89 DAYS during the month
						 INNER JOIN patient ON o.person_id = patient.patient_id
						-- INNER JOIN location l ON o.location_id = l.location_id
						 AND o.person_id in (
						 -- begin
						select active_clients.person_id
								from
								(  
                                select B.person_id, B.obs_group_id, B.value_datetime AS latest_follow_up,DATEDIFF(CAST('#endDate#' AS DATE), B.value_datetime) as num_day,
								case 
								-- Added interval of 28,29,30,31 days to 89 days to calculate the number of days in a month(including 89 days that determine LTFU)
								-- determine the max days a client will have if LTFU during period  
                                    when MONTH(CAST('#endDate#' AS DATE)) = 01 then '120'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 02 then '117'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 03 then '120'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 04 then '119'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 05 then '120'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 06 then '119'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 07 then '120'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 08 then '120'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 09 then '119'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 10 then '120'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 11 then '119'
                                    when MONTH(CAST('#endDate#' AS DATE)) = 12 then '119'
                                      else '118' end as days_in_month
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
                                    having DATEDIFF(CAST('#endDate#' AS DATE), latest_follow_up) > 89
                                    and DATEDIFF(CAST('#endDate#' AS DATE), latest_follow_up) < days_in_month

								) as active_clients
								where active_clients.latest_follow_up < cast('#endDate#' as date)
				
				
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
                                    AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND os.voided = 0
                                    )
						
		                        and active_clients.person_id not in (
                                    select distinct os.person_id
                                    from obs os
                                    where concept_id = 2249
                                    AND MONTH(os.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
                                    AND YEAR(os.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
									AND os.voided = 0
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
			
                                -- DEAD
		                        and active_clients.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('#endDate#' as date)
									and dead = 1 and voided = 0
								 )
								and active_clients.person_id in (
									-- AHD Client
									select os.person_id 
									from obs os
									where os.concept_id = 4958 and os.value_coded = 2146
									and os.voided = 0
								)

					 )) AS LTFU
					 on all_patients.Id = LTFU.person_id
						
