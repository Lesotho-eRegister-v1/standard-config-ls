

SELECT distinct Patient_Identifier
			   ,Patient_Name
			   ,Age
			   ,Gender
			   ,FP_Visit
			   ,OnART
			   ,Prep_Provided
			   ,FP_Method
			   ,FP_TB_Screening
			   ,STI_Screening
			   ,STI_Treatment
			   ,HIV_Testing
FROM
( 

	 (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender,       
                             CASE
                                WHEN code = 2093 THEN 'New'
                                WHEN code = 4539 THEN 'Revisit'
                                WHEN code = 2303 THEN 'Restarted'
                             ELSE 'typeOfFpVisit'
                             END AS 'FP_Visit', sort_order
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,
                                               o.value_coded as 'code'

						from obs o
								-- FP Attendance 

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 4538 and o.value_coded IN (2093,4539,2303)
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Modified_Ages'
						) AS new_fp
		    ORDER BY new_fp.sort_order desc
			
			)FP_VISITS 

			LEFT JOIN 

			(
				select distinct person_id as Id, CASE
				when OnART ='Yes' then 'Yes'
				when OnART ='' then 'No'
				else ''
				end as OnART
					from   
					(select on_art.person_id, OnART
					from
					(
					select distinct o.person_id, 'Yes' as 'OnART'
					from obs o
					where o.concept_id = 2403 and o.voided = 0
					AND CAST(o.obs_datetime AS DATE) <= DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)
					)on_art
					)X
			)art
			ON FP_VISITS.Id = art.Id

			left outer join
			(select
				o.person_id,
				case
					when value_coded = 2146 then "Yes"
					when value_coded = 2147 then "No"
					when value_coded = 1975 then "N/A"
					else "Not Provided"
				end AS Prep_Provided
			from obs o
			inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as prep_taken
					from obs oss
					where oss.concept_id = 5204 and oss.voided=0
					and oss.obs_datetime < cast('#endDate#' as date)
					group by oss.person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 5204
				and  o.obs_datetime = max_observation
				) prep_taken
			ON FP_VISITS.Id = prep_taken.person_id

			LEFT OUTER JOIN 
			(
				select distinct
				person_id,
				case
						WHEN value_coded = 5205 THEN 'Progestrone only pill' 
						WHEN value_coded = 5206 THEN 'Combined oral contraceptive' 
						WHEN value_coded = 5207 THEN 'Depo medroxy progestrone acetate subcutatneous (DMPA-SC)' 
						WHEN value_coded = 5208 THEN 'Depo medroxy progestrone acetate intramusc' 
						WHEN value_coded = 5209 THEN 'Noristrate (NTE)' 
						WHEN value_coded = 2314 THEN 'Implant' 
						WHEN value_coded = 4551 THEN 'Jadelle' 
						WHEN value_coded = 5212 THEN 'Norplant' 
						WHEN value_coded = 4441 THEN 'Lactational Amenorrhea Method' 
						WHEN value_coded = 4552 THEN 'Copper T380A' 
						WHEN value_coded = 5214 THEN 'Intra Uterine Contraceptive Device(IUCD)' 
						WHEN value_coded = 4440 THEN 'Bilateral Tubal Ligation (BTL)' 
						WHEN value_coded = 2497 THEN 'Vasectomy' 
						WHEN value_coded = 4229 THEN 'Male Condoms' 
						WHEN value_coded = 4230 THEN 'Female Condoms' 
						WHEN value_coded = 4553 THEN 'Standard Days Method' 
						WHEN value_coded = 5215 THEN 'Emegency Pill' 
						WHEN value_coded = 1154 THEN 'None' 
						ELSE ''
				end AS FP_Method
				from 
				(
					select B.person_id, B.obs_group_id, B.obs_datetime AS latest_fp_method,value_coded
					from obs B
					inner join 
						(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs where concept_id = 5225 -- Pick from method provided section
						and obs_datetime <= cast('#endDate#' as date)
						and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						where concept_id = 2481
						and A.observation_id = B.obs_group_id
						and voided = 0	
						AND CAST(B.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
              )fp_method_provided
				
			) fp_method
			ON FP_VISITS.Id = fp_method.person_id
			
			LEFT OUTER JOIN 
			(
				select distinct
				person_id,
				case
						WHEN value_coded = 3709 THEN 'No Signs' 
						WHEN value_coded = 1876 THEN 'Suspected/Probable' 
						WHEN value_coded = 3639 THEN 'On TB Treatment' 
						WHEN value_coded = 4332 THEN 'History of confirmed TB' 
						ELSE ''
				end AS FP_TB_Screening
				from 
				(
					select B.person_id, B.obs_group_id, B.obs_datetime AS fp_tb_screening,value_coded
					from obs B
					inner join 
						(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs where concept_id = 4544 -- Pick from Exams, Screens and Removals
						and obs_datetime <= cast('#endDate#' as date)
						and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						where concept_id = 4447 -- TB Screening
						and A.observation_id = B.obs_group_id
						and voided = 0	
						AND CAST(B.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
              )fp_tb_screening
				
			) tb_screening
			ON FP_VISITS.Id = tb_screening.person_id

			LEFT OUTER JOIN 
			(
				select distinct
				person_id,
				case
						WHEN value_coded = 4306 THEN 'Reactive' 
						WHEN value_coded = 4307 THEN 'Non-Reactive' 
						WHEN value_coded = 4308 THEN 'Not Done' 
						ELSE 'Not Provided'
				end AS STI_Screening
				from 
				(
					select B.person_id, B.obs_group_id, B.obs_datetime AS sti_screening, value_coded
					from obs B
					inner join 
						(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs where concept_id = 4544 -- Pick from Exams, Screens and Removals
						and obs_datetime <= cast('#endDate#' as date)
						and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						where concept_id = 4443 -- STI Screening
						and A.observation_id = B.obs_group_id
						and voided = 0	
						AND CAST(B.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
              )sti_screening
				
			)screening_sti
			ON FP_VISITS.Id = screening_sti.person_id

			LEFT OUTER JOIN 
			(
				select distinct
				person_id,
				case
						WHEN value_coded = 5192 THEN 'Treatment Initiated' 
						WHEN value_coded = 5193 THEN 'Treatment not provided' 
						WHEN value_coded = 5194 THEN 'Treatment N/A' 
						ELSE ''
				end AS STI_Treatment
				from 
				(
					select B.person_id, B.obs_group_id, B.obs_datetime AS sti_treatment, value_coded
					from obs B
					inner join 
						(select person_id, max(obs_datetime), SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
						from obs where concept_id = 4544 -- Pick from Exams, Screens and Removals
						and obs_datetime <= cast('#endDate#' as date)
						and voided = 0
						group by person_id) as A
						on A.observation_id = B.obs_group_id
						where concept_id = 5191 -- STI Treatment
						and A.observation_id = B.obs_group_id
						and voided = 0	
						AND CAST(B.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(B.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
              )sti_treatment
				
			)sti_treatment
			ON FP_VISITS.Id = sti_treatment.person_id

			LEFT OUTER JOIN 

			(
				select
				o.person_id,
				case
					when value_coded = 1738 then "Positive"
					when value_coded = 1016 then "Negative"
					when value_coded = 1739 then "Unknown"
					else ""
				end AS HIV_Testing
				from obs o
				inner join
					(
					select oss.person_id, MAX(oss.obs_datetime) as max_observation,
					SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as hiv_testing
					from obs oss
					where oss.concept_id = 5202 and oss.voided=0
					and cast(oss.obs_datetime as Date) <= cast('#endDate#' as date)
					group by oss.person_id
					)latest
				on latest.person_id = o.person_id
				where concept_id = 5202
				and  o.obs_datetime = max_observation
			)hiv_testing
			ON FP_VISITS.Id = hiv_testing.person_id

			)
			

			