SELECT regimen_name,
	IF(Id is null, 0,SUM(IF(outcome = 'drug_count_1' AND Age >= 15,1,0))) AS "1 Month",
    IF(Id is null, 0,SUM(IF(outcome = 'drug_count_other' AND Age >= 15,1,0))) AS "Other"

FROM (

SELECT Id, regimen_name, outcome, Age

FROM

(select Id, outcome, Age, 
case 
when ARV_regimen = 3683 THEN "3a"
when ARV_regimen = 3684 THEN "3b"
when ARV_regimen = 3685 THEN "3c"
when ARV_regimen = 4706 THEN "3d"
when ARV_regimen = 4707 THEN "3e"
when ARV_regimen = 4708 THEN "3f"
when ARV_regimen = 4709 THEN "3g"
when ARV_regimen = 4710 THEN "3h"
else 'Other' end as regimen_name
FROM 
(Select Id, outcome, Age, ARV_regimen
FROM
((Select Id, outcome, Age, ARV_regimen
FROM
((Select Id, outcome, Age
	FROM
(Select Id, outcome, Age
	FROM
	(select distinct patient.patient_id AS Id,  'drug_count_1' as outcome,
				floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                -- INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 -- INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								-- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'
				  )AS Clients_Seen

		WHERE Clients_Seen.Id not in (
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

				  
				  )Seen_Clients)

 UNION

 (Select Id, outcome, Age
	FROM
	(select distinct patient.patient_id AS Id,  'drug_count_1' as outcome,
				floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

                from obs o

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
                   WHERE observed_age_group.report_group_name = 'Modified_Ages')Seen_Previous))Seen_and_Seen_Prev		  

	inner join 

		( SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen
		FROM(
					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS current_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 2250
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as currentreg
					
					LEFT OUTER JOIN									

					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS substitute_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 4284
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					LEFT OUTER JOIN					

					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS switch_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 2268
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as switchreg
					ON switchreg.person_id =  currentreg.person_id
		)				
		
		)latest 
		on latest.person_id = Seen_and_Seen_Prev.Id
		  
	 inner join 
 (select ID_, latest_follow_up,max_observation
		FROM(
            select a.person_id AS ID_, SUBSTRING(MAX(CONCAT(a.obs_datetime, b.value_datetime)), 20) AS latest_follow_up, Max(CAST(a.obs_datetime AS DATE)) as max_observation,
			SUBSTRING(MAX(CONCAT(a.obs_datetime, b.obs_group_id)), 20) as max_obs_group_id
			from obs a, obs b
			where a.person_id = b.person_id
			and a.concept_id = 3753
			and b.concept_id = 3752
			and a.obs_id = b.obs_group_id
			and a.obs_datetime <= cast('#endDate#' as date)
			group by a.person_id)as latest_follow_up_obs
			where datediff(latest_follow_up, max_observation) >= 10 AND datediff(latest_follow_up, max_observation)< 28
			OR datediff(latest_follow_up, max_observation) >= 28 AND datediff(latest_follow_up, max_observation)< 56)as supply_duration
		ON 	Seen_and_Seen_Prev.Id = supply_duration.ID_

 where ARV_regimen in (3683,3684,3685,4706,4707,4708,4709,4710))

 UNION 

 (Select Id, outcome, Age, ARV_regimen
FROM
((Select Id, outcome, Age
	FROM
(Select Id, outcome, Age
	FROM
	(select distinct patient.patient_id AS Id,  'drug_count_other' as outcome,
				floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                -- INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 -- INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								-- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
								 INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'
				  )AS Clients_Seen

		WHERE Clients_Seen.Id not in (
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

				  
				  )Seen_Clients)

 UNION

 (Select Id, outcome, Age
	FROM
	(select distinct patient.patient_id AS Id,  'drug_count_other' as outcome,
				floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age

                from obs o

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
                   WHERE observed_age_group.report_group_name = 'Modified_Ages')Seen_Previous))Seen_and_Seen_Prev		  

	inner join 

		( SELECT currentreg.person_id,COALESCE(switch_regimen,substitute_regimen,current_regimen) ARV_regimen
		FROM(
					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS current_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 2250
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as currentreg
					
					LEFT OUTER JOIN									

					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS substitute_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 4284
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as substitutereg
					ON substitutereg.person_id =  currentreg.person_id

					LEFT OUTER JOIN					

					
					(select distinct o.person_id, max(o.obs_datetime) as maxdate, SUBSTRING(MAX(CONCAT(o.obs_datetime, o.value_coded)), 20) AS switch_regimen
					from obs o 
					INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.preferred=1
					where o.concept_id = 2268
					AND o.voided = 0
					and o.obs_datetime <= cast('#endDate#' as date)
					group by person_id) as switchreg
					ON switchreg.person_id =  currentreg.person_id
		)				
		
		)latest 
		on latest.person_id = Seen_and_Seen_Prev.Id
		  
	 inner join 
 (select ID_, latest_follow_up,max_observation
		FROM(
            select a.person_id AS ID_, SUBSTRING(MAX(CONCAT(a.obs_datetime, b.value_datetime)), 20) AS latest_follow_up, Max(CAST(a.obs_datetime AS DATE)) as max_observation,
			SUBSTRING(MAX(CONCAT(a.obs_datetime, b.obs_group_id)), 20) as max_obs_group_id
			from obs a, obs b
			where a.person_id = b.person_id
			and a.concept_id = 3753
			and b.concept_id = 3752
			and a.obs_id = b.obs_group_id
			and a.obs_datetime <= cast('#endDate#' as date)
			group by a.person_id)as latest_follow_up_obs
			where datediff(latest_follow_up, max_observation) >=  56 )as supply_duration
		ON 	Seen_and_Seen_Prev.Id = supply_duration.ID_

 where ARV_regimen in (3683,3684,3685,4706,4707,4708,4709,4710)))txcurr_with_regimen) Total_Patients_On_ART_with_Regimen)as Regimen_Report
 
 UNION
 
SELECT '',"3a",'',''


UNION
 
SELECT '',"3b",'',''


UNION
 
SELECT '',"3c",'',''


UNION
 
SELECT '',"3d",'',''


UNION
 
SELECT '',"3e",'',''

UNION
 
SELECT '',"3f",'',''

UNION
 
SELECT '',"3g",'',''

UNION
 
SELECT '',"3h",'',''
 
 )as Final_Regimen_Report
 Group by regimen_name