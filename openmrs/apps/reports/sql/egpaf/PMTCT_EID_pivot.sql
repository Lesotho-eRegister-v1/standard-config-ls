SELECT HEI_TOTALS_COLS_ROWS.AgeGroup as 'Age_at_Test'
		  , HEI_TOTALS_COLS_ROWS.Gender
      , HEI_TOTALS_COLS_ROWS.First_Tests as 'First Tests'
      , HEI_TOTALS_COLS_ROWS.Subsenquent_Tests as 'Subsequent Tests'
		  , HEI_TOTALS_COLS_ROWS.Total

FROM (

		(SELECT HEI_Status_Detailed.Age_at_Test AS AgeGroup
          , HEI_Status_Detailed.Gender
          , IF(HEI_Status_Detailed.Id IS NULL, 0, SUM(IF(HEI_Status_Detailed.Test_Sequence = 'First Test', 1, 0))) as First_Tests
          , IF(HEI_Status_Detailed.Id IS NULL, 0, SUM(IF(HEI_Status_Detailed.Test_Sequence = 'Subsequent Test', 1, 0))) as Subsenquent_Tests
          , IF(HEI_Status_Detailed.Id IS NULL, 0, SUM(1)) as 'Total'
          , HEI_Status_Detailed.sort_order

		FROM
		(SELECT Id, Patient_Identifier, Patient_Name, age_group, Age, Gender, Age_at_Test, Test_Sequence, Date_Sample_Taken, Test_Result, sort_order
			FROM

		(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age_, Age, Gender, age_group, sort_order, group_id
		FROM
						(select distinct patient.patient_id AS Id,
							patient_identifier.identifier AS patientIdentifier,
							concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Age_,
							concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
							person.gender AS Gender,
							o.obs_group_id as group_id,
							observed_age_group.name AS age_group,
							observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								 
                                 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id in (4569, 4588, 5095) -- First NAT test, Repeat NAT and Second NAT test at 9months
									AND cast(os.obs_datetime as date) >= CAST('#startDate#' AS DATE) 
									AND cast(os.obs_datetime as date) <= CAST('#endDate#' AS DATE)
									AND os.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- First NAT test, Repeat NAT and Second NAT test at 9months
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id in (4569, 4588, 5095)
								 )) AS HEIClients_Status
                   having Age_ <= 12   

) AS HEI_Status_Detailed

left outer join 

(Select person_id, obs_group_id, Test_Sequence, Age_at_Test
FROM(
(select o.person_id, value_numeric, o.obs_group_id, 'First Test' as Test_Sequence, "< 2months" as Age_at_Test
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        where concept_id = 4569 -- 6 weeks or first contact test done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4570 -- Age at test
            and o.voided = 0
			having value_numeric < 8
)

UNION

(select o.person_id, value_numeric, o.obs_group_id, 'First Test' as Test_Sequence, "2-12 months" as Age_at_Test
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        where concept_id = 4569 -- 6 weeks or first contact test done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4570 -- Age at test
            and o.voided = 0
			having value_numeric >= 8
)

UNION

(select o.person_id, value_numeric, o.obs_group_id,'Subsequent Test' as Test_Sequence, "2-12 months" as Age_at_Test
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        where concept_id in (4588, 5095) -- subsequent tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4587 -- Age at test
            and o.voided = 0
)
)tests
)test_age
on test_age.obs_group_id = HEI_Status_Detailed.group_id

left outer join 

(select o.person_id, cast(value_datetime as date) as Date_Sample_Taken, o.obs_group_id
		from obs o
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        		where concept_id in (4569, 4588, 5095) -- Tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id
				) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4575 -- Date sample taken
            and o.voided = 0
			order by 1
            )sample_date
on sample_date.obs_group_id = HEI_Status_Detailed.group_id

left outer join 

(select distinct o.person_id,
        case
           when value_coded = 1738 then "Positive"
           when value_coded = 1016 then "Negative"
           when value_coded = 4220 then "Indeterminate"
           else ""
       end AS Test_Result
from obs o
		inner join
			(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
        from obs where concept_id in (4569,4588, 5095)  -- Tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as test_result
			on test_result.person_id = o.person_id
			where o.concept_id = 4578 -- HEI Test Result
            and o.voided = 0
            )results
on results.person_id = HEI_Status_Detailed.Id
)HEI_Status_Detailed

GROUP BY HEI_Status_Detailed.Age_at_Test, HEI_Status_Detailed.Gender
ORDER BY HEI_Status_Detailed.sort_order)
			
			
UNION ALL

(SELECT 'Total' AS 'Age_at_Test'
, ' ' AS 'Gender' 
, IF(HEI_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HEI_STATUS_DRVD_COLS.Test_Sequence = 'First Test', 1, 0))) as 'First Tests'
, IF(HEI_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(HEI_STATUS_DRVD_COLS.Test_Sequence = 'Subsequent Test', 1, 0))) as 'Subsequent Tests'
, IF(HEI_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(1)) as 'Total'
			, 99 AS sort_order 
			FROM 
			
			(SELECT Id, Patient_Identifier, Patient_Name, age_group, Age, Gender, Age_at_Test, Test_Sequence, Date_Sample_Taken, Test_Result, sort_order
			
			FROM

		(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age_, Age, Gender, age_group, sort_order, group_id
		FROM
						(select distinct patient.patient_id AS Id,
							patient_identifier.identifier AS patientIdentifier,
							concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
							floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30) AS Age_,
							concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
							person.gender AS Gender,
							o.obs_group_id as group_id,
							observed_age_group.name AS age_group,
							observed_age_group.sort_order AS sort_order

						from obs o
								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND patient.voided = 0 AND o.voided = 0
								 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								 
                                 AND o.person_id in (
									select distinct os.person_id 
									from obs os
									where os.concept_id in (4569, 4588, 5095) -- First NAT test, Repeat NAT and Second NAT test at 9months
									AND cast(os.obs_datetime as date) >= CAST('#startDate#' AS DATE) 
									AND cast(os.obs_datetime as date) <= CAST('#endDate#' AS DATE)
									AND os.voided = 0
								 )
								 
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
								 -- First NAT test, Repeat NAT and Second NAT test at 9months
								 AND o.obs_group_id in (
									select og.obs_id from obs og where og.concept_id in (4569, 4588, 5095)
								 )) AS HEIClients_Status
                   having Age_ <= 12   


) AS HEI_Status_Detailed

left outer join 

(Select person_id, obs_group_id, Test_Sequence, Age_at_Test
FROM(
(select o.person_id, value_numeric, o.obs_group_id, 'First Test' as Test_Sequence, "< 2months" as Age_at_Test
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        where concept_id = 4569 -- 6 weeks or first contact test done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4570 -- Age at test
            and o.voided = 0
			having value_numeric < 8
)

UNION

(select o.person_id, value_numeric, o.obs_group_id, 'First Test' as Test_Sequence, "2-12 months" as Age_at_Test
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        where concept_id = 4569 -- 6 weeks or first contact test done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4570 -- Age at test
            and o.voided = 0
			having value_numeric >= 8
)

UNION

(select o.person_id, value_numeric, o.obs_group_id,'Subsequent Test' as Test_Sequence, "2-12 months" as Age_at_Test
		from obs o
		
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        where concept_id in (4588, 5095) -- subsequent tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4587 -- Age at test
            and o.voided = 0
)
)tests
)test_age
on test_age.obs_group_id = HEI_Status_Detailed.group_id

left outer join 

(select o.person_id, cast(value_datetime as date) as Date_Sample_Taken, o.obs_group_id
		from obs o
		inner join
			(select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id, obs_group_id
				from obs 
        		where concept_id in (4569, 4588, 5095) -- Tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id
				) as tests
			 on tests.person_id = o.person_id
			where o.concept_id = 4575 -- Date sample taken
            and o.voided = 0
			order by 1
            )sample_date
on sample_date.obs_group_id = HEI_Status_Detailed.group_id

left outer join 

(select distinct o.person_id,
        case
           when value_coded = 1738 then "Positive"
           when value_coded = 1016 then "Negative"
           when value_coded = 4220 then "Indeterminate"
           else ""
       end AS Test_Result
from obs o
		inner join
			(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
        from obs where concept_id in (4569,4588, 5095)  -- Tests done by age 12 months
				and obs_datetime <= cast('#endDate#' as date)
				and voided = 0
				group by person_id) as test_result
			on test_result.person_id = o.person_id
			where o.concept_id = 4578 -- HEI Test Result
            and o.voided = 0
            )results
on results.person_id = HEI_Status_Detailed.Id
)AS HEI_STATUS_DRVD_COLS
		)
		
	) AS HEI_TOTALS_COLS_ROWS
ORDER BY HEI_TOTALS_COLS_ROWS.sort_order

