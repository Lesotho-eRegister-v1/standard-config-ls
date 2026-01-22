SELECT patientName as 'Patient Name', patientIdentifier as 'Patient Identifier', Age, Gender, Outcome, Key_Populations
FROM
(SELECT id, patientName, patientIdentifier, Age, Gender, Outcome
FROM
(
-- Cured
(select id, patientName, patientIdentifier, Age, Gender, Outcome
from 
(
	select patient.patient_id AS Id,
		   patient_identifier.identifier AS patientIdentifier,
		   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		   person.gender AS Gender,
		   'Cured' as 'Outcome'
		   
	from obs o
	
	INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON o.person_id = person_name.person_id
	where o.concept_id = 3792 and o.value_coded = 1068
	and o.obs_datetime >= CAST('#startDate#' AS DATE)
    and o.obs_datetime <= CAST('#endDate#'AS DATE)
	)as a
)

UNION

-- Completed
(select id, patientName, patientIdentifier, Age, Gender, Outcome
from 
(
	select patient.patient_id AS Id,
		   patient_identifier.identifier AS patientIdentifier,
		   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		   person.gender AS Gender,
		   'Completed' as 'Outcome'
		   
	from obs o
	
	INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON o.person_id = person_name.person_id
	where concept_id = 3792 and value_coded = 2242
	and obs_datetime >= CAST('#startDate#' AS DATE)
    and obs_datetime <= CAST('#endDate#'AS DATE)
) as b)

UNION

-- Died
(select id, patientName, patientIdentifier, Age, Gender, Outcome
from 
(
	select patient.patient_id AS Id,
		   patient_identifier.identifier AS patientIdentifier,
		   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		   person.gender AS Gender,
		   'Died' as 'Outcome'
		   
	from obs o
	
	INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON o.person_id = person_name.person_id
	where concept_id = 3792 and value_coded = 3650
	and obs_datetime >= CAST('#startDate#' AS DATE)
    and obs_datetime <= CAST('#endDate#'AS DATE)
) as b)

UNION

-- Lost to Followup
(select id, patientName, patientIdentifier, Age, Gender, Outcome
from 
(
	select patient.patient_id AS Id,
		   patient_identifier.identifier AS patientIdentifier,
		   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		   person.gender AS Gender,
		   'LTFU' as 'Outcome'
		   
	from obs o
	
	INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON o.person_id = person_name.person_id
	where concept_id = 3792 and value_coded = 2302
	and obs_datetime >= CAST('#startDate#' AS DATE)
    and obs_datetime <= CAST('#endDate#'AS DATE)
) as b)

UNION

-- Failed
(select id, patientName, patientIdentifier, Age, Gender, Outcome
from 
(
	select patient.patient_id AS Id,
		   patient_identifier.identifier AS patientIdentifier,
		   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		   person.gender AS Gender,
		   'Failed' as 'Outcome'
		   
	from obs o
	
	INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON o.person_id = person_name.person_id
	where concept_id = 3792 and value_coded = 3793
	and obs_datetime >= CAST('#startDate#' AS DATE)
    and obs_datetime <= CAST('#endDate#'AS DATE)
) as b)

UNION

-- Transferred to 2nd Line
(select id, patientName, patientIdentifier, Age, Gender, Outcome
from 
(
	select patient.patient_id AS Id,
		   patient_identifier.identifier AS patientIdentifier,
		   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
		   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
		   person.gender AS Gender,
		   'Moved_to_2ndLine' as 'Outcome'
		   
	from obs o
	
	INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
	INNER JOIN patient ON o.person_id = patient.patient_id 
	INNER JOIN patient_identifier ON patient_identifier.patient_id = o.person_id AND patient_identifier.identifier_type = 3
	INNER JOIN person_name ON o.person_id = person_name.person_id
	where concept_id = 3792 and value_coded = 3650
	and obs_datetime >= CAST('#startDate#' AS DATE)
    and obs_datetime <= CAST('#endDate#'AS DATE)
) as b)
)Outcome)Outcomes

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
else "N/A" 
end AS Key_Populations
from obs o
where o.concept_id = 3776 and o.voided = 0
and o.person_id in (
		select o.person_id
		from obs o
		where o.concept_id = 2237 and o.voided = 0
		and o.value_datetime >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -12 MONTH) 
		and o.value_datetime <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
		group by o.person_id
			)
Group by o.person_id
) risk
on Outcomes.Id = risk.person_id










