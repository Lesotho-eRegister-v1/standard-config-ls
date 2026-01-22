SELECT Persons,	   
 IF(Id IS NULL, 0, SUM(IF(Gender = 'M', 1, 0))) AS Males, 
 IF(Id IS NULL, 0, SUM(IF(Gender = 'F', 1, 0))) AS Females

FROM
    (
    SELECT Id,Gender,Persons
        FROM(
            (SELECT  Id,Gender,'Under1yr' as Persons
            FROM(
                select distinct o.person_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                floor(datediff(CAST('2020-07-31' AS DATE), person.birthdate)/365) AS Age,
                                person.gender AS Gender,
                                observed_age_group.name AS age_group
                from obs o 	
                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('2020-07-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages'
                        AND o.voided = 0
                        AND MONTH(obs_datetime) = MONTH(CAST('2020-07-31' AS DATE))
                        AND YEAR(obs_datetime) =  YEAR(CAST('2020-07-31' AS DATE))
                        and concept_id = 3728 and value_numeric >= 1
            )ctx_a
            WHERE Age < 1)

            UNION

            (SELECT  Id,Gender,'1yr-4yrs' as Persons
            FROM(
                select distinct o.person_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                floor(datediff(CAST('2020-07-31' AS DATE), person.birthdate)/365) AS Age,
                                person.gender AS Gender,
                                observed_age_group.name AS age_group
                from obs o 	
                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('2020-07-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages'
                        AND o.voided = 0
                        AND MONTH(obs_datetime) = MONTH(CAST('2020-07-31' AS DATE))
                        AND YEAR(obs_datetime) =  YEAR(CAST('2020-07-31' AS DATE))
                        and concept_id = 3728 and value_numeric >= 1
            )ctx_b
            WHERE Age >= 1 AND Age <=4)

            UNION

            (SELECT  Id,Gender,'5yr-14yrs' as Persons
            FROM(
                select distinct o.person_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                floor(datediff(CAST('2020-07-31' AS DATE), person.birthdate)/365) AS Age,
                                person.gender AS Gender,
                                observed_age_group.name AS age_group
                from obs o 	
                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('2020-07-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages'
                        AND o.voided = 0
                        AND MONTH(obs_datetime) = MONTH(CAST('2020-07-31' AS DATE))
                        AND YEAR(obs_datetime) =  YEAR(CAST('2020-07-31' AS DATE))
                        and concept_id = 3728 and value_numeric >= 1
            )ctx_c
            WHERE Age >= 5 AND Age <=14)

            UNION

            (SELECT  Id,Gender,'Adults' as Persons
            FROM(
                select distinct o.person_id AS Id,
                                patient_identifier.identifier AS patientIdentifier,
                                floor(datediff(CAST('2020-07-31' AS DATE), person.birthdate)/365) AS Age,
                                person.gender AS Gender,
                                observed_age_group.name AS age_group
                from obs o 	
                INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                INNER JOIN reporting_age_group AS observed_age_group ON
                                CAST('2020-07-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                        WHERE observed_age_group.report_group_name = 'Modified_Ages'
                        AND o.voided = 0
                        AND MONTH(obs_datetime) = MONTH(CAST('2020-07-31' AS DATE))
                        AND YEAR(obs_datetime) =  YEAR(CAST('2020-07-31' AS DATE))
                        and concept_id = 3728 and value_numeric >= 1
            )ctx_d
            WHERE Age > 14)
			
			UNION ALL
			
			(SELECT  '','','Under1yr') 
			
			UNION ALL
			
			(SELECT  '','','1yr-4yrs') 
			
			UNION ALL
			
			(SELECT  '','','5yr-14yrs') 
			
			UNION ALL
			
			(SELECT  '','','Adults') 
			
    )all_CTX
    )all_agg
	GROUP BY Persons
	ORDER BY FIELD (Persons,'Under1yr','1yr-4yrs','5yr-14yrs','Adults')