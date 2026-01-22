


SELECT distinct INDEX_TOTALS_COLS_ROWS.Totals
		    , INDEX_TOTALS_COLS_ROWS.Males_above_15
	    	, INDEX_TOTALS_COLS_ROWS.Females_above_15 
	    	, INDEX_TOTALS_COLS_ROWS.Males_below_15 
	    	, INDEX_TOTALS_COLS_ROWS.Females_below_15 
			, INDEX_TOTALS_COLS_ROWS.Total

FROM (

			(SELECT  INDEX_STATUS_DRVD_ROWS.age_group AS 'Totals'				
						, IF(INDEX_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(INDEX_STATUS_DRVD_ROWS.Gender = 'M' AND INDEX_STATUS_DRVD_ROWS.Contact_age >= 15, 1, 0))) AS Males_above_15
						, IF(INDEX_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(INDEX_STATUS_DRVD_ROWS.Gender = 'F' AND INDEX_STATUS_DRVD_ROWS.Contact_age >= 15, 1, 0))) AS Females_above_15
						, IF(INDEX_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(INDEX_STATUS_DRVD_ROWS.Gender = 'M' AND INDEX_STATUS_DRVD_ROWS.Contact_age < 15, 1, 0))) AS Males_below_15
						, IF(INDEX_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF(INDEX_STATUS_DRVD_ROWS.Gender = 'F' AND INDEX_STATUS_DRVD_ROWS.Contact_age < 15, 1, 0))) AS Females_below_15					
						, IF(INDEX_STATUS_DRVD_ROWS.Id IS NULL, 0, SUM(IF( ((INDEX_STATUS_DRVD_ROWS.Gender = 'M') || (INDEX_STATUS_DRVD_ROWS.Gender = 'F')), 1, 0))) as 'Total'
						, INDEX_STATUS_DRVD_ROWS.sort_order
			FROM (  
                        -- List the elicited contact name,age,gender for the Index Client
                SELECT Id,Client_Name, contact_Name, Contact_age, Gender, '' as age_group, 1 as sort_order
                FROM (                        
                        -- List the elicited contact name and age for the Index Contact
                    SELECT Id,concat(given_name ,' ',family_name) as Client_Name, concat(firstname,' ',surname) as contact_Name,Contact_age,c_gender.contact_gender as Gender from
                    (   
                         -- List the elicited contact firstname and surname for Index Client
                        SELECT Id,given_name , family_name, concept_id, firstname, surname,age_set.Contact_age, obs_group_id from
                        (   
                            -- Get elicited contact first name for the Index Client
                            SELECT Id,first_name_set.given_name, first_name_set.family_name, first_name_set.concept_id, firstname, surname, first_name_set.obs_group_id from
                            (   
                                 select obs_id, o.person_id as Id, given_name, family_name, concept_id, value_text as firstname, obs_group_id, o.voided 
                                 from obs o
                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                                
                                AND o.voided=0
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)		
                                                                    
                                    where concept_id in (4761)
                                group by obs_group_id
                            ) as first_name_set 

                            inner join 
                            (   
                                -- Get elicited contact surname for the Index Client
                                select obs_id, o.person_id, given_name, family_name, concept_id, value_text as surname, obs_group_id, o.voided  
                                from obs o
                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                                
                                AND o.voided=0
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)		
                                where concept_id in (4762) 
                                group by obs_group_id
                            ) as surname_set 
                                    ON first_name_set.obs_group_id=surname_set.obs_group_id 
                        ) as names 
                                
                        inner join
                        (   
                            -- Get the contact age for the Index Client
                            select obs_id, o.person_id, value_numeric as Contact_age, o.obs_group_id as age_obs_group_id, o.voided  
                            from obs o
                
                                INNER JOIN patient ON o.person_id = patient.patient_id 
                                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                                
                                AND o.voided=0
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)								 

                            AND o.obs_group_id in ( 
                                        select oss.obs_group_id
                                        from obs oss inner join person p ON oss.person_id=p.person_id 
                                        AND oss.concept_id = 4769 
                                        AND oss.voided=0
                                        AND oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE) 
                            )
                                
                            where concept_id = 4769
                            group by obs_group_id 
                        ) as age_set 

                        ON names.obs_group_id = age_set.age_obs_group_id
                    ) as Contact_age

                    inner join

                    (   
                        -- Get the elicited contact gender for Index Client
                        select obs_id, o.person_id, IF(value_coded = 1088,'F','M') as contact_gender, o.obs_group_id as gender_obs_group_id, o.voided  
                       
                        from obs o                
                            INNER JOIN patient ON o.person_id = patient.patient_id 
                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                            
                            AND o.voided=0
                            AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)								 
                        AND o.value_coded in (1088,1087)
                        AND o.obs_group_id in (
                                    select oss.obs_group_id
                                    from obs oss inner join person p ON oss.person_id=p.person_id 
                                    AND oss.concept_id = 4769 
                                    AND oss.voided=0 
                                    AND oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                        )

                        group by obs_group_id 
                    ) as c_gender 

                    ON Contact_age.obs_group_id = c_gender.gender_obs_group_id
                    group by obs_group_id 
                    ) as INDEX_CLIENTS_CONTACTS
                    group by Client_Name,Contact_age,Gender



			) AS INDEX_STATUS_DRVD_ROWS

			GROUP BY INDEX_STATUS_DRVD_ROWS.age_group, INDEX_STATUS_DRVD_ROWS.Gender
			ORDER BY INDEX_STATUS_DRVD_ROWS.sort_order
			)			
			
	 UNION ALL

			(SELECT 'Total' AS 'Totals' 
                        , IF(INDEX_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(INDEX_STATUS_DRVD_COLS.Gender = 'M' AND INDEX_STATUS_DRVD_COLS.Contact_age >= 15, 1, 0))) AS Males_above_15
						, IF(INDEX_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(INDEX_STATUS_DRVD_COLS.Gender = 'F' AND INDEX_STATUS_DRVD_COLS.Contact_age >= 15, 1, 0))) AS Females_above_15
						, IF(INDEX_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(INDEX_STATUS_DRVD_COLS.Gender = 'M' AND INDEX_STATUS_DRVD_COLS.Contact_age < 15, 1, 0))) AS Males_below_15
						, IF(INDEX_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF(INDEX_STATUS_DRVD_COLS.Gender = 'F' AND INDEX_STATUS_DRVD_COLS.Contact_age < 15, 1, 0))) AS Females_below_15					
						, IF(INDEX_STATUS_DRVD_COLS.Id IS NULL, 0, SUM(IF( ((INDEX_STATUS_DRVD_COLS.Gender = 'M') || (INDEX_STATUS_DRVD_COLS.Gender = 'F')), 1, 0))) as 'Total'
						, 99 AS sort_order
			FROM (
                        -- List the elicited contact name,age,gender for the Index Client
                SELECT Id, Client_Name, contact_Name, Contact_age, Gender, 1 as sort_order
                FROM (                        
                        -- List the elicited contact name and age for the Index Contact
                     SELECT Id, concat(given_name ,' ',family_name) as Client_Name, concat(firstname,' ',surname) as contact_Name,Contact_age,c_gender.contact_gender as Gender from
                    (
                        -- List the elicited contact firstname and surname for Index Client
                        SELECT Id, given_name , family_name, concept_id, firstname, surname,age_set.Contact_age, obs_group_id from
                        (
                            -- Get elicited contact first name for the Index Client
                            SELECT Id, first_name_set.given_name, first_name_set.family_name, first_name_set.concept_id, firstname, surname, first_name_set.obs_group_id from
                            (   
                                select obs_id, o.person_id as Id, given_name, family_name, concept_id, value_text as firstname, obs_group_id, o.voided 
                                from obs o 
                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                                    
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)                      
                                                                    
                                    where concept_id in (4761)
                                group by obs_group_id
                            ) as first_name_set 
                            inner join  
                            ( 
                                -- Get elicited contact surname for the Index Client
                                select obs_id, o.person_id, given_name, family_name, concept_id, value_text as surname, obs_group_id, o.voided 
                                from obs o 
                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                                        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)                       					 

                                where concept_id in (4762) 
                                group by obs_group_id
                            ) as surname_set 
                                    ON first_name_set.obs_group_id=surname_set.obs_group_id 
                        ) as names
                                
                        inner join
                        (
                            -- Get the contact age for the Index Client
                            select obs_id, o.person_id, value_numeric as Contact_age, o.obs_group_id as age_obs_group_id, o.voided  
                            from obs o 
                                INNER JOIN patient ON o.person_id = patient.patient_id 
                                INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                                    
                            AND o.voided=0   
                            AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                       
                            AND o.obs_group_id in ( 
                                        select oss.obs_group_id
                                        from obs oss inner join person p ON oss.person_id=p.person_id 
                                        AND oss.concept_id = 4769 
                                        AND oss.voided=0
                                        AND oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE) 
                            )
                                
                            where concept_id = 4769
                            group by obs_group_id 
                        ) as age_set 

                        ON names.obs_group_id = age_set.age_obs_group_id
                    ) as Contact_age

                    inner join

                    (
                         -- Get the elicited contact gender for Index Client
                        select obs_id, o.person_id, IF(value_coded = 1088,'F','M') as contact_gender, o.obs_group_id as gender_obs_group_id, o.voided  
                        from obs o 
                            INNER JOIN patient ON o.person_id = patient.patient_id 
                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                                
                        AND o.voided=0   
                        AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                       
                        AND o.value_coded in (1088,1087)
                        AND o.obs_group_id in (
                                    select oss.obs_group_id
                                    from obs oss inner join person p ON oss.person_id=p.person_id 
                                    AND oss.concept_id = 4769 
                                    AND oss.voided=0 
                                    AND oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                        )

                        group by obs_group_id 
                    ) as c_gender 

                    ON Contact_age.obs_group_id = c_gender.gender_obs_group_id
                    group by obs_group_id 
                    ) as INDEX_CLIENTS_CONTACTS
                    group by Client_Name,Contact_age,Gender
			) AS INDEX_STATUS_DRVD_COLS
		)
		
	) AS INDEX_TOTALS_COLS_ROWS
ORDER BY INDEX_TOTALS_COLS_ROWS.sort_order
