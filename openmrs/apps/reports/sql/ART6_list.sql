SELECT Patient_Identifier, Patient_Name, Age, Gender, age_group, VL_result
FROM
(SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, age_group,VL_Results_Status, sort_order
FROM (
	

		(SELECT DISTINCT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, age_group, 'Received' AS 'VL_Results_Status', sort_order
		FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('2023-12-31' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
                                               o.value_datetime AS Date_Specimen_Collected,
											   observed_age_group.sort_order AS sort_order

						from obs o

						      
                                 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4266
                                 AND patient.voided = 0 AND o.voided = 0

								--  CLients with with viral load results
								 AND o.person_id in (
                                    Select Id
                                    from(
                                    select Id, max_observation,latest_vl_result
                                    from
                                    (
                                        select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) AS latest_vl_result
                                        from obs oss
                                        where oss.concept_id = 4266 -- VL test result
                                        and oss.voided=0
                                        and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('2023-12-31' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('2023-12-31' as datetime), interval 1 day)
                                        group by oss.person_id
                                    )As VL_result

                                    UNION

                                    select Id, max_observation,latest_vl_result
                                    from(select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.concept_id)), 20) AS latest_vl_result
                                                    from obs oss
                                                    where oss.concept_id = 5485 and oss.voided=0 -- from DISA
                                                    and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('2023-12-31' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('2023-12-31' as datetime), interval 1 day)
                                                    and oss.value_numeric < 1000
                                                    group by oss.person_id

                                    ) As Lab_Copies

                                    UNION

                                    select Id, max_observation,latest_vl_result
                                    from(select oss.person_id as Id, MAX(oss.obs_datetime) as max_observation, SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.concept_id)), 20) AS latest_vl_result
                                                    from obs oss
                                                    where oss.concept_id = 5489 and oss.voided=0 -- from DISA
                                                    and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('2023-12-31' AS DATE), INTERVAL -12 MONTH)) AND date_add(cast('2023-12-31' as datetime), interval 1 day)
                                                    group by oss.person_id

                                    ) As LDL
                                    )all_results
                                 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('2023-12-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						  	 WHERE observed_age_group.report_group_name = 'Modified_Ages'
								) AS viral_loadClients_status
		ORDER BY viral_loadClients_status.Age)


) AS viral_load_status
)received_results

-- results
inner join
(SELECT distinct person_id, VL_result
From
((select o.person_id, max_observation, "Undetectable" as "VL_result"
	from obs o
	inner join
		(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
			from obs where concept_id = 4273
			and obs_datetime <= cast('2023-12-31' as date)
			and voided = 0
			-- Viral Load Undetectable
			group by person_id) as latest_vl_result
		on latest_vl_result.person_id = o.person_id
		where o.concept_id = 4266 and o.value_coded = 4263
        and o.obs_datetime = max_observation
        and o.voided = 0
			)

UNION

(select o.person_id, max_observation, "Less than 20" as "VL_result"
	from obs o
	inner join
		(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
			from obs where concept_id = 4273
			and obs_datetime <= cast('2023-12-31' as date)
			and voided = 0
			-- Viral Load < 20
			group by person_id) as latest_vl_result
		on latest_vl_result.person_id = o.person_id
		where o.concept_id = 4266 and o.value_coded = 4264
		and o.obs_datetime = max_observation
        and o.voided = 0
		 )

UNION

(Select greater_than_20.person_id, max_observation, Viral_Load
from
(select o.person_id, max_observation
from obs o
inner join
	(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		from obs where concept_id = 4273
		and obs_datetime <= cast('2023-12-31' as date)
		and voided = 0
		-- Viral Load >=20
		group by person_id) as latest_vl_result
	on latest_vl_result.person_id = o.person_id
	where o.concept_id = 4266 and o.value_coded = 4265
	and o.obs_datetime = max_observation
    and o.voided = 0) greater_than_20
	inner join 
	(select o.person_id, value_numeric as Viral_load
		from obs o
		-- Viral Load copies per ml recorded
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
				from obs where concept_id = 4273
				and obs_datetime <= cast('2023-12-31' as date)
				and voided = 0
				group by person_id) as latest_vl_result
			on latest_vl_result.person_id = o.person_id
			where o.concept_id = 2254 
			and o.obs_datetime = max_observation
            and o.voided = 0
		 )numeric_value
	on greater_than_20.person_id = numeric_value.person_id
		 )
)viral_load_result	
	)results
ON received_results.Id = results.person_id

ORDER BY 2