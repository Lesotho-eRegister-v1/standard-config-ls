select patient_type, 
	IF(id is null, 0,SUM(IF(outcome = '< 1',1,0))) AS "<1",
	IF(id is null, 0,SUM(IF(outcome = '1 - 4 yrs',1,0))) AS "1-4yrs",
	IF(id is null, 0,SUM(IF(outcome = '5 -9 yrs',1,0))) AS "5-9yrs",
    IF(id is null, 0,SUM(IF(outcome = '10 - 14 yrs',1,0))) AS "10-14yrs",
	IF(id is null, 0,SUM(IF(outcome = '15 - 19 yrs',1,0))) AS "15-19yrs",
	IF(id is null, 0,SUM(IF(outcome = '20 - 24 yrs',1,0))) AS "20-24yrs",
    IF(id is null, 0,SUM(IF(outcome = '25- 34 yrs',1,0))) AS "25-34yrs",
	IF(id is null, 0,SUM(IF(outcome = '35 - 44 yrs',1,0))) AS "35-44yrs",
	IF(id is null, 0,SUM(IF(outcome = '45 - 49 yrs',1,0))) AS "45-49yrs",
	IF(id is null, 0,SUM(IF(outcome = '50+ yrs',1,0))) AS "50+yrs"

from(
select id, outcome, patient_type
from
(    
    -- MALE NEW CLIENTS LIST
    ( 
        select distinct o.person_id as id, '< 1' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/30.4) < 12
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	
	UNION
	
	    ( 
        select distinct o.person_id as id, '1 - 4 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 1 and 4
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '5 - 9 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 5 and 9
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '10 - 14 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 10 and 14
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '15 - 19 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 15 and 19
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '20 - 24 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 20 and 24
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '25 - 29 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 25 and 29
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '30 - 34 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 30 and 34
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '35 - 39 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 35 and 39
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '40 - 44 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 40 and 44
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '45 - 49 yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 45 and 49
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '50+ yrs' as outcome, 'Male' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'M'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) >= 50 
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	
	UNION
	
	-- FEMALE NEW CLIENTS LIST
    ( 
        select distinct o.person_id as id, '< 1' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/30.4) < 12
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	
	UNION
	
	    ( 
        select distinct o.person_id as id, '1 - 4 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 1 and 4
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '5 - 9 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 5 and 9
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '10 - 14 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 10 and 14
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '15 - 19 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 15 and 19
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '20 - 24 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 20 and 24
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '25 - 29 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 25 and 29
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '30 - 34 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 30 and 34
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '35 - 39 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 35 and 39
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '40 - 44 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 40 and 44
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '45 - 49 yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) between 45 and 49
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)
	UNION
	
	    ( 
        select distinct o.person_id as id, '50+ yrs' as outcome, 'Female' as patient_type
				from obs o inner join person p
                on o.person_id = p.person_id 
                and p.voided = 0 
                and p.gender = 'F'
                -- less than a year
                and FLOOR(DATEDIFF(current_date(),p.birthdate)/365) >= 50 
                and o.person_id in 
						(
						select o.person_id
						from obs o
						-- CLIENTS NEWLY INITIATED ON ART
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 2249 AND DATE(o.value_datetime) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.person_id not in (
							select distinct os.person_id from obs os
							where 
								os.concept_id = 3634 AND os.value_coded = 2095 
								AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
						 )
						 AND o.person_id not in 
								(
								select distinct person_id 
													from person
													where death_date < CAST('#endDate#' AS DATE)
													and dead = 1
								)
						AND o.person_id not in 
								(
								select distinct os.person_id 
							   from obs os
							   where os.concept_id = 4155 and os.value_coded = 2146
							   AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Coarse_Ages')
	)

	
) allDataRows
	) pivotTable
group by patient_type