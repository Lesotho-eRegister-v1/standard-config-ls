SELECT PREP_TOTALS_COLS_ROWS.AgeGroup
		, PREP_TOTALS_COLS_ROWS.Continuation_Males
		, PREP_TOTALS_COLS_ROWS.Continuation_Females
		, PREP_TOTALS_COLS_ROWS.New_Males
		, PREP_TOTALS_COLS_ROWS.New_Females
		, PREP_TOTALS_COLS_ROWS.Total

FROM (

			(SELECT PREP_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'PrEP_Continuation' AND PREP_STATUS_DRVD_ROWS.Gender = 'M',1 , 0))) AS Continuation_Males
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'PrEP_Continuation' AND PREP_STATUS_DRVD_ROWS.Gender = 'F',1 , 0))) AS Continuation_Females
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'PrEP_New' AND PREP_STATUS_DRVD_ROWS.Gender = 'M',1 , 0))) AS New_Males	
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Program_Status = 'PrEP_New' AND PREP_STATUS_DRVD_ROWS.Gender = 'F',1 , 0))) AS New_Females		
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(1)) AS Total
						, PREP_STATUS_DRVD_ROWS.sort_order
			FROM (

			SELECT Id, patientIdentifier , patientName, Age, Gender, age_group, 'PrEP_Continuation' AS 'Program_Status', Location, sort_order
			FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order,
									   l.name AS Location

                from obs o
						-- CLIENTS CONTINUING PrEP
						inner join patient ON o.person_id = patient.patient_id 
						and (o.concept_id = 5029
								and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						     )
					    and patient.voided = 0 and o.voided = 0

						and o.person_id not in 
						(
							 -- PrEP NEW
							select distinct os.person_id 
							from obs os
								where os.concept_id = 4994
								and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								and os.voided = 0
						)	

						and o.person_id not in 
						(
							 -- Stopped PrEP
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5005
								and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								and os.voided = 0
						)
											 
						 inner join person ON person.person_id = patient.patient_id and person.voided = 0
						 inner join location l on o.location_id = l.location_id  and l.retired=0
						 inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
						 inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
						 inner join reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                where observed_age_group.report_group_name = 'Modified_Ages') AS PrEP_Seen
-- ORDER BY PrEP_Seen.patientName

			UNION

			SELECT Id, patientIdentifier , patientName, Age, Gender, age_group, 'PrEP_New' AS 'Program_Status', Location, sort_order
				FROM
							(select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order,
									   l.name AS Location

                from obs o
						-- CLIENTS NEWLY INITIATED
						inner join patient ON o.person_id = patient.patient_id 
						and (o.concept_id = 4994
								and CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						     )
					    and patient.voided = 0 and o.voided = 0
						and o.person_id not in 
						(
							 -- TRANSFER INN
							select distinct os.person_id 
							from obs os
							where os.concept_id = 5070
							and os.value_coded = 2146
						)	
						and o.person_id not in 
						(
							 -- HAS BEEN ON PrEP BEFORE
							select distinct os.person_id 
							from obs os
							where os.concept_id = 5003 and os.value_coded = 1
						 )						 
						 inner join person ON person.person_id = patient.patient_id and person.voided = 0
						 inner join location l on o.location_id = l.location_id  and l.retired=0
						 inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
						 inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
						 inner join reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                where observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_Clients

			) AS PREP_STATUS_DRVD_ROWS

			GROUP BY PREP_STATUS_DRVD_ROWS.age_group, PREP_STATUS_DRVD_ROWS.Gender
			ORDER BY PREP_STATUS_DRVD_ROWS.sort_order)
			
			
	UNION ALL

		(SELECT 'Total' AS 'AgeGroup'
			, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'PrEP_Continuation' AND PREP_STATUS_DRVD_COLS.Gender = 'M',1 , 0))) AS Continuation_Males
						, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'PrEP_Continuation' AND PREP_STATUS_DRVD_COLS.Gender = 'F',1 , 0))) AS Continuation_Females
						, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'PrEP_New' AND PREP_STATUS_DRVD_COLS.Gender = 'M',1 , 0))) AS New_Males	
						, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Program_Status = 'PrEP_New' AND PREP_STATUS_DRVD_COLS.Gender = 'F',1 , 0))) AS New_Females		
						, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(1)) AS Total
					, 99 AS sort_order
		FROM (
				
			SELECT Id, patientIdentifier , patientName, Age, Gender, age_group, 'PrEP_Continuation' AS 'Program_Status', Location, sort_order
			FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order,
									   l.name AS Location

                from obs o
						-- CLIENTS CONTINUING PrEP
						inner join patient ON o.person_id = patient.patient_id 
						and (o.concept_id = 5029
								and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						     )
					    and patient.voided = 0 and o.voided = 0

						and o.person_id not in 
						(
							 -- PrEP NEW
							select distinct os.person_id 
							from obs os
								where os.concept_id = 4994
								and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								and os.voided = 0
						)	

						and o.person_id not in 
						(
							 -- Stopped PrEP
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5005
								and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
								and os.voided = 0
						)
											 
						 inner join person ON person.person_id = patient.patient_id and person.voided = 0
						 inner join location l on o.location_id = l.location_id  and l.retired=0
						 inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
						 inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
						 inner join reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                where observed_age_group.report_group_name = 'Modified_Ages') AS PrEP_Seen
-- ORDER BY PrEP_Seen.patientName

			UNION

			SELECT Id, patientIdentifier , patientName, Age, Gender, age_group, 'PrEP_New' AS 'Program_Status', Location, sort_order
				FROM
							(select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order,
									   l.name AS Location

                from obs o
						-- CLIENTS NEWLY INITIATED
						inner join patient ON o.person_id = patient.patient_id 
						and (o.concept_id = 4994
								and CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						     )
					    and patient.voided = 0 and o.voided = 0
						and o.person_id not in 
						(
							 -- TRANSFER INN
							select distinct os.person_id 
							from obs os
							where os.concept_id = 5070
							and os.value_coded = 2146
						)	
						and o.person_id not in 
						(
							 -- HAS BEEN ON PrEP BEFORE
							select distinct os.person_id 
							from obs os
							where os.concept_id = 5003 and os.value_coded = 1
						 )						 
						 inner join person ON person.person_id = patient.patient_id and person.voided = 0
						 inner join location l on o.location_id = l.location_id  and l.retired=0
						 inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
						 inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
						 inner join reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                where observed_age_group.report_group_name = 'Modified_Ages') AS Newly_Initiated_Clients
			) AS PREP_STATUS_DRVD_COLS
		)
		
	) AS PREP_TOTALS_COLS_ROWS
ORDER BY PREP_TOTALS_COLS_ROWS.sort_order

