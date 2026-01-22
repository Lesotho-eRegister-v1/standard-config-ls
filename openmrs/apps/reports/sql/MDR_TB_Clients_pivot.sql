SELECT Total_Aggregated_Mdr.AgeGroup
		, Total_Aggregated_Mdr.Cured_Males
		, Total_Aggregated_Mdr.Cured_Females
		, Total_Aggregated_Mdr.Completed_Males
		, Total_Aggregated_Mdr.Completed_Females
		, Total_Aggregated_Mdr.Deceased_Males
		, Total_Aggregated_Mdr.Deceased_Females
		, Total_Aggregated_Mdr.Failed_Males
		, Total_Aggregated_Mdr.Failed_Females
        , Total_Aggregated_Mdr.Lost_to_Follow_Males
		, Total_Aggregated_Mdr.Lost_to_Follow_Females
        , Total_Aggregated_Mdr.Not_Evaluated_Males
		, Total_Aggregated_Mdr.Not_Evaluated_Females

FROM

(
	(SELECT MDR_DETAILS.age_group AS 'AgeGroup'
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Cured' AND MDR_DETAILS.Gender = 'M', 1, 0))) AS Cured_Males
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Cured' AND MDR_DETAILS.Gender = 'F', 1, 0))) AS Cured_Females
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Completed' AND MDR_DETAILS.Gender = 'M', 1, 0))) AS Completed_Males
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Completed' AND MDR_DETAILS.Gender = 'F', 1, 0))) AS Completed_Females
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Deceased' AND MDR_DETAILS.Gender = 'M', 1, 0))) AS Deceased_Males
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Deceased' AND MDR_DETAILS.Gender = 'F', 1, 0))) AS Deceased_Females
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Failed_Treatment' AND MDR_DETAILS.Gender = 'M', 1, 0))) AS Failed_Males
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Failed_Treatment' AND MDR_DETAILS.Gender = 'F', 1, 0))) AS Failed_Females
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Lost_to_Follow_up' AND MDR_DETAILS.Gender = 'M', 1, 0))) AS Lost_to_Follow_Males
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Lost_to_Follow_up' AND MDR_DETAILS.Gender = 'F', 1, 0))) AS Lost_to_Follow_Females
            , IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Not_Evaluated' AND MDR_DETAILS.Gender = 'M', 1, 0))) AS Not_Evaluated_Males
			, IF(MDR_DETAILS.Id IS NULL, 0, SUM(IF(MDR_DETAILS.Outcome = 'Not_Evaluated' AND MDR_DETAILS.Gender = 'F', 1, 0))) AS Not_Evaluated_Females
			, MDR_DETAILS.sort_order
			
	FROM

	(
	
Select Distinct Id, Patient_Identifier, Patient_Name, Age, age_group, Gender,Referral_Date, TB_Start_Date, Outcome_Date,Outcome, HIVStatus, sort_order
from
(Select distinct Id, patientIdentifier as Patient_Identifier , patientName as Patient_Name, Age, age_group, Gender, sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('2023-08-31' AS DATE), person.birthdate)/365) AS Age,
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
						CAST('2023-08-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 5502
						AND CAST(o.obs_datetime AS DATE) >= CAST('2023-08-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2023-08-31' AS DATE)
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
     and oss.obs_datetime < cast('2023-08-31' as date)
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
						floor(datediff(CAST('2023-08-31' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order,
						case
						when o.value_coded = 1068 then "Cured"
						when o.value_coded = 2242 then "Completed"
						when o.value_coded = 5661 then "Deceased"
						when o.value_coded = 3793 then "Failed_Treatment"
						when o.value_coded = 2302 then "Lost_to_Follow_up"
                        when o.value_coded = 5556 then "Not_Evaluated"
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
						CAST('2023-08-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 5660
						AND CAST(o.obs_datetime AS DATE) >= CAST('2023-08-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2023-08-31' AS DATE)
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
     and oss.obs_datetime < cast('2023-08-31' as date)
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
     and oss.obs_datetime < cast('2023-08-31' as date)
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
						floor(datediff(CAST('2023-08-31' AS DATE), person.birthdate)/365) AS Age,
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
						CAST('2023-08-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4521
						AND CAST(o.obs_datetime AS DATE) >= CAST('2023-08-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2023-08-31' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) as status

) As HIVStatus
On mdr.Id = HIVStatus.Person_Id
Group by mdr.Id
	) AS MDR_DETAILS

	GROUP BY MDR_DETAILS.age_group
	ORDER BY MDR_DETAILS.sort_order)

UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Cured' AND Totals.Gender = 'M', 1, 0))) AS 'Cured_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Cured' AND Totals.Gender = 'F', 1, 0))) AS 'Cured_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Completed' AND Totals.Gender = 'M', 1, 0))) AS 'Completed_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Completed' AND Totals.Gender = 'F', 1, 0))) AS 'Completed_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Deceased' AND Totals.Gender = 'M', 1, 0))) AS 'Deceased_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Deceased' AND Totals.Gender = 'F', 1, 0))) AS 'Deceased_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Failed_Treatment' AND Totals.Gender = 'M', 1, 0))) AS 'Failed_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Failed_Treatment' AND Totals.Gender = 'F', 1, 0))) AS 'Failed_Females'
        , IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Lost_to_Follow_up' AND Totals.Gender = 'M', 1, 0))) AS 'Lost_to_Follow_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Lost_to_Follow_up' AND Totals.Gender = 'F', 1, 0))) AS 'Lost_to_Follow_Females'
        , IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Not_Evaluated' AND Totals.Gender = 'M', 1, 0))) AS 'Not_Evaluated_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Outcome = 'Not_Evaluated' AND Totals.Gender = 'F', 1, 0))) AS 'Not_Evaluated_Females'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_Mdr.Id
					, Total_Mdr.Patient_Identifier
					, Total_Mdr.Patient_Name
					, Total_Mdr.Age
					, Total_Mdr.Gender
					, Total_Mdr.Outcome
				
		FROM

		(

		Select Distinct Id, Patient_Identifier, Patient_Name, Age, age_group, Gender,Referral_Date, TB_Start_Date, Outcome_Date,Outcome, HIVStatus, sort_order
from
(Select distinct Id, patientIdentifier as Patient_Identifier , patientName as Patient_Name, Age, age_group, Gender, sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('2023-08-31' AS DATE), person.birthdate)/365) AS Age,
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
						CAST('2023-08-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 5502
						AND CAST(o.obs_datetime AS DATE) >= CAST('2023-08-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2023-08-31' AS DATE)
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
     and oss.obs_datetime < cast('2023-08-31' as date)
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
						floor(datediff(CAST('2023-08-31' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order,
						case
						when o.value_coded = 1068 then "Cured"
						when o.value_coded = 2242 then "Completed"
						when o.value_coded = 5661 then "Deceased"
						when o.value_coded = 3793 then "Failed_Treatment"
						when o.value_coded = 2302 then "Lost_to_Follow_up"
                        when o.value_coded = 5556 then "Not_Evaluated"
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
						CAST('2023-08-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 5660
						AND CAST(o.obs_datetime AS DATE) >= CAST('2023-08-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2023-08-31' AS DATE)
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
     and oss.obs_datetime < cast('2023-08-31' as date)
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
     and oss.obs_datetime < cast('2023-08-31' as date)
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
						floor(datediff(CAST('2023-08-31' AS DATE), person.birthdate)/365) AS Age,
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
						CAST('2023-08-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 4521
						AND CAST(o.obs_datetime AS DATE) >= CAST('2023-08-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2023-08-31' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) as status

) As HIVStatus
On mdr.Id = HIVStatus.Person_Id
Group by mdr.Id
		) AS Total_Mdr
  ) AS Totals
 )
) AS Total_Aggregated_Mdr
ORDER BY Total_Aggregated_Mdr.sort_order