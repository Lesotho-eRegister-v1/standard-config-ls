
Select Patient_Identifier, Patient_Name, Sex, Age, Age_Group,Collection_Date_And_Time,Requesting_Facility_Name,Reason_for_VL_Test,Sample_Processing_Date, Result, Date_Results_Sent, Initials_Of_a_HealthWorker
from(
Select Id,patientIdentifier as Patient_Identifier, patientName as Patient_Name, Sex, Age, age_group as Age_Group,Requesting_Facility_Name,Reason_for_VL_Test, Collection_Date_And_Time,Sample_Processing_Date,Result,Date_Results_Sent, Initials_Of_a_HealthWorker, sort_order
from
(select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Sex,
                observed_age_group.name AS age_group,
                observed_age_group.sort_order AS sort_order

            from obs o
            -- HIV POC Viral Load
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.concept_id = 	6052
                    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    LEFT JOIN patient_identifier pi2 ON pi2.patient_id = person.person_id AND pi2.identifier_type in (5,12)
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') as poc 
Left Join
(
    SELECT o.person_id, cn.name AS Requesting_Facility_Name
    FROM obs o
    JOIN concept_name cn ON o.value_coded = cn.concept_id
    JOIN encounter e ON o.encounter_id = e.encounter_id
    WHERE o.concept_id = 2251
    AND o.voided = 0
    AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
    AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
)facility
On poc.Id = facility.person_id

Left Join
(
  select o.person_id,
  case
  when o.value_coded = 6056 then 'Birth'
  when o.value_coded = 6057 then '7 days'
  when o.value_coded = 6058 then '10 - 14 weeks'
  when o.value_coded = 6044 then '9 months'
  end as Reason_for_VL_Test
  from obs o
  where o.concept_id = 6060
  and o.voided = 0
  AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
  AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)reason
On poc.Id = reason.person_id

Left Outer Join
(select o.person_id,latest_collection_date as Collection_Date_And_Time
	from obs o 
	inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as latest_collection_date
     from obs oss
     where oss.concept_id = 6039 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest 
  on latest.person_id = o.person_id
  where concept_id = 6039
  and  o.obs_datetime = max_observation 
  ) as dateCollected
On poc.Id = dateCollected.person_id

Left Outer Join
(select distinct o.person_id, CAST(latest_processing_date as DATE) as Sample_Processing_Date
	from obs o 
	inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as latest_processing_date
     from obs oss
     where oss.concept_id = 6040 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest 
  on latest.person_id = o.person_id
  where concept_id = 6040
  and  o.obs_datetime = max_observation 
  ) as dateProcessed
On poc.Id = dateCollected.person_id

Left Join 
(
  select distinct o.person_id, 
  case
  when o.value_coded = 1738 then 'Positive'
  when o.value_coded = 1016 then 'Negative'
  when o.value_coded = 6047 then 'Invalid'
  end as Result
  from obs o
  where o.concept_id = 6054
  and o.voided = 0
 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
  AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
  Group by person_id

)result
On poc.Id = result.person_id

Left Outer Join
(select distinct o.person_id, CAST(latest_resultSent_date as DATE) as Date_Results_Sent
	from obs o 
	inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as latest_resultSent_date
     from obs oss
     where oss.concept_id = 6053 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest 
  on latest.person_id = o.person_id
  where concept_id = 6053
  and  o.obs_datetime = max_observation 

  ) as dateResultsSent
  On poc.Id = dateResultsSent.person_id

Left Join
(
SELECT distinct o.person_id, CONCAT(SUBSTRING(pn.given_name, 1, 1), SUBSTRING(pn.family_name, 1, 1)) AS Initials_Of_a_HealthWorker
FROM encounter e
JOIN users u ON e.creator = u.user_id
JOIN person p ON u.person_id = p.person_id
JOIN person_name pn ON p.person_id = pn.person_id
JOIN obs o ON e.encounter_id = o.encounter_id
where o.concept_id = 6052
AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
Group by person_id
)Initials
On poc.Id = Initials.person_id

)as A
Group by A.Id