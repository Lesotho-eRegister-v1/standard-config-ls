SELECT Heading,	   
 IF(Id IS NULL, 0, SUM(IF(Persons = 'Children' AND Gender = 'M', 1, 0))) AS Children_Males, 
 IF(Id IS NULL, 0, SUM(IF(Persons = 'Children' AND Gender = 'F', 1, 0))) AS Children_Females,
 IF(Id IS NULL, 0, SUM(IF(Persons = 'Adults' AND Gender = 'M', 1, 0))) AS Adults_Males, 
 IF(Id IS NULL, 0, SUM(IF(Persons = 'Adults' AND Gender = 'F', 1, 0))) AS Adults_Females

FROM
    (
    SELECT Id,Gender,Heading,Persons
    FROM(    
        (SELECT  Id,Gender,'Plumpy_Nut' as Heading,'Children' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4163
             )plumpy
        WHERE Age < 15)     

        UNION

         (SELECT  Id,Gender,'Plumpy_Nut' as Heading,'Adults' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4163
             )plumpy
        WHERE Age > 15)

        UNION

        (SELECT  Id,Gender,'F100' as Heading,'Children' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4164
             )plumpy
        WHERE Age < 15)     

        UNION

         (SELECT  Id,Gender,'F100' as Heading,'Adults' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4164
             )plumpy
        WHERE Age > 15)

        UNION

        (SELECT  Id,Gender,'F75' as Heading,'Children' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4165
             )plumpy
        WHERE Age < 15)     

        UNION

         (SELECT  Id,Gender,'F75' as Heading,'Adults' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4165
             )plumpy
        WHERE Age > 15)

        UNION

        (SELECT  Id,Gender,'Super_Cereal' as Heading,'Children' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4815
             )plumpy
        WHERE Age < 15)     

        UNION

         (SELECT  Id,Gender,'Super_Cereal' as Heading,'Adults' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4815
             )plumpy
        WHERE Age > 15)

        UNION

        (SELECT  Id,Gender,'Other_Nutritional_Supplements' as Heading,'Children' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4166
             )others
        WHERE Age < 15)     

        UNION

         (SELECT  Id,Gender,'Other_Nutritional_Supplements' as Heading,'Adults' as Persons
        FROM(
            select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2021-05-18' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
            from obs o 	
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('2021-05-18' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.voided = 0
            AND MONTH(obs_datetime) = MONTH(CAST('2021-05-18' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2021-05-18' AS DATE))
            and concept_id = 4167 and value_coded = 4166
             )others
        WHERE Age > 15)
		
		UNION ALL
	
		SELECT  '','','Plumpy_Nut',''
		
		UNION ALL
	
		SELECT  '','','F100',''
		
		UNION ALL
	
		SELECT  '','','F75',''
		
		UNION ALL
	
		SELECT  '','','Super_Cereal',''
		
		UNION ALL
	
		SELECT  '','','Other_Nutritional_Supplements',''
    )all_supplements    
    )all_agg
    GROUP BY Heading
	ORDER BY FIELD (Persons,'Plumpy_Nut','F100','F75','Super_Cereal','Other_Nutritional_Supplements')
