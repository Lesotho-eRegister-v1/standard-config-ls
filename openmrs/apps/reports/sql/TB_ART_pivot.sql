SELECT Total_Aggregated_TB_ART.AgeGroup
		, Total_Aggregated_TB_ART.New_Positive_Males
		, Total_Aggregated_TB_ART.New_Positive_Females
		, Total_Aggregated_TB_ART.Known_Positive_Males
		, Total_Aggregated_TB_ART.Known_Positive_Females
		, Total_Aggregated_TB_ART.New_ART_Males
		, Total_Aggregated_TB_ART.New_ART_Females
		, Total_Aggregated_TB_ART.Already_ART_Males
		, Total_Aggregated_TB_ART.Already_ART_Females
		, Total_Aggregated_TB_ART.Total

FROM

(
	(SELECT TB_ART_DETAILS.age_group AS 'AgeGroup'
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.HIV_Status = 'New Positive' AND TB_ART_DETAILS.Gender = 'M', 1, 0))) AS New_Positive_Males
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.HIV_Status = 'New Positive' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS New_Positive_Females
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.HIV_Status = 'Known Positive' AND TB_ART_DETAILS.Gender = 'M', 1, 0))) AS Known_Positive_Males
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.HIV_Status = 'Known Positive' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS Known_Positive_Females
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.HIV_Management = 'New ART' AND TB_ART_DETAILS.Gender = 'M', 1, 0))) AS New_ART_Males
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.HIV_Management = 'New ART' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS New_ART_Females
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.HIV_Management = 'Already on ART' AND TB_ART_DETAILS.Gender = 'M', 1, 0))) AS Already_ART_Males
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.HIV_Management = 'Already on ART' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS Already_ART_Females
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, TB_ART_DETAILS.sort_order
			
	FROM

	(
	
		SELECT distinct Id, patientIdentifier,TB_Number, patientName, Age,age_group, Gender,consultation_date, HIV_Status, HIV_Management, sort_order
 FROM (
(Select distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group, Gender, consultation_date, sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						pi2.identifier AS TB_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('2023-01-31' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order,
						o.obs_datetime as consultation_date

					from obs o
					--  TB Clients 
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type in (7)
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('2023-01-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id  = 4666 and o.value_coded in (4323, 4324)
						AND CAST(o.obs_datetime AS DATE) >= CAST('2023-01-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2023-01-31' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)

)diagnosis_type

left outer join

(select
       o.person_id,
       case
           when value_coded = 4323 then "New Positive"
           when value_coded = 4324 then "Known Positive"
           else ""
       end AS HIV_Status
from obs o
	inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4666 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('2023-01-31' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4666
	and  o.obs_datetime = max_observation
	) status
ON diagnosis_type.Id = status.person_id

left outer join

(select
       o.person_id,
       case
           when o.value_coded = 4669 then "New ART"
		   when o.value_coded = 4670 then "Already on ART"
           else ""
       end AS HIV_Management
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4667 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('2023-01-31' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4667
	and  o.obs_datetime = max_observation
	) Management
ON diagnosis_type.Id = Management.person_id
Group by diagnosis_type.patientIdentifier
	) AS TB_ART_DETAILS

	GROUP BY TB_ART_DETAILS.age_group
	ORDER BY TB_ART_DETAILS.sort_order)

UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Status = 'New Positive' AND Totals.Gender = 'M', 1, 0))) AS 'New_Positive_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Status = 'New Positive' AND Totals.Gender = 'F', 1, 0))) AS 'New_Positive_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Status = 'Known Positive' AND Totals.Gender = 'M', 1, 0))) AS 'Known_Positive_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Status = 'Known Positive' AND Totals.Gender = 'F', 1, 0))) AS 'Known_Positive_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Management = 'New ART' AND Totals.Gender = 'M', 1, 0))) AS 'New_ART_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Management = 'New ART' AND Totals.Gender = 'F', 1, 0))) AS 'New_ART_Females'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Management = 'Already ART' AND Totals.Gender = 'M', 1, 0))) AS 'Already_ART_Males'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.HIV_Management = 'Already ART' AND Totals.Gender = 'F', 1, 0))) AS 'Already_ART_Females'
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_TB_ART.Id
					, Total_TB_ART.patientIdentifier AS "Patient Identifier"
					, Total_TB_ART.patientName AS "Patient Name"
					, Total_TB_ART.Age
					, Total_TB_ART.Gender
					, Total_TB_ART.HIV_Status
					, Total_TB_ART.HIV_Management
				
		FROM

		(

			SELECT distinct Id, patientIdentifier,TB_Number, patientName, Age,age_group, Gender,consultation_date, HIV_Status, HIV_Management, sort_order
 FROM (
(Select distinct Id, TB_Number, patientIdentifier , patientName, Age, age_group, Gender, consultation_date, sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						pi2.identifier AS TB_Number,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('2023-01-31' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order,
						o.obs_datetime as consultation_date
					from obs o
					--  TB Clients 
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type in (7)
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('2023-01-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id  = 4666 and o.value_coded in (4323, 4324)
						AND CAST(o.obs_datetime AS DATE) >= CAST('2023-01-01' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('2023-01-31' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)

)diagnosis_type

left outer join

(select
       o.person_id,
       case
           when value_coded = 4323 then "New Positive"
           when value_coded = 4324 then "Known Positive"
           else ""
       end AS HIV_Status
from obs o
	inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4666 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('2023-01-31' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4666
	and  o.obs_datetime = max_observation
	) status
ON diagnosis_type.Id = status.person_id

left outer join

(select
       o.person_id,
       case
           when o.value_coded = 4669 then "New ART"
		   when o.value_coded = 4670 then "Already on ART"
           else ""
       end AS HIV_Management
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4667 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('2023-01-31' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4667
	and  o.obs_datetime = max_observation
	) Management
ON diagnosis_type.Id = Management.person_id
Group by diagnosis_type.patientIdentifier
		) AS Total_TB_ART
  ) AS Totals
 )
) AS Total_Aggregated_TB_ART
ORDER BY Total_Aggregated_TB_ART.sort_order