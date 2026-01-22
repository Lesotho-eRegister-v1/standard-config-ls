SELECT Heading,	   
 IF(Id IS NULL, 0, SUM(IF(Persons = 'Children' AND Gender = 'M', 1, 0))) AS Children_Males, 
 IF(Id IS NULL, 0, SUM(IF(Persons = 'Children' AND Gender = 'F', 1, 0))) AS Children_Females,
 IF(Id IS NULL, 0, SUM(IF(Persons = 'Adults' AND Gender = 'M', 1, 0))) AS Adults_Males, 
 IF(Id IS NULL, 0, SUM(IF(Persons = 'Adults' AND Gender = 'F', 1, 0))) AS Adults_Females

FROM
    (   
   SELECT Id,Gender,Heading,Persons
        FROM(
   
   (SELECT  Id,Gender,'ART_PreART_Seen' as Heading,'Children' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        -- CLIENTS SEEN FOR ART
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.concept_id = 3843 AND o.value_coded in (3841,3842)
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
            AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.voided = 0
          
        ) artPreart_a
    WHERE Age < 15  )     

    UNION

       (SELECT  Id,Gender,'ART_PreART_Seen' as Heading,'Adults' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        -- CLIENTS SEEN FOR ART
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND o.concept_id = 3843 AND o.value_coded in (3841,3842)
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
            AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.voided = 0
          
        ) artPreart_a
    WHERE Age >= 15  ) 

    UNION

       (SELECT  Id,Gender,'ART_PreART_Screened' as Heading,'Children' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        -- CLIENTS SEEN FOR ART
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
			AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.voided = 0
            AND o.concept_id = 3843 AND o.value_coded in (3842) 
            AND o.person_id in (
						select person_id from obs
						where concept_id = 3710 and value_coded IN (3709,1876,3639) 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
					)
                    
        ) artPreart_a
    WHERE Age < 15  )     

    UNION

       (SELECT  Id,Gender,'ART_PreART_Screened' as Heading,'Adults' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        -- CLIENTS SEEN FOR ART
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
			AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.concept_id = 3843 AND o.value_coded in (3842) 
            AND o.voided = 0          
            and o.person_id in (
						select person_id from obs
						where concept_id = 3710 and value_coded IN (3709,1876,3639)  
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
					)
        ) artPreart_a
    WHERE Age >= 15  )              

    UNION

       (SELECT  Id,Gender,'Presumptive_reported' as Heading,'Children' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        -- CLIENTS SEEN FOR ART
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
			AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.concept_id = 3843 AND o.value_coded in (3842)
            AND o.voided = 0
          
            AND o.person_id in (
						select person_id from obs
						where concept_id = 3710 and value_coded = 1876 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
					)
        ) artPreart_a
    WHERE Age < 15  )     

    UNION

       (SELECT  Id,Gender,'Presumptive_reported' as Heading,'Adults' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        -- CLIENTS SEEN FOR ART
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
			AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.concept_id = 3843 AND o.value_coded in (3842)
            AND o.voided = 0
          
            and o.person_id in (
						select person_id from obs
						where concept_id = 3710 and value_coded = 1876 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
					)
        ) artPreart_a
    WHERE Age >= 15  )              

    UNION

    -- Start : ART clients disagnosed using genXpert in the reporting period
       (SELECT  Id,Gender,'Diagnosed' as Heading,'Children' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
         
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
			AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.voided = 0
            
            -- select geneXpert as diagnosis
            AND o.concept_id = 3814 and o.value_coded = 3824
            AND o.voided = 0 
             
        ) artPreart_a
    WHERE Age < 15  )     

    UNION

       (SELECT  Id,Gender,'Diagnosed' as Heading,'Adults' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
			AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            
            -- select geneXpert as diagnosis
            AND o.concept_id = 3814 and o.value_coded = 3824
            AND o.voided = 0 
             
        ) artPreart_a
    WHERE Age >= 15  )   
        -- //End ART clients disagnosed using genXpert in the reporting period
    UNION

       (SELECT  Id,Gender,'Started' as Heading,'Children' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        -- CLIENTS SEEN FOR ART
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
			AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.voided = 0
          
            AND o.person_id in (
						select person_id from obs 
						-- genexpert
						where concept_id = 3787 and value_coded in (3816,3817) 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
						-- line probe
						UNION
						select person_id from obs
						where concept_id = 3805 and value_coded in (1738) 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
						UNION
						-- phenotypic
						select person_id from obs
						where concept_id = 3840 and value_coded in (3837,3838,3839) 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
					)
            AND o.person_id in(
                select person_id from obs
                where concept_id = 2237 
                AND MONTH(value_datetime) = MONTH(CAST('#endDate#' AS DATE))
                AND YEAR(value_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            )
        ) artPreart_a
    WHERE Age < 15  )     

    UNION

       (SELECT  Id,Gender,'Started' as Heading,'Adults' as Persons
    FROM( 
            select o.person_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group
            from obs o
        -- CLIENTS SEEN FOR ART
            INNER JOIN person ON person.person_id = o.person_id AND person.voided = 0
            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
            INNER JOIN reporting_age_group AS observed_age_group ON
            CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
            AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
            WHERE observed_age_group.report_group_name = 'Modified_Ages'
            AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
			AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            AND o.voided = 0
          
            and o.person_id in (
						select person_id from obs 
						-- genexpert
						where concept_id = 3787 and value_coded in (3816,3817) 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
						-- line probe
						UNION
						select person_id from obs
						where concept_id = 3805 and value_coded in (1738) 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
						UNION
						-- phenotypic
						select person_id from obs
						where concept_id = 3840 and value_coded in (3837,3838,3839) 
						AND MONTH(obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
					)
            AND o.person_id in(
                select person_id from obs
                where concept_id = 2237 
                AND MONTH(value_datetime) = MONTH(CAST('#endDate#' AS DATE))
                AND YEAR(value_datetime) =  YEAR(CAST('#endDate#' AS DATE))
            )        
        ) artPreart_a
    WHERE Age >= 15  )
    
	UNION ALL
	
	SELECT  '','','ART_PreART_Seen',''
	
	UNION ALL
	
	SELECT  '','','ART_PreART_Screened',''
	
	UNION ALL
	
	SELECT  '','','Presumptive_reported',''
	
	UNION ALL
	
	SELECT  '','','Diagnosed',''
	
	UNION ALL
	
	SELECT  '','','Started',''   
        )all_TB                       

    )all_agg
GROUP BY Heading   
ORDER BY FIELD (Heading,'ART_PreART_Seen','ART_PreART_Screened','Presumptive_reported','Diagnosed','Started') 