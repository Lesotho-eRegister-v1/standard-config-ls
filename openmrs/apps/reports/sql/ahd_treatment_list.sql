SELECT patientIdentifier , patientName, Age, Gender, age_group, Regimen_Name
FROM
((SELECT  Id, patientIdentifier , patientName, Age, Gender, age_group, 'Initiated' AS 'Program_Status', sort_order
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
						 AND (o.concept_id = 2249 

						AND MONTH(o.value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
						AND YEAR(o.value_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							and os.voided = 0
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
ORDER BY Newly_Initiated_ART_Clients.patientName)

UNION

(SELECT Id, patientIdentifier , patientName , Age, Gender, age_group, 'Seen' AS 'Program_Status', sort_order
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
								 AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
								 AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
									  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
           WHERE observed_age_group.report_group_name = 'Modified_Ages'

) AS Clients_Seen

WHERE Clients_Seen.Id not in (
		select distinct patient.patient_id AS Id
		from obs o
				-- CLIENTS INITIATED ON ART
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
							and os.voided = 0
							AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )	

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
													where concept_id = 3752 and os.voided = 0
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
										where os.concept_id=2266 and os.voided = 0
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
														where concept_id = 3752 and os.voided = 0
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
											and voided = 0	
						)
					)

ORDER BY Clients_Seen.patientName)

)Tx_Curr

INNER JOIN

(SELECT person_id, Regimen_Name
FROM
(-- AHD given - Liposomal Amphotericin B and Flucytosine
(select os.person_id, 'Liposomal Amphotericin B and Flucytosine' AS 'Regimen_Name'
		from obs os
		where os.concept_id = 4958 and os.value_coded = 2146
		and os.voided = 0
		and os.person_id in(
				select person_id 
				-- given Liposomal Amphotericin B and Flucytosine
				from obs o 
				where o.concept_id = 4952 and o.value_coded = 4948
				and MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
				and YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
				and o.voided = 0
			))
		
	UNION

-- AHD given Amphotericin B Deoxycholate and Flucytosine
(select os.person_id, 'Amphotericin B Deoxycholate and Flucytosine' AS 'Regimen_Name'
		from obs os
		where os.concept_id = 4958 and os. value_coded = 2146
		and os.voided = 0
		and os.person_id in(
				select person_id 
				-- given Amphotericin B Deoxycholate and Flucytosine
				from obs o 
				where o.concept_id = 4952 and o.value_coded = 4949
				and MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
				and YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
				and o.voided = 0
			))

	UNION

-- AHD given Fluconazole and Flucytosine
(select os.person_id, 'Fluconazole and Flucytosine' AS 'Regimen_Name'
		from obs os
		where os.concept_id = 4958 and os.value_coded = 2146
		and os.voided = 0
		and os.person_id in(
				select person_id 
				-- given Fluconazole and Flucytosine
				from obs o 
				where o.concept_id = 4952 and o.value_coded = 4950
				and MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
				and YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
				and o.voided = 0
			))

	UNION

-- AHD given Amphotericin B Deoxycholate and Fluconazole
(select os.person_id, 'Amphotericin B Deoxycholate and Fluconazole' AS 'Regimen_Name'
		from obs os
		where os.concept_id = 4958 and os.value_coded = 2146
		and os.voided = 0
		and os.person_id in(
				select person_id 
				-- given Amphotericin B Deoxycholate and Fluconazole
				from obs o 
				where o.concept_id = 4952 and o.value_coded = 4951
				and MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
				and YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
				and o.voided = 0
			))
)Regimen)RegName
ON Tx_Curr.Id = RegName.person_id