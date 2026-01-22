Select Distinct Patient_Identifier, Patient_Name, Age, age_group, Gender,Referral_Date, TB_Start_Date, Outcome_Date,Outcome, HIVStatus
from
(Select distinct Id, patientIdentifier as Patient_Identifier , patientName as Patient_Name, Age, age_group, Gender, sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order
					from obs o
					--  MDR_TB
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 5502
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)as mdr
Left Outer Join
-- TB Start Date
(select o.person_id,CAST(tb_start_date AS DATE) as TB_Start_Date
	from obs o 
	inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as tb_start_date
     from obs oss
     where oss.concept_id = 2237 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest 
  on latest.person_id = o.person_id
  where o.concept_id = 2237 and o.voided = 0
  and  o.obs_datetime = max_observation 
  ) as tb_start_date
On mdr.Id = tb_start_date.person_id
Left Outer Join
-- Outcome
(
	Select Person_Id, Outcome
	From(
	select distinct patient.patient_id AS Person_Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order,
						case
						when o.value_coded = 1068 then "Cured"
						when o.value_coded = 2242 then "Completed"
						when o.value_coded = 5661 then "Deceased"
						when o.value_coded = 3793 then "Failed Treatment"
						when o.value_coded = 2302 then "Lost to Follow-up"
						else "N/A" 
						end AS Outcome
					from obs o
					--  TB Outcome
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 5660
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) as outcomes

) As Outcome
On mdr.Id = Outcome.Person_Id
Left Outer Join
-- Outcome Date
(select o.person_id,CAST(latest_outcome_date AS DATE) as Outcome_Date
	from obs o 
	inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as latest_outcome_date
     from obs oss
     where oss.concept_id = 5658 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest 
  on latest.person_id = o.person_id
  where o.concept_id = 5658 and o.voided = 0
  and  o.obs_datetime = max_observation 
  ) as Outcome_Date
On mdr.Id = Outcome_Date.person_id
Left Outer Join
-- Referall_Date
(select o.person_id,CAST(latest_referral_date AS DATE) as Referral_Date
	from obs o 
	inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as latest_referral_date
     from obs oss
     where oss.concept_id = 5848 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest 
  on latest.person_id = o.person_id
  where o.concept_id = 5848 and o.voided = 0
  and  o.obs_datetime = max_observation 
  ) as Referral_Date
On mdr.Id = Referral_Date.person_id
Left Outer Join
(
	Select Person_Id, HIVStatus
	From(
	select distinct patient.patient_id AS Person_Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order,
						case
						when o.value_coded = 1738 then "Positive"
						when o.value_coded = 1016 then "Negative"
						when o.value_coded = 1739 then "Unknown"
						else "N/A" 
						end AS HIVStatus
					from obs o
					--  HIV Status
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4521
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) as status

) As HIVStatus
On mdr.Id = HIVStatus.Person_Id
Group by mdr.Id