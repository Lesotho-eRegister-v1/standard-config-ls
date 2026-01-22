SELECT Distinct 
			PatientIdentifier
			,PatientName
			,Age
			,Gender
			,Viral_Load
			,Date_Blood_Drawn

			FROM
(select distinct 
			patient_identifier.identifier AS PatientIdentifier,
			o.person_id as Id,
			concat(person_name.given_name, ' ', person_name.family_name) AS PatientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender,
			unsuppressed.Viral_load as Viral_Load,
			cast(o.value_datetime as date)as Date_Blood_Drawn
						

                from obs o
						
						 INNER JOIN patient ON o.person_id = patient.patient_id
						-- AND o.person_id in 
						INNER JOIN (
								select o.person_id, value_numeric as Viral_load
								from obs o
								where o.concept_id = 2254 -- Viral Load value
								and cast(o.obs_datetime as date) >= DATE_ADD(CAST('#startDate#' AS DATE), INTERVAL -3 MONTH)
								and cast(o.obs_datetime as date) < cast('#startDate#' as date)
								and o.voided = 0
								having value_numeric >= 1000 		
						 )unsuppressed
						 on unsuppressed.person_id = o.person_id
						 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						INNER JOIN location l on o.location_id = l.location_id and l.retired=0
                        INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages' and cast(o.obs_datetime as date) <= CAST('#endDate#' AS DATE) and concept_id = 4267
				   and cast(o.value_datetime as date) >= cast('#startDate#' as date)
				   and cast(o.value_datetime as date) <= cast('#endDate#' as date)
				   Group  BY patientIdentifier 
)test_after_unsuppressed_result

order by 2