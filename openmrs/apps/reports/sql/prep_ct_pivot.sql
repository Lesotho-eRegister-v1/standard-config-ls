
SELECT Total_Aggregated_Cases.Age_Group
		, Total_Aggregated_Cases.Males_Seen
		, Total_Aggregated_Cases.Females_Seen
		, Total_Aggregated_Cases.Total
FROM

(
	(SELECT prep_status.Age_Group AS 'Age_Group',
			IF(prep_status.Id IS NULL, 0, SUM(IF(Program_Status = 'PrEP_Continuation' AND Gender = 'M', 1, 0))) AS Males_Seen,
			IF(prep_status.Id IS NULL, 0, SUM(IF(Program_Status = 'PrEP_Continuation' AND Gender = 'F', 1, 0))) AS Females_Seen,
			IF(prep_status.Id IS NULL, 0, SUM(IF(Program_Status = 'PrEP_Continuation', 1, 0))) AS Total,
			prep_status.sort_order
			
			
	FROM(
		SELECT Id,patientIdentifier, patientName, Age, Gender, age_group, Program_Status, Location,sort_order
		from

	(SELECT Id,patientIdentifier , patientName, Age, Gender, age_group, 'PrEP_Continuation' AS 'Program_Status', Location,sort_order
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
ORDER BY PrEP_Seen.patientName)as prep )AS prep_status

	GROUP BY prep_status.Age_group
	Order by prep_status.sort_order)
	
	
UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'PrEP_Continuation' AND Gender = 'M', 1, 0))) AS 'Males_Seen'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'PrEP_Continuation' AND Gender = 'F', 1, 0))) AS 'Females_Seen'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Program_Status = 'PrEP_Continuation', 1, 0))) AS 'Total'
		, 99 AS 'sort_order'
FROM

		(SELECT  Total_prep_status.Id
					, Total_prep_status.Age
					, Total_prep_status.Program_Status
					, Total_prep_status.Gender
					, Total_prep_status.sort_order
				
		FROM

		(SELECT Id,patientIdentifier, patientName, Age, Gender, age_group, Program_Status, Location,sort_order
			from

		(SELECT Id,patientIdentifier , patientName, Age, Gender, age_group, 'PrEP_Continuation' AS 'Program_Status', Location,sort_order
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
ORDER BY PrEP_Seen.patientName)as prep) AS Total_prep_status
-- Order by Total_prep_status.sort_order
  ) AS Totals
 )
) AS Total_Aggregated_Cases
Order by Total_Aggregated_Cases.sort_order

