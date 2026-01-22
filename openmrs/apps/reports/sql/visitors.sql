SELECT patientIdentifier as Patient_Identifier
     , patientName as Patient_Name
     , Gender 
     , Age
     , age_group as Age_Group
     , encounter_date as Date_Seen
     , follow_up as Follow_up
     , regimen_name as Regimen_Name
     , Days_Dispensed as Drugs_Durations

FROM 
(SELECT Id, patientIdentifier, patientName, Gender, Age, age_group, encounter_date, follow_up, regimen_name, Days_Dispensed
FROM
(select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id in (
							-- Visitor
							select distinct os.person_id from obs os
							where os.concept_id = 5416
							AND os.value_coded = 1 and os.voided = 0
							AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )	

						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages')visitors


left outer JOIN
-- encounter date

		(select a.person_id, CAST(SUBSTRING(MAX(CONCAT(a.obs_datetime, b.value_datetime)), 20) AS DATE) AS follow_up, Max(CAST(a.obs_datetime AS DATE)) as encounter_date
			from obs a, obs b
			where a.person_id = b.person_id
			and a.concept_id = 3753
			and b.concept_id = 3752
			and a.obs_id = b.obs_group_id
			-- and a.obs_datetime = b.obs_datetime
			and a.obs_datetime <= cast('#endDate#'as date)
			group by a.person_id
			
	)encounter
ON visitors.Id = encounter.person_id

left outer join
(
-- regimen
select distinct a.person_id, 
case 
when ARV_regimen = 2201 then '1c'
when ARV_regimen = 2203 then '1d'
when ARV_regimen = 2205 then '1e'
when ARV_regimen = 2207 then '1f'
when ARV_regimen = 3672 then '1g'
when ARV_regimen = 3673 then '1h'
when ARV_regimen = 4678 then '1j'
when ARV_regimen = 4679 then '1k'
when ARV_regimen = 4680 then '1m'
when ARV_regimen = 4681 then '1n'
when ARV_regimen = 4682 then '1p'
when ARV_regimen = 4683 then '1q'
when ARV_regimen = 2143 then 'other'
when ARV_regimen = 2210 then '2c'
when ARV_regimen = 2209 then '2d'
when ARV_regimen = 3674 then '2e'
when ARV_regimen = 3675 then '2f'
when ARV_regimen = 3676 THEN "2g"
when ARV_regimen = 3677 THEN "2h"
when ARV_regimen = 3678 THEN "2i"
when ARV_regimen = 4689 THEN "2j"
when ARV_regimen = 4690 THEN "2k"
when ARV_regimen = 4691 THEN "2L"
when ARV_regimen = 4692 THEN "2m"
when ARV_regimen = 4693 THEN "2n"
when ARV_regimen = 4694 THEN "2o"
when ARV_regimen = 4695 THEN "2p"
when ARV_regimen = 4849 THEN "2q"
when ARV_regimen = 4850 THEN "2r"
when ARV_regimen = 4851 THEN "2s"
when ARV_regimen = 3683 THEN "3a"
when ARV_regimen = 3684 THEN "3b"
when ARV_regimen = 3685 THEN "3c"
when ARV_regimen = 4706 THEN "3d"
when ARV_regimen = 4707 THEN "3e"
when ARV_regimen = 4708 THEN "3f"
when ARV_regimen = 4709 THEN "3g"
when ARV_regimen = 4710 THEN "3h"
when ARV_regimen = 2202 THEN "4c"
when ARV_regimen = 2204 THEN "4d"
when ARV_regimen = 3679 THEN "4e"
when ARV_regimen = 3680 THEN "4f"
when ARV_regimen = 4684 THEN "4g"
when ARV_regimen = 4685 THEN "4h"
when ARV_regimen = 4686 THEN "4j"
when ARV_regimen = 4687 THEN "4k"
when ARV_regimen = 4688 THEN "4L"
when ARV_regimen = 3681 THEN "5a"
when ARV_regimen = 3682 THEN "5b"
when ARV_regimen = 4696 THEN "5c"
when ARV_regimen = 4697 THEN "5d"
when ARV_regimen = 4698 THEN "5e"
when ARV_regimen = 4699 THEN "5f"
when ARV_regimen = 4700 THEN "5g"
when ARV_regimen = 4701 THEN "5h"
when ARV_regimen = 3686 THEN "6a"
when ARV_regimen = 3687 THEN "6b"
when ARV_regimen = 4702 THEN "6c"
when ARV_regimen = 4703 THEN "6d"
when ARV_regimen = 4704 THEN "6e"
when ARV_regimen = 4705 THEN "6f"
when ARV_regimen = 4714 THEN "1a"
when ARV_regimen = 4715 THEN "1b"
else 'NewRegimen' end as regimen_name
from obs a
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
		on latest.person_id = a.person_id
) regimen
ON visitors.Id = regimen.person_id

left outer join

(select o.person_id, value_numeric as Days_Dispensed
		from obs o
		-- Drugs days dispensed
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
				from obs where concept_id = 5416 and value_coded = 1
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as latest_vl_result
			on latest_vl_result.person_id = o.person_id
			where o.concept_id = 3730 
			and o.obs_datetime = max_observation
 )dispensed_days
 ON visitors.Id = dispensed_days.person_id
)visitors_seen