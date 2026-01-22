
-- Add more filters to the reports. on all report groups

SELECT PREP_TOTALS_COLS_ROWS.AgeGroup
		, PREP_TOTALS_COLS_ROWS.Gender
		, PREP_TOTALS_COLS_ROWS.SW
		, PREP_TOTALS_COLS_ROWS.MSM
		, PREP_TOTALS_COLS_ROWS.Transgender
		, PREP_TOTALS_COLS_ROWS.PWID
		, PREP_TOTALS_COLS_ROWS.Other
		, PREP_TOTALS_COLS_ROWS.Total_Initiated

FROM (

			(SELECT PREP_STATUS_DRVD_ROWS.age_group AS 'AgeGroup'
					, PREP_STATUS_DRVD_ROWS.Gender
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.prep_group = 'SW',1 , 0))) AS SW
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.prep_group = 'MSM',1 , 0))) AS MSM
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.prep_group = 'Transgender',1 , 0))) AS Transgender	
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.prep_group = 'PWID',1 , 0))) AS PWID			
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.prep_group = 'Other',1 , 0))) AS Other
						, IF(PREP_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_ROWS.Initiated = 'Initiated', 1, 0))) as 'Total_Initiated'
						, PREP_STATUS_DRVD_ROWS.sort_order
			FROM (

			SELECT distinct Id, patientIdentifier , patientName, Age, Gender, age_group, 'Initiated' AS 'Initiated',Entry_Point,Entry_Point_level_facility,Entry_Point_level_community,ifnull(prep_group,'other') as prep_group,sort_order, Location
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
						-- CLIENTS NEWLY INITIATED ON PREP
						inner join patient ON o.person_id = patient.patient_id 
						and o.concept_id = 4994
						and CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						and CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)

						and patient.voided = 0 
						and o.voided = 0

						and o.person_id not in 
						(
							 -- TRANSFER INN
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5070
								and os.value_coded = 2146
								and CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)	
						and o.person_id not in 
						(
							 -- HAS BEEN ON PrEP BEFORE
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5003
								and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
						 inner join person ON person.person_id = patient.patient_id and person.voided = 0
						 inner join location l on o.location_id = l.location_id  and l.retired=0
						 inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
						 inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
						 inner join reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                	where observed_age_group.report_group_name = 'Modified_Ages'
					AND floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) >= 10  
				) AS Newly_Initiated_Clients

				left outer join (
					
						select distinct patient.patient_id ,
										CASE 
											WHEN o.value_coded = 4981 THEN 'Community'
											WHEN o.value_coded = 4982 THEN 'Health Facility'
											ELSE 'non selected'
										END AS 'Entry_Point'

               			 from obs o
						 -- PREP CLIENT INITIATED : COMMUNITY AND FACILITY
						 
			     		 inner join patient ON o.person_id = patient.patient_id 		
						 AND o.voided = 0									 
						 AND o.concept_id = 4980 AND o.value_coded IN (4982, 4981)
						 and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						 and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 inner join person ON person.person_id = patient.patient_id and person.voided = 0
						 inner join location l on o.location_id = l.location_id  and l.retired=0
						 inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
						 inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
						 inner join reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
        		        where observed_age_group.report_group_name = 'Modified_Ages'
					)ENTRY_POINT
					
					ON Newly_Initiated_Clients.Id = ENTRY_POINT.patient_id

					left outer join
						
						(
							select distinct patient.patient_id ,
							case 
							when o.value_coded = 4987 THEN 'Adolescent Corner'
							when o.value_coded = 4988 THEN 'ANC/PNC'
							when o.value_coded = 4989 THEN 'ART'
							when o.value_coded = 4990 THEN 'OPD'
							when o.value_coded = 4991 THEN 'Other'  
							END as 'Entry_Point_level_facility'

							from obs o
							-- PREP CLIENT INITIATED : COMMUNITY AND ALSO OUTREACH
							
							inner join patient ON o.person_id = patient.patient_id 											 
							AND o.concept_id = 4986 and 
							o.value_coded IN ( 4987, 4988, 4989, 4990, 4991)	
							AND o.voided = 0 
							and CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)								
						
							inner join person ON person.person_id = patient.patient_id and person.voided = 0
							inner join location l on o.location_id = l.location_id  and l.retired=0
							inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
							inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
							inner join reporting_age_group AS observed_age_group ON
							CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							where observed_age_group.report_group_name = 'Modified_Ages'
						)entry_point_level_facility

						ON Newly_Initiated_Clients.Id = entry_point_level_facility.patient_id

						LEFT JOIN 
						(
							select distinct patient.patient_id ,
							case 
								when o.value_coded = 4984 THEN 'Community Program'
								when o.value_coded = 4985 THEN 'Outreach' 
							END as 'Entry_Point_level_community'

							from obs o
							-- PREP CLIENT INITIATED : COMMUNITY AND ALSO OUTREACH
							
							inner join patient ON o.person_id = patient.patient_id 											 
							AND o.concept_id = 4983 and 
							o.value_coded IN ( 4984, 4985)	
							AND o.voided = 0 
							and CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)								
						
							inner join person ON person.person_id = patient.patient_id and person.voided = 0
							inner join location l on o.location_id = l.location_id  and l.retired=0
							inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
							inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
							inner join reporting_age_group AS observed_age_group ON
							CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							where observed_age_group.report_group_name = 'Modified_Ages'
						
					)entry_point_level_community

					ON Newly_Initiated_Clients.Id = entry_point_level_community.patient_id
					
					LEFT JOIN 
						(
							select distinct patient.patient_id ,
							case 
								when o.value_coded = 5019 THEN 'Exchange sex for money' -- SW
								when o.value_coded = 5020 THEN 'Currently Pays for sex' 
								when o.value_coded = 5021 THEN 'MSM'
								when o.value_coded = 5022 THEN 'Transgender' --'Transgender Individual'
								when o.value_coded = 5023 THEN 'PWID' -- 'Individual Inject drugs'
								when o.value_coded = 5025 THEN 'Other' -- "serodiscordant relationship and HIV-Positive partner partner's viral load is >=1000 unknown"
								when o.value_coded = 5024 THEN 'Other' -- "serodiscordant relationship and HIV partner is not on ART or has been on for <12 months"
								when o.value_coded = 5026 THEN 'Other' -- 'Has multiple Concurrent partners'
								when o.value_coded = 5027 THEN 'Other' -- 'Individual belives their partner has multiple other Concurrent partners'
								when o.value_coded = 5028 THEN 'Other' -- 'Individula At High Risk of being force to have sex'								
								else 'Other'
							END as 'prep_group'

							from obs o
							-- PREP CLIENT INITIATED : COMMUNITY AND ALSO OUTREACH
							
							inner join patient ON o.person_id = patient.patient_id 											 
							AND o.concept_id = 5018 and 
							o.value_coded IN ( 5019,5020,5021,5022,5023,5024,5025,5026,5027,5028)	
							AND o.voided = 0 
							and CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)								
						
							inner join person ON person.person_id = patient.patient_id and person.voided = 0
							inner join location l on o.location_id = l.location_id  and l.retired=0
							inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
							inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
							inner join reporting_age_group AS observed_age_group ON
							CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							where observed_age_group.report_group_name = 'Modified_Ages'
						
					)indications_for_initiating_PrEP

					ON Newly_Initiated_Clients.Id = indications_for_initiating_PrEP.patient_id
					 
					GROUP BY Newly_Initiated_Clients.patientName
					ORDER BY Newly_Initiated_Clients.sort_order

			) AS PREP_STATUS_DRVD_ROWS

			GROUP BY PREP_STATUS_DRVD_ROWS.age_group, PREP_STATUS_DRVD_ROWS.Gender
			ORDER BY PREP_STATUS_DRVD_ROWS.sort_order)
			
			
	UNION ALL

			(SELECT 'Total' AS 'AgeGroup'
					, 'All' AS 'Gender'
					, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.prep_group = 'SW',1 , 0))) AS SW
					, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.prep_group = 'MSM',1 , 0))) AS MSM	
					, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.prep_group = 'Transgender',1 , 0))) AS Transgender	
					, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.prep_group = 'PWID',1 , 0))) AS PWID			
					, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.prep_group = 'Other',1 , 0))) AS Other
					, IF(PREP_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(PREP_STATUS_DRVD_COLS.Initiated = 'Initiated', 1, 0))) as 'Total_Initiated'
					, 99 AS sort_order
		FROM (
				SELECT distinct Id, patientIdentifier , patientName, Age, Gender, age_group, 'Initiated' AS 'Initiated',Entry_Point,Entry_Point_level_facility,Entry_Point_level_community,ifnull(prep_group, 'Other') as prep_group, sort_order, Location
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
						-- CLIENTS NEWLY INITIATED ON PREP
						inner join patient ON o.person_id = patient.patient_id 
						and (o.concept_id = 4994
								and CAST(o.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(o.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						     )
					    
						and patient.voided = 0 
						and o.voided = 0

						and o.person_id not in 
						(
							 -- TRANSFER INN
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5070
								and os.value_coded = 2146
								and CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						)	
						and o.person_id not in 
						(
							 -- HAS BEEN ON PrEP BEFORE
							select distinct os.person_id 
							from obs os
								where os.concept_id = 5003
								and CAST(os.value_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								and CAST(os.value_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 )
						 inner join person ON person.person_id = patient.patient_id and person.voided = 0
						 inner join location l on o.location_id = l.location_id  and l.retired=0
						 inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
						 inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
						 inner join reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                	where observed_age_group.report_group_name = 'Modified_Ages'
					AND floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) >= 10  
				) AS Newly_Initiated_Clients

				left outer join (
					
						select distinct patient.patient_id ,
										CASE 
											WHEN o.value_coded = 4981 THEN 'Community'
											WHEN o.value_coded = 4982 THEN 'Health Facility'
											ELSE 'non selected'
										END AS 'Entry_Point'

               			 from obs o
						 -- PREP CLIENT INITIATED : COMMUNITY AND FACILITY
						 
			     		 inner join patient ON o.person_id = patient.patient_id 		
						 AND o.voided = 0									 
						 AND o.concept_id = 4980 AND o.value_coded IN (4982, 4981)
						 and CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						 and CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						 inner join person ON person.person_id = patient.patient_id and person.voided = 0
						 inner join location l on o.location_id = l.location_id  and l.retired=0
						 inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
						 inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
						 inner join reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
        		        where observed_age_group.report_group_name = 'Modified_Ages'
					)ENTRY_POINT
					
					ON Newly_Initiated_Clients.Id = ENTRY_POINT.patient_id

					left outer join
						
						(
							select distinct patient.patient_id ,
							case 
							when o.value_coded = 4987 THEN 'Adolescent Corner'
							when o.value_coded = 4988 THEN 'ANC/PNC'
							when o.value_coded = 4989 THEN 'ART'
							when o.value_coded = 4990 THEN 'OPD'
							when o.value_coded = 4991 THEN 'Other'  
							END as 'Entry_Point_level_facility'

							from obs o
							-- PREP CLIENT INITIATED : COMMUNITY AND ALSO OUTREACH
							
							inner join patient ON o.person_id = patient.patient_id 											 
							AND o.concept_id = 4986 and 
							o.value_coded IN ( 4987, 4988, 4989, 4990, 4991)	
							AND o.voided = 0 
							and CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)								
						
							inner join person ON person.person_id = patient.patient_id and person.voided = 0
							inner join location l on o.location_id = l.location_id  and l.retired=0
							inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
							inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
							inner join reporting_age_group AS observed_age_group ON
							CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							where observed_age_group.report_group_name = 'Modified_Ages'
						)entry_point_level_facility

						ON Newly_Initiated_Clients.Id = entry_point_level_facility.patient_id

						LEFT JOIN 
						(
							select distinct patient.patient_id ,
							case 
								when o.value_coded = 4984 THEN 'Community Program'
								when o.value_coded = 4985 THEN 'Outreach' 
							END as 'Entry_Point_level_community'

							from obs o
							-- PREP CLIENT INITIATED : COMMUNITY AND ALSO OUTREACH
							
							inner join patient ON o.person_id = patient.patient_id 											 
							AND o.concept_id = 4983 and 
							o.value_coded IN ( 4984, 4985)	
							AND o.voided = 0 
							and CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)								
						
							inner join person ON person.person_id = patient.patient_id and person.voided = 0
							inner join location l on o.location_id = l.location_id  and l.retired=0
							inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
							inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
							inner join reporting_age_group AS observed_age_group ON
							CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							where observed_age_group.report_group_name = 'Modified_Ages'
						
					)entry_point_level_community

					ON Newly_Initiated_Clients.Id = entry_point_level_community.patient_id
					
					LEFT JOIN 
						(
							select distinct patient.patient_id ,
							case 
								when o.value_coded = 5019 THEN 'Exchange sex for money' -- SW
								when o.value_coded = 5020 THEN 'Currently Pays for sex' 
								when o.value_coded = 5021 THEN 'MSM'
								when o.value_coded = 5022 THEN 'Transgender' --'Transgender Individual'
								when o.value_coded = 5023 THEN 'PWID' -- 'Individual Inject drugs'
								when o.value_coded = 5025 THEN 'Other' -- "serodiscordant relationship and HIV-Positive partner partner's viral load is >=1000 unknown"
								when o.value_coded = 5024 THEN 'Other' -- "serodiscordant relationship and HIV partner is not on ART or has been on for <12 months"
								when o.value_coded = 5026 THEN 'Other' -- 'Has multiple Concurrent partners'
								when o.value_coded = 5027 THEN 'Other' -- 'Individual belives their partner has multiple other Concurrent partners'
								when o.value_coded = 5028 THEN 'Other' -- 'Individula At High Risk of being force to have sex'								
								else 'Other'
							END as 'prep_group'

							from obs o
							-- PREP CLIENT INITIATED : COMMUNITY AND ALSO OUTREACH
							
							inner join patient ON o.person_id = patient.patient_id 											 
							AND o.concept_id = 5018 and 
							o.value_coded IN ( 5019,5020,5021,5022,5023,5024,5025,5026,5027,5028)	
							AND o.voided = 0 
							and CAST(obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							and CAST(obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)								
						
							inner join person ON person.person_id = patient.patient_id and person.voided = 0
							inner join location l on o.location_id = l.location_id  and l.retired=0
							inner join person_name ON person.person_id = person_name.person_id and person_name.preferred = 1
							inner join patient_identifier ON patient_identifier.patient_id = person.person_id and patient_identifier.identifier_type = 3 and patient_identifier.preferred=1
							inner join reporting_age_group AS observed_age_group ON
							CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
							and (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
							where observed_age_group.report_group_name = 'Modified_Ages'
						
					)indications_for_initiating_PrEP

					ON Newly_Initiated_Clients.Id = indications_for_initiating_PrEP.patient_id

					GROUP BY Newly_Initiated_Clients.patientName
					ORDER BY Newly_Initiated_Clients.sort_order

			) AS PREP_STATUS_DRVD_COLS
		)
		
	) AS PREP_TOTALS_COLS_ROWS
ORDER BY PREP_TOTALS_COLS_ROWS.sort_order

