SELECT regimen_name AS regimen_name,
	IF(Id is null, 0,SUM(IF(Weight_ >=0  and Weight_ <4.0 AND Age < 15,1,0))) AS "0-3.9kg",
    IF(Id is null, 0,SUM(IF(Weight_ >=4.0  and Weight_ <6.0 AND Age < 15,1,0))) AS "4-5.9kg",
    IF(Id is null, 0,SUM(IF(Weight_ >=6.0  and Weight_ <10.0 AND Age < 15,1,0))) AS "6-9.9kg",
    IF(Id is null, 0,SUM(IF(Weight_ >=10.0  and Weight_ <14 AND Age < 15,1,0))) AS "10-13.9kg",
	IF(Id is null, 0,SUM(IF(Weight_ >=14.0  and Weight_ <20 AND Age < 15,1,0))) AS "14-19.9kg",
	IF(Id is null, 0,SUM(IF(Weight_ >=20.0  and Weight_ <25 AND Age < 15,1,0))) AS "20-24.9kg",
	IF(Id is null, 0,SUM(IF(Weight_ >=25.0  and Weight_ <35 AND Age < 15,1,0))) AS "25-34.9kg",
	IF(Id is null, 0,SUM(IF(Weight_ >=35.0  AND Age < 15,1,0))) AS ">=35kg"

FROM 

(select Id, Age, Weight_,
case 
when ARV_regimen = 2202 then '4c=AZT-3TC-NVP'
when ARV_regimen = 2204 then '4d=AZT-3TC-EFV'
when ARV_regimen = 3679 then '4e=ABC-3TC-NVP'
when ARV_regimen = 3680 then '4f=ABC-3TC-EFV'
when ARV_regimen = 4684 then '4g=AZT-3TC-LPV/r'
when ARV_regimen = 4685 then '4h=ABC-3TC-LPV/r'
when ARV_regimen = 4686 then '4j=TDF-3TC-DTG (TLD)'
when ARV_regimen = 4687 then '4k=ABC-3TC-DTG'
when ARV_regimen = 4688 then '4l=AZT-3TC-DTG'
else 'Other' end as regimen_name
FROM
(Select Id, Age, ARV_regimen, Weight_
FROM
((Select Id, Age
	FROM
(Select Id, Age
	FROM
	(select distinct patient.patient_id AS Id, 
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

 (Select Id, Age
	FROM
	(select distinct patient.patient_id AS Id,
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


LEFT OUTER JOIN 

(select o.person_id,value_numeric as Weight_
		from obs o 
		inner join 
				(select person_id,max(obs_datetime) maxdate 
				from obs a
				where obs_datetime <= '#endDate#'
				and concept_id = 119
				group by person_id 
				)latest 
			on latest.person_id = o.person_id
			where concept_id = 119
			and  o.obs_datetime = maxdate	
			)weight
		on Seen_and_Seen_Prev.Id = weight.person_id)txcurr_with_weight

where ARV_regimen in (2202,2204,3679,3680,4684,4685,4686,4687,4688)

UNION
SELECT '','','','4c=AZT-3TC-NVP'
UNION
SELECT '','','','4d=AZT-3TC-EFV'
UNION
SELECT '','','','4e=ABC-3TC-NVP'
UNION
SELECT '','','','4f=ABC-3TC-EFV'
UNION
SELECT '','','','4g=AZT-3TC-LPV/r'
UNION
SELECT '','','','4h=ABC-3TC-LPV/r'
UNION
SELECT '','','','4j=TDF-3TC-DTG (TLD)'
UNION
SELECT '','','','4k=ABC-3TC-DTG'
UNION
SELECT '','','','4l=AZT-3TC-DTG'
UNION
SELECT '','','','Other'


)txcurr_with_regimen
Group by regimen_name