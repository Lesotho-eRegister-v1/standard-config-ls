SELECT patientIdentifier, TB_Number,patientName, Age, age_group, Gender,TB_History,Key_Populations, HIV_Status, HIV_Management,Prevention_of_OIs,Treatment_Outcome
FROM
(Select distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group, Gender
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						pi2.identifier AS TB_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order 
					from obs o
					--  TB Clients 
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type in (7)
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.person_id in (
								 --
						select tb_clients.person_id
								from
								(select B.person_id, B.obs_group_id, B.value_datetime AS tb_start_date
									from obs B
									inner join 
									(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs where concept_id = 4153 -- TB Intake form
									and obs_datetime <= cast('#endDate#' as date)
									and voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 2237 -- TB Start Date
									and CAST(value_datetime as DATE)>= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -12 MONTH) 
									and CAST(value_datetime as DATE)<= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) as tb_clients
						)
						AND o.person_id not in (
                        select distinct os.person_id 
                            from obs os
                                -- Patient must not be a tranfer in	
                            where os.concept_id = 3772 and os.value_coded =2095
                        	AND cast(os.obs_datetime as date) >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -12 MONTH) 
							AND cast(os.obs_datetime as date) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
                        	AND os.voided = 0
                        )
						
)tb_started_year_ago

)tb_started

Left Outer Join
(
-- Type of patient
 select o.person_id,case
 when o.value_coded = 1034 then "New Patient"
 when o.value_coded = 1084 then "Relapse"
 when o.value_coded = 3786 then "Treatment after LTFU"
 when o.value_coded = 1037 then "Treatment after failure"
 else "" 
end AS TB_History
from obs o
where o.concept_id = 3785 and o.voided = 0
AND cast(o.obs_datetime as date) >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -12 MONTH) 
AND cast(o.obs_datetime as date) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
Group by o.person_id
) risk
on tb_started.Id = risk.person_id

Left Outer Join
(
-- High Risk Population
 select o.person_id,case
 when o.value_coded = 3669 then "Factory worker"
 when o.value_coded = 3667 then "Miner"
 when o.value_coded = 3670 then "Health Worker"
 when o.value_coded = 3777 then "Household member of current miner"
 when o.value_coded = 3778 then "Household member of ex miner"
 when o.value_coded = 3779 then "Prison Staff"
 when o.value_coded = 3671 then "Prisoner"
 when o.value_coded = 3668 then "Ex-miner"
 when o.value_coded = 4654 then "Public Transport"
 when o.value_coded = 4919 then "Contact of DRTB patient"
else "" 
end AS Key_Populations
from obs o
where o.concept_id = 3776 and o.voided = 0
and o.person_id in (
		select o.person_id
		from obs o
		where o.concept_id = 2237 -- TB Start Date
		and o.voided = 0
		and o.value_datetime >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -12 MONTH) 
		and o.value_datetime <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
		group by o.person_id
			)
Group by o.person_id
)key_pop
on tb_started.Id = key_pop.person_id

-- HIV STATUS	
left outer join
	(
	select person_id, value_coded as Status_Code
	from obs where concept_id = 4666 and voided = 0
	)Status

	inner join
	(
		select concept_id, name AS HIV_Status
			from concept_name 
				where name in ("Known Positive", "Known Negative", "New Positive", "New Negative") 
				and voided = 0
	) concept_name
	on concept_name.concept_id = Status.Status_Code 

on tb_started.Id = Status.person_id 

Left Outer Join
(
-- HIV Management
 select o.person_id,case
 when o.value_coded = 4669 then "New ART"
 when o.value_coded = 4670 then "Already on ART"
else "" 
end AS HIV_Management
from obs o
where o.concept_id = 4667 and o.voided = 0
and o.person_id in (
		select o.person_id
		from obs o
		where o.concept_id = 2237 -- TB Start Date
		and o.voided = 0
		and cast(o.value_datetime as date) >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -12 MONTH) 
		and cast(o.value_datetime as date) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
		group by o.person_id
			)
Group by o.person_id
)hiv_management
on tb_started.Id = hiv_management.person_id

Left Outer Join
(
-- Prevention of OIs
 select o.person_id,case
 when o.value_coded = 2330 then "Provided CPT"
 when o.value_coded = 4619 then "Dapsone"
else "N/A" 
end AS Prevention_of_OIs
from obs o
where o.concept_id = 5415 and o.voided = 0
Group by o.person_id
) prevention
on tb_started.Id = prevention.person_id

Left Outer Join
(
-- TB Treatment Outcome
 select o.person_id,o.value_coded, case
 when o.value_coded = 1068 then "Cured"
 when o.value_coded = 2242 then "Completed"
 when o.value_coded = 3650 then "Died"
 when o.value_coded = 2302 then "Lost to Follow-up"
 when o.value_coded = 3793 then "Failed treatment"
 when o.value_coded = 3794 then "Failed treatment and is resistant"
else "N/A" 
end AS Treatment_Outcome
from obs o
where o.concept_id = 3792 and o.voided = 0
Group by o.person_id
) outcome
on tb_started.Id = outcome.person_id

