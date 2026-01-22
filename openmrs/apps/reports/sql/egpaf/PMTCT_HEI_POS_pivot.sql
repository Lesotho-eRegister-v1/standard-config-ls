SELECT PMTCT_STATUS_DRVD_COLS_ROWS.AgeGroup
		, PMTCT_STATUS_DRVD_COLS_ROWS.Gender
		, PMTCT_STATUS_DRVD_COLS_ROWS.Total

FROM (

			(SELECT PMTCT_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					, PMTCT_STATUS_DRVD_ROWS.Gender
						, IF(PMTCT_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PMTCT_STATUS_DRVD_ROWS.PMTCT_Status = 'PMTCT_Pos', 1, 0))) as 'Total'
						, PMTCT_STATUS_DRVD_ROWS.sort_order
			FROM (
					SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, 'PMTCT_POS' AS 'PMTCT_Status', age_group,sort_order
					FROM
					(SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
					FROM (
					SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order 
							FROM
							(
					SELECT DISTINCT patient.patient_id AS Id,
									patient_identifier.identifier AS patientIdentifier,
									concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
									person.gender AS Gender,
									observed_age_group.name AS age_group,
									observed_age_group.sort_order AS sort_order,
									o.obs_datetime,
									cast(o.value_datetime as date) as Date_Sample_Taken

					FROM obs o
					INNER JOIN patient ON o.person_id = patient.patient_id 
						AND patient.voided = 0 AND o.voided = 0
						AND concept_id = 4575
						-- First DNA PCR
						-- Date Sample Taken for First DNA PCR
						inner join 
							(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
								from obs 
							where concept_id = 4569
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
							group by person_id
							) as A
							on A.observation_id = o.obs_group_id					
						-- HIV Exposed Infants with HIV Positive Status
						AND o.person_id in (
											select distinct os.person_id 
												from obs os
												where os.concept_id = 4578 and value_coded = 1738
												and os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												and patient.voided = 0 AND o.voided = 0
											)									 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
								and o.voided = 0
								and CAST(o.value_datetime as date) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime as date) <= CAST('#endDate#' AS DATE)
								having Age <= 12
					)As First_NAT_Test_6_weeks
					-- where Age <= 12

					left outer join 
					(
						Select distinct person_id, concat(Age_at_Test, ' ', 'weeks') as Age_at_Test
							FROM
							(select distinct o.person_id, value_numeric as Age_at_Test
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4569
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 4570 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)Age_test  
					)test_age
					on test_age.person_id = First_NAT_Test_6_weeks.Id

					left outer join 
					(
						Select distinct person_id, ART_Start_Date
							FROM
							(select distinct o.person_id, cast(o.value_datetime as date) as ART_Start_Date
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4596
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 1734 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)ART_initiation  
					)ART_Initiation
					on ART_Initiation.person_id = First_NAT_Test_6_weeks.Id

					)AS First_NAT_Test


					UNION


					SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
					FROM (
					SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
							FROM
							(
					SELECT DISTINCT patient.patient_id AS Id,
									patient_identifier.identifier AS patientIdentifier,
									concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
									person.gender AS Gender,
									observed_age_group.name AS age_group,
									observed_age_group.sort_order AS sort_order,
									o.obs_datetime,
									cast(o.value_datetime as date) as Date_Sample_Taken

					FROM obs o
					INNER JOIN patient ON o.person_id = patient.patient_id 
						AND patient.voided = 0 AND o.voided = 0
						AND concept_id = 4575
						-- First DNA PCR
						-- Date Sample Taken for First DNA PCR
						inner join 
							(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
								from obs 
							where concept_id = 4588
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
							group by person_id
							) as A
							on A.observation_id = o.obs_group_id					
						-- HIV Exposed Infants with HIV Positive Status
						AND o.person_id in (
											select distinct os.person_id 
												from obs os
												where os.concept_id = 4578 and value_coded = 1738
												and os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												and patient.voided = 0 AND o.voided = 0
											)									 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
								and o.voided = 0
								and CAST(o.value_datetime as date) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime as date) <= CAST('#endDate#' AS DATE)
								having Age <= 12
					)As First_NAT_Test_6_weeks

					left outer join 
					(
						Select distinct person_id, concat(Age_at_Test, ' ', 'months') as Age_at_Test
							FROM
							(select distinct o.person_id, value_numeric as Age_at_Test
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4588
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 4570 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)Age_test  
					)test_age
					on test_age.person_id = First_NAT_Test_6_weeks.Id

					left outer join 
					(
						Select distinct person_id, ART_Start_Date
							FROM
							(select distinct o.person_id, cast(o.value_datetime as date) as ART_Start_Date
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4596
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 1734 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)ART_initiation  
					)ART_Initiation
					on ART_Initiation.person_id = First_NAT_Test_6_weeks.Id

					)AS Repeat_NAT_Test



					UNION


					SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
					FROM (
					SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
							FROM
							(
					SELECT DISTINCT patient.patient_id AS Id,
									patient_identifier.identifier AS patientIdentifier,
									concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
									person.gender AS Gender,
									observed_age_group.name AS age_group,
									observed_age_group.sort_order AS sort_order,
									o.obs_datetime,
									cast(o.value_datetime as date) as Date_Sample_Taken

					FROM obs o
					INNER JOIN patient ON o.person_id = patient.patient_id 
						AND patient.voided = 0 AND o.voided = 0
						AND concept_id = 4575
						-- First DNA PCR
						-- Date Sample Taken for First DNA PCR
						inner join 
							(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
								from obs 
							where concept_id = 5095
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
							group by person_id
							) as A
							on A.observation_id = o.obs_group_id					
						-- HIV Exposed Infants with HIV Positive Status
						AND o.person_id in (
											select distinct os.person_id 
												from obs os
												where os.concept_id = 4578 and value_coded = 1738
												and os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												and patient.voided = 0 AND o.voided = 0
											)									 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
								and o.voided = 0
								and CAST(o.value_datetime as date) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime as date) <= CAST('#endDate#' AS DATE)
								having Age <= 12
					)As First_NAT_Test_6_weeks

					left outer join 
					(
						Select distinct person_id, concat(Age_at_Test, ' ', 'months') as Age_at_Test
							FROM
							(select distinct o.person_id, value_numeric as Age_at_Test
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 5095
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 4570 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)Age_test  
					)test_age
					on test_age.person_id = First_NAT_Test_6_weeks.Id

					left outer join 
					(
						Select distinct person_id, ART_Start_Date
							FROM
							(select distinct o.person_id, cast(o.value_datetime as date) as ART_Start_Date
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4596
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 1734 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)ART_initiation  
					)ART_Initiation
					on ART_Initiation.person_id = First_NAT_Test_6_weeks.Id

					)AS Second_NAT_Test
					)NAT_Test


			) AS PMTCT_STATUS_DRVD_ROWS

			GROUP BY PMTCT_STATUS_DRVD_ROWS.age_group, PMTCT_STATUS_DRVD_ROWS.Gender
			ORDER BY PMTCT_STATUS_DRVD_ROWS.sort_order)
			
			
	UNION ALL

			(
					SELECT 'Total' AS 'AgeGroup'
							, 'All' AS 'Gender'		
						, IF(PMTCT_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PMTCT_STATUS_DRVD_COLS.PMTCT_Status = 'PMTCT_Pos', 1, 0))) as 'Total'
						, 99 AS sort_order
			FROM (
					SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, 'PMTCT_POS' AS 'PMTCT_Status', age_group,sort_order
					FROM
					(SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
					FROM (
					SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order 
							FROM
							(
					SELECT DISTINCT patient.patient_id AS Id,
									patient_identifier.identifier AS patientIdentifier,
									concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
									person.gender AS Gender,
									observed_age_group.name AS age_group,
									observed_age_group.sort_order AS sort_order,
									o.obs_datetime,
									cast(o.value_datetime as date) as Date_Sample_Taken

					FROM obs o
					INNER JOIN patient ON o.person_id = patient.patient_id 
						AND patient.voided = 0 AND o.voided = 0
						AND concept_id = 4575
						-- First DNA PCR
						-- Date Sample Taken for First DNA PCR
						inner join 
							(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
								from obs 
							where concept_id = 4569
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
							group by person_id
							) as A
							on A.observation_id = o.obs_group_id					
						-- HIV Exposed Infants with HIV Positive Status
						AND o.person_id in (
											select distinct os.person_id 
												from obs os
												where os.concept_id = 4578 and value_coded = 1738
												and os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												and patient.voided = 0 AND o.voided = 0
											)									 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
								and o.voided = 0
								and CAST(o.value_datetime as date) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime as date) <= CAST('#endDate#' AS DATE)
								having Age <= 12
					)As First_NAT_Test_6_weeks

					left outer join 
					(
						Select distinct person_id, concat(Age_at_Test, ' ', 'weeks') as Age_at_Test
							FROM
							(select distinct o.person_id, value_numeric as Age_at_Test
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4569
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 4570 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)Age_test  
					)test_age
					on test_age.person_id = First_NAT_Test_6_weeks.Id

					left outer join 
					(
						Select distinct person_id, ART_Start_Date
							FROM
							(select distinct o.person_id, cast(o.value_datetime as date) as ART_Start_Date
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4596
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 1734 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)ART_initiation  
					)ART_Initiation
					on ART_Initiation.person_id = First_NAT_Test_6_weeks.Id

					)AS First_NAT_Test


					UNION


					SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
					FROM (
					SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
							FROM
							(
					SELECT DISTINCT patient.patient_id AS Id,
									patient_identifier.identifier AS patientIdentifier,
									concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
									person.gender AS Gender,
									observed_age_group.name AS age_group,
									observed_age_group.sort_order AS sort_order,
									o.obs_datetime,
									cast(o.value_datetime as date) as Date_Sample_Taken

					FROM obs o
					INNER JOIN patient ON o.person_id = patient.patient_id 
						AND patient.voided = 0 AND o.voided = 0
						AND concept_id = 4575
						-- First DNA PCR
						-- Date Sample Taken for First DNA PCR
						inner join 
							(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
								from obs 
							where concept_id = 4588
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
							group by person_id
							) as A
							on A.observation_id = o.obs_group_id					
						-- HIV Exposed Infants with HIV Positive Status
						AND o.person_id in (
											select distinct os.person_id 
												from obs os
												where os.concept_id = 4578 and value_coded = 1738
												and os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												and patient.voided = 0 AND o.voided = 0
											)									 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
								and o.voided = 0
								and CAST(o.value_datetime as date) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime as date) <= CAST('#endDate#' AS DATE)
								having Age <= 12
					)As First_NAT_Test_6_weeks

					left outer join 
					(
						Select distinct person_id, concat(Age_at_Test, ' ', 'months') as Age_at_Test
							FROM
							(select distinct o.person_id, value_numeric as Age_at_Test
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4588
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 4570 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)Age_test  
					)test_age
					on test_age.person_id = First_NAT_Test_6_weeks.Id

					left outer join 
					(
						Select distinct person_id, ART_Start_Date
							FROM
							(select distinct o.person_id, cast(o.value_datetime as date) as ART_Start_Date
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4596
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 1734 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)ART_initiation  
					)ART_Initiation
					on ART_Initiation.person_id = First_NAT_Test_6_weeks.Id

					)AS Repeat_NAT_Test



					UNION


					SELECT Id, Patient_Identifier, Patient_Name, Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
					FROM (
					SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, Gender, Age_at_Test, Date_Sample_Taken, ART_Start_Date, age_group,sort_order
							FROM
							(
					SELECT DISTINCT patient.patient_id AS Id,
									patient_identifier.identifier AS patientIdentifier,
									concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									concat(floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/30), ' ', 'months') as Age,
									person.gender AS Gender,
									observed_age_group.name AS age_group,
									observed_age_group.sort_order AS sort_order,
									o.obs_datetime,
									cast(o.value_datetime as date) as Date_Sample_Taken

					FROM obs o
					INNER JOIN patient ON o.person_id = patient.patient_id 
						AND patient.voided = 0 AND o.voided = 0
						AND concept_id = 4575
						-- First DNA PCR
						-- Date Sample Taken for First DNA PCR
						inner join 
							(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
								from obs 
							where concept_id = 5095
							and obs_datetime <= cast('#endDate#' as date)
							and voided = 0
							group by person_id
							) as A
							on A.observation_id = o.obs_group_id					
						-- HIV Exposed Infants with HIV Positive Status
						AND o.person_id in (
											select distinct os.person_id 
												from obs os
												where os.concept_id = 4578 and value_coded = 1738
												and os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
												and patient.voided = 0 AND o.voided = 0
											)									 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN reporting_age_group AS observed_age_group ON
								CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
								WHERE observed_age_group.report_group_name = 'Modified_Ages'
								and o.voided = 0
								and CAST(o.value_datetime as date) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime as date) <= CAST('#endDate#' AS DATE)
								having Age <= 12
					)As First_NAT_Test_6_weeks

					left outer join 
					(
						Select distinct person_id, concat(Age_at_Test, ' ', 'months') as Age_at_Test
							FROM
							(select distinct o.person_id, value_numeric as Age_at_Test
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 5095
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 4570 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)Age_test  
					)test_age
					on test_age.person_id = First_NAT_Test_6_weeks.Id

					left outer join 
					(
						Select distinct person_id, ART_Start_Date
							FROM
							(select distinct o.person_id, cast(o.value_datetime as date) as ART_Start_Date
									from obs o
									
									inner join
										(select distinct person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
											from obs where concept_id = 4596
											and obs_datetime <= cast('#endDate#' as date)
											and voided = 0
											group by person_id) as 6weeks_test
										on 6weeks_test.person_id = o.person_id
										where o.concept_id = 1734 
										and o.obs_datetime = max_observation
										and o.voided = 0
										)ART_initiation  
					)ART_Initiation
					on ART_Initiation.person_id = First_NAT_Test_6_weeks.Id

					)AS Second_NAT_Test
					)NAT_Test


			) AS PMTCT_STATUS_DRVD_COLS)
		
	) AS PMTCT_STATUS_DRVD_COLS_ROWS
ORDER BY PMTCT_STATUS_DRVD_COLS_ROWS.sort_order

