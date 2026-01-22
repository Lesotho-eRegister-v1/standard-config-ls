(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Initiated' AS 'Program_Status', '1st_Visit' AS 'Visit_Type', 'Positive' AS 'SCRN_Results', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						
						
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  -- HISTORY OF PREVIOUS RESULTD--1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						-- VIA +VE
						 AND o.person_id in
						 
						 (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						 )
						  
						 
                   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Initiated' AS 'Program_Status', '1st_Visit' AS 'Visit_Type', 'Negative' AS 'SCRN_Results', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						
						
						
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  -- HISTORY OF PREVIOUS RESULTD--1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						-- VIA +VE
						 AND o.person_id in
						 
						 (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						 )
						  
						 
                   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Initiated' AS 'Program_Status', 'ReScreened' AS 'Visit_Type', 'Positive' AS 'SCRN_Results',  sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						
						  INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						  INNER JOIN person_name ON person.person_id = person_name.person_id
						  INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						  INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- VIA +VE
						 AND o.person_id in
						 
						 (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						 )
						
						
                   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Initiated' AS 'Program_Status', 'ReScreened' AS 'Visit_Type', 'Negative' AS 'SCRN_Results',  sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						
						  INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						  INNER JOIN person_name ON person.person_id = person_name.person_id
						  INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						  INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- VIA +VE
						 AND o.person_id in
						 
						 (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						 )
						
						
                   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Initiated' AS 'Program_Status', 'Post_Tx_Follow_up' AS 'Visit_Type', 'Positive' AS 'SCRN_Results',  sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- VIA +VE
						 AND o.person_id in
						 
						 (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						 )
						
                   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Initiated' AS 'Program_Status', 'Post_Tx_Follow_up' AS 'Visit_Type', 'Negative' AS 'SCRN_Results',  sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- VIA +VE
						 AND o.person_id in
						 
						 (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						 )
						
                   WHERE observed_age_group.report_group_name = 'HIV_ages') AS Newly_Initiated_ART_Clients
ORDER BY Newly_Initiated_ART_Clients.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen' AS 'Program_Status', '1st_Visit' AS 'Visit_Type', 'Positive' AS 'SCRN_Results',  sort_order
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 
                                 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
									  
						 -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						-- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)
						
           WHERE observed_age_group.report_group_name = 'HIV_ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				 AND patient.voided = 0 AND o.voided = 0
				and patient.patient_id not in(
											select distinct os.person_id from obs os															 
											where os.concept_id = 2396 														 
											AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
											)
							)
AND Clients_Seen.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
				AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
		)

AND Clients_Seen.Id not in 
			(
			select distinct person_id 
			from person
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)

ORDER BY Clients_Seen.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen' AS 'Program_Status', '1st_Visit' AS 'Visit_Type', 'Negative' AS 'SCRN_Results',  sort_order
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 
                                 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
									  
						 -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						-- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)
						
           WHERE observed_age_group.report_group_name = 'HIV_ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				 AND patient.voided = 0 AND o.voided = 0
				and patient.patient_id not in(
											select distinct os.person_id from obs os															 
											where os.concept_id = 2396 														 
											AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
											)
							)
AND Clients_Seen.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
				AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
		)

AND Clients_Seen.Id not in 
			(
			select distinct person_id 
			from person
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)

ORDER BY Clients_Seen.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen' AS 'Program_Status', 'ReScreened' AS 'Visit_Type', 'Positive' AS 'SCRN_Results',  sort_order
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 
                                 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
									  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- VIA +VE
						 AND o.person_id in
						 
						       (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)
						
           WHERE observed_age_group.report_group_name = 'HIV_ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				 AND patient.voided = 0 AND o.voided = 0
				and patient.patient_id not in(
											select distinct os.person_id from obs os															 
											where os.concept_id = 2396 														 
											AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
											)
							)
AND Clients_Seen.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
				AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
		)

AND Clients_Seen.Id not in 
			(
			select distinct person_id 
			from person
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)

ORDER BY Clients_Seen.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen' AS 'Program_Status', 'ReScreened' AS 'Visit_Type', 'Negative' AS 'SCRN_Results',  sort_order
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 
                                 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
									  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- VIA +VE
						 AND o.person_id in
						 
						       (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)
						
           WHERE observed_age_group.report_group_name = 'HIV_ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				 AND patient.voided = 0 AND o.voided = 0
				and patient.patient_id not in(
											select distinct os.person_id from obs os															 
											where os.concept_id = 2396 														 
											AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
											)
							)
AND Clients_Seen.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
				AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
		)

AND Clients_Seen.Id not in 
			(
			select distinct person_id 
			from person
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)

ORDER BY Clients_Seen.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen' AS 'Program_Status', 'Post_Tx_Follow_up' AS 'Visit_Type', 'Positive' AS 'SCRN_Results',  sort_order
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 
                                 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
									  
						  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to PREVOUS POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- VIA +VE
						 AND o.person_id in
						 
						       (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)
						
           WHERE observed_age_group.report_group_name = 'HIV_ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				 AND patient.voided = 0 AND o.voided = 0
				and patient.patient_id not in(
											select distinct os.person_id from obs os															 
											where os.concept_id = 2396 														 
											AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
											)
							)
AND Clients_Seen.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
				AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
		)

AND Clients_Seen.Id not in 
			(
			select distinct person_id 
			from person
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)

ORDER BY Clients_Seen.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen' AS 'Program_Status', 'Post_Tx_Follow_up' AS 'Visit_Type', 'Negative' AS 'SCRN_Results',  sort_order
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order
        from obs o
								-- CLIENTS SEEN FOR ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND (o.concept_id = 3843 AND o.value_coded = 3841 OR o.value_coded = 3842)
								 
                                 AND (DATE(o.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
									  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
									  
						  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to PREVOUS POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						-- VIA +VE
						 AND o.person_id in
						 
						       (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)
						
           WHERE observed_age_group.report_group_name = 'HIV_ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS NEWLY INITIATED ON ART
				 INNER JOIN patient ON o.person_id = patient.patient_id
				 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				 AND patient.voided = 0 AND o.voided = 0
				and patient.patient_id not in(
											select distinct os.person_id from obs os															 
											where os.concept_id = 2396 														 
											AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
											)
							)
AND Clients_Seen.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
				AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
		)

AND Clients_Seen.Id not in 
			(
			select distinct person_id 
			from person
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)

ORDER BY Clients_Seen.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status', '1st_Visit' AS 'Visit_Type', 'Positive' AS 'SCRN_Results', sort_order
FROM (
(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

        from obs o
				-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
				  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
				  AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247))
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				 INNER JOIN person_name ON person.person_id = person_name.person_id
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
                 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						-- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)
						
						
						  
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)

                          -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)						
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')
	   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4175
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  	   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')


UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4176
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  	   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4177
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  	   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4245
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
					 -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4246
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							 							  	   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
		        -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages'	)	   
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.Id not in (
				SELECT os.person_id 
				FROM obs os
				WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
				AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
										)
and ARTCurrent_PrevMonths.Id not in (
	           select distinct patient.patient_id AS Id
	           from obs o
	                       -- CLIENTS NEWLY INITIATED ON ART
				INNER JOIN patient ON o.person_id = patient.patient_id													
				AND (o.concept_id = 2249 
				AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND patient.voided = 0 AND o.voided = 0)
AND ARTCurrent_PrevMonths.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
		)
AND ARTCurrent_PrevMonths.Id not in (
			select person_id 
			from person 
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)
ORDER BY ARTCurrent_PrevMonths.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status', '1st_Visit' AS 'Visit_Type', 'Negative' AS 'SCRN_Results', sort_order
FROM (
(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

        from obs o
				-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
				  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
				  AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247))
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				 INNER JOIN person_name ON person.person_id = person_name.person_id
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
                 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						-- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)
						
						
						  
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)

                          -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)						
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')
	   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4175
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  	   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')


UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4176
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  	   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4177
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  	   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4245
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
					 -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4246
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							 							  	   -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
		        -- HISTORY OF PREVIOUS RESULTD-- 1st time screened
						  AND o.person_id in 
							(
							select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2147
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages'	)	   
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.Id not in (
				SELECT os.person_id 
				FROM obs os
				WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
				AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
										)
and ARTCurrent_PrevMonths.Id not in (
	           select distinct patient.patient_id AS Id
	           from obs o
	                       -- CLIENTS NEWLY INITIATED ON ART
				INNER JOIN patient ON o.person_id = patient.patient_id													
				AND (o.concept_id = 2249 
				AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND patient.voided = 0 AND o.voided = 0)
AND ARTCurrent_PrevMonths.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
		)
AND ARTCurrent_PrevMonths.Id not in (
			select person_id 
			from person 
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)
ORDER BY ARTCurrent_PrevMonths.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status', 'ReScreened' AS 'Visit_Type', 'Positive' AS 'SCRN_Results', sort_order
FROM (
(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

        from obs o
				-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
				  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
				  AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247))
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				 INNER JOIN person_name ON person.person_id = person_name.person_id
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
                 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						  
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')
	   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							   --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
                     --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4175
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')


UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4176
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
                    --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4177
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4245
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
					  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4246
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
						 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
		        --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages'	)	   
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.Id not in (
				SELECT os.person_id 
				FROM obs os
				WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
				AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
										)
and ARTCurrent_PrevMonths.Id not in (
	           select distinct patient.patient_id AS Id
	           from obs o
	                       -- CLIENTS NEWLY INITIATED ON ART
				INNER JOIN patient ON o.person_id = patient.patient_id													
				AND (o.concept_id = 2249 
				AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND patient.voided = 0 AND o.voided = 0)
AND ARTCurrent_PrevMonths.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
		)
AND ARTCurrent_PrevMonths.Id not in (
			select person_id 
			from person 
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)
ORDER BY ARTCurrent_PrevMonths.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status', 'ReScreened' AS 'Visit_Type', 'Negative' AS 'SCRN_Results', sort_order
FROM (
(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

        from obs o
				-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
				  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
				  AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247))
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				 INNER JOIN person_name ON person.person_id = person_name.person_id
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
                 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						  
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')
	   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							   --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
                     --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4175
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')


UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4176
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
                    --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4177
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4245
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
					  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4246
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
						 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
		        --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages'	)	   
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.Id not in (
				SELECT os.person_id 
				FROM obs os
				WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
				AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
										)
and ARTCurrent_PrevMonths.Id not in (
	           select distinct patient.patient_id AS Id
	           from obs o
	                       -- CLIENTS NEWLY INITIATED ON ART
				INNER JOIN patient ON o.person_id = patient.patient_id													
				AND (o.concept_id = 2249 
				AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND patient.voided = 0 AND o.voided = 0)
AND ARTCurrent_PrevMonths.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
		)
AND ARTCurrent_PrevMonths.Id not in (
			select person_id 
			from person 
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)
ORDER BY ARTCurrent_PrevMonths.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status', 'Post_Tx_Follow_up' AS 'Visit_Type', 'Positive' AS 'SCRN_Results',  sort_order
FROM (
(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

        from obs o
				-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
				  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
				  AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247))
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				 INNER JOIN person_name ON person.person_id = person_name.person_id
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
                 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						  
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')
	   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							 
							 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	 
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
                       --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4175
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')


UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4176
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
                      --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
					          -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4177
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						    
							  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4245
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
					   --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4246
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
						   --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
		          --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (328) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages'	)	   
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.Id not in (
				SELECT os.person_id 
				FROM obs os
				WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
				AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
										)
and ARTCurrent_PrevMonths.Id not in (
	           select distinct patient.patient_id AS Id
	           from obs o
	                       -- CLIENTS NEWLY INITIATED ON ART
				INNER JOIN patient ON o.person_id = patient.patient_id													
				AND (o.concept_id = 2249 
				AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND patient.voided = 0 AND o.voided = 0)
AND ARTCurrent_PrevMonths.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
		)
AND ARTCurrent_PrevMonths.Id not in (
			select person_id 
			from person 
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)
ORDER BY ARTCurrent_PrevMonths.Age)
UNION
(SELECT patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, Gender, age_group, 'Seen_Prev_Months' AS 'Program_Status', 'Post_Tx_Follow_up' AS 'Visit_Type', 'Negative' AS 'SCRN_Results',  sort_order
FROM (
(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

        from obs o
				-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
				  AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) AND patient.voided = 0 AND o.voided = 0 
				  AND (o.concept_id = 4174 and (o.value_coded = 4176 or o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247))
                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
				 INNER JOIN person_name ON person.person_id = person_name.person_id
				 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
                 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  
						  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						  
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4177 or o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
							 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to negative results -- Rescreened after previous negative
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1016
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')
	   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4245 or o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0			 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							 
							 --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	 
           WHERE observed_age_group.report_group_name = 'HIV_ages')

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and (o.value_coded = 4246 or o.value_coded = 4247)
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
						
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
				-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
                 INNER JOIN patient ON o.person_id = patient.patient_id 
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
                       --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		

UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4175
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')


UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4176
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
                      --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
					          -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4177
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
						  --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						    
							  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')
		   
UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4245
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
								
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
					   --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						
						      -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
							  
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4246
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28	
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
							  
						   --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						      -- VIA -VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages')



UNION

(select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(o.obs_datetime, person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
								   observed_age_group.sort_order AS sort_order

                from obs o
                 INNER JOIN patient ON o.person_id = patient.patient_id
					 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
					 AND patient.voided = 0 AND o.voided = 0 
					 AND o.concept_id = 4174 and o.value_coded = 4247
					 AND o.person_id in (
						select distinct os.person_id from obs os
						where 
							MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
							AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
							AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
					 )
					 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0				 
					 INNER JOIN person_name ON person.person_id = person_name.person_id
					 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
					 INNER JOIN reporting_age_group AS observed_age_group ON
							  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							  AND Gender = 'F' AND datediff(CURDATE(),person.birthdate) >= 15
		          --  not the first type of visit 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4513 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)
						
						 --  second visit due to POSITIVE results  --  POST TREATMENT FOLLOWUP 
						  AND o.person_id in 
								(
							   select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4515 and os.value_coded = 1738
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)   
						
						  -- VIA +VE
						 AND o.person_id in
						 
						   (
						 select distinct yo.person_id from obs yo inner join concept_name on yo.value_coded = concept_name.concept_id              
						 where yo.concept_id = 327 and yo.value_coded in (329) and yo.voided = 0  
						 and concept_name.name != 'sn VIA +ve' and concept_name.name != 'sn VIA -ve'
						)	
           WHERE observed_age_group.report_group_name = 'HIV_ages'	)	   
		   
) AS ARTCurrent_PrevMonths
 
WHERE ARTCurrent_PrevMonths.Id not in (
				SELECT os.person_id 
				FROM obs os
				WHERE (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
				AND (DATE(os.obs_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
										)
and ARTCurrent_PrevMonths.Id not in (
	           select distinct patient.patient_id AS Id
	           from obs o
	                       -- CLIENTS NEWLY INITIATED ON ART
				INNER JOIN patient ON o.person_id = patient.patient_id													
				AND (o.concept_id = 2249 
				AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
				AND patient.voided = 0 AND o.voided = 0)
AND ARTCurrent_PrevMonths.Id not in (
				select distinct os.person_id 
				from obs os
				where os.concept_id = 4155 and os.value_coded = 2146
		)
AND ARTCurrent_PrevMonths.Id not in (
			select person_id 
			from person 
			where death_date < CAST('#endDate#' AS DATE)
			and dead = 1
			)
ORDER BY ARTCurrent_PrevMonths.Age)




