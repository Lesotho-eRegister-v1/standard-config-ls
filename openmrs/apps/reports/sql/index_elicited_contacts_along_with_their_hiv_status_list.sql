select Client_Name,Contact_Name,contact_age,contact_gender,Contact_HIV_Status 
from
(
        (  select Client_Name, Contact_Name, contact_age, contact_gender,Contact_HIV_Status from
         -- start
            ( select Client_Name, Contact_Name, contact_age, contact_gender,c_status.Contact_HIV_Status from
            
                (
                    SELECT concat(given_name,' ', family_name) as Client_Name, concat(firstname,' ',surname) as Contact_Name, contact_age, c_gender.contact_gender, contact_ages.obs_group_id
                        from
                        (
                            SELECT given_name, family_name, concept_id, firstname, surname,age_set.contact_age, obs_group_id from
                            (
                                SELECT first_name_set.given_name, first_name_set.family_name, first_name_set.concept_id, firstname, surname, first_name_set.obs_group_id from
                                (    
                                    -- Contact Firstname and Surname
                                    select obs_id, o.person_id, given_name, family_name, concept_id, value_text as firstname, obs_group_id, o.voided 
                                     from obs o
                                        INNER JOIN patient ON o.person_id = patient.patient_id 
                                        INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                        INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                        INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
            
                                    AND o.voided=0   
                                    AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)	
                                        where concept_id in (4761)
                                    group by obs_group_id) as first_name_set 

                                inner join 
                                ( 
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
                                    -- Contact Age
                                    select obs_id, o.person_id, value_numeric as contact_age, o.obs_group_id as age_obs_group_id, o.voided  
                                    from obs o
                                        INNER JOIN patient ON o.person_id = patient.patient_id 
                                        INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                        INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                        INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)									 
                                    and o.obs_group_id in (
                                                select oss.obs_group_id
                                                from obs oss inner join person p on oss.person_id=p.person_id 
                                                and oss.concept_id = 4769 
                                                and oss.voided=0
								                and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)								                                                 
                                    )
                                        
                                    where concept_id = 4769
                                    group by obs_group_id 
                                ) as age_set 
                            on names.obs_group_id = age_set.age_obs_group_id
                        
                        ) as contact_ages

                                inner join
                                    ( 
                                        -- Contact gender
                                        select obs_id, o.person_id, IF(value_coded = 1088,'F','M') as contact_gender, o.obs_group_id as gender_obs_group_id, o.voided  
                                        from obs o
                                                INNER JOIN patient ON o.person_id = patient.patient_id 
                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)										 	
                                        and o.value_coded in (1088,1087)
                                        and o.obs_group_id in (
                                                    select oss.obs_group_id
                                                    from obs oss inner join person p on oss.person_id=p.person_id
                                                    and oss.concept_id = 4770 
                                                    and oss.voided=0
								                    and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								  
                                        )                    
                                        and o.concept_id in(4770) 
                                        group by obs_group_id 
                                    ) as c_gender 
                        on contact_ages.obs_group_id = c_gender.gender_obs_group_id

                ) as contact_status
            

                        inner join
                            (
                                -- Contact has prior testing results
                                select obs_id, o.person_id, 
                                        case 
                                                when value_coded = 1738 then 'Prior_Positive'
                                                when value_coded = 1016 then 'Prior_Negative'
                                                when value_coded = 1975 then 'Not_Applicable'  
                                                else 'Unknown' end as Contact_HIV_Status,
                                                o.obs_group_id as status_obs_group_id 
                                from obs o
                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)									 
								    and o.value_coded in (1738,1016,1975,1739) 

                                    and o.obs_group_id in (
                                            select oss.obs_group_id
                                            from obs oss inner join person p on oss.person_id=p.person_id 
                                            and oss.voided=0 
                                            and oss.value_coded in (2146) 
                                            and oss.concept_id = 4773
								            and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								 
                                )                    
                                and o.concept_id in(4774) 
                                group by obs_group_id 
                            ) as c_status
                on contact_status.obs_group_id = c_status.status_obs_group_id

                group by obs_group_id
            ) as contact_prior_tests
            -- end
            order by contact_prior_tests.contact_age
        )   

union
    ( select Client_Name, Contact_Name, contact_age, contact_gender,Contact_HIV_Status from
    
        ( select Client_Name, Contact_Name, contact_age, contact_gender,c_status.Contact_HIV_Status from
        
            (
                SELECT concat(given_name,' ', family_name) as Client_Name, concat(firstname,' ',surname) as Contact_Name, contact_age, c_gender.contact_gender, contact_ages.obs_group_id
                    from
                    (
                        SELECT given_name, family_name, concept_id, firstname, surname,age_set.contact_age, obs_group_id from
                        (
                            -- Contact Firstname and surname
                            SELECT first_name_set.given_name, first_name_set.family_name, first_name_set.concept_id, firstname, surname, first_name_set.obs_group_id from
                            (   
                                select obs_id, o.person_id, given_name, family_name, concept_id, value_text as firstname, obs_group_id, o.voided
                                from obs o
                                    INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)									 
								 
                                    where concept_id in (4761)
                                group by obs_group_id) as first_name_set 

                            inner join 
                            (
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
                                -- Contact age
                                select obs_id, o.person_id, value_numeric as contact_age, o.obs_group_id as age_obs_group_id, o.voided  
                                from obs o
                                 INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)	
                                and o.obs_group_id in (
                                            select oss.obs_group_id
                                            from obs oss inner join person p on oss.person_id=p.person_id 
                                            and oss.concept_id = 4769 
                                            and oss.voided=0
        								    and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE) 
                                )
                                    
                                where concept_id = 4769
                                group by obs_group_id 
                            ) as age_set 
                        on names.obs_group_id = age_set.age_obs_group_id
                    
                    ) as contact_ages

                            inner join
                                (
                                    -- Contact gender
                                    select obs_id, o.person_id, IF(value_coded = 1088,'F','M') as contact_gender, o.obs_group_id as gender_obs_group_id, o.voided  
                                    from obs o
                                           INNER JOIN patient ON o.person_id = patient.patient_id 
                                            INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                            INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                            INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
                
                                        AND o.voided=0   
                                        AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)									 
                                    and o.value_coded in (1088,1087)
                                    and o.obs_group_id in (
                                                select oss.obs_group_id
                                                from obs oss inner join person p on oss.person_id=p.person_id 
                                                and oss.concept_id = 4770 
                                                and oss.voided=0
            								    and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE) 
                                    )                    
                                    and o.concept_id in(4770)  
                                    group by obs_group_id 
                                ) as c_gender 
                    on contact_ages.obs_group_id = c_gender.gender_obs_group_id
           
            ) as contact_status

                    inner join
                        (
                            -- Contact newly tested for HIV
                            select obs_id, o.person_id, 
                                         case 
                                            when value_coded = 1738 then 'New_Positive'
                                            when value_coded = 1016 then 'New_Negative'
                                            when value_coded = 4220 then 'New_Indeterminate'  
                                            else 'Not_Tested' end as Contact_HIV_Status,
                                            o.obs_group_id as status_obs_group_id 
                            from obs o
                                 INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)	

                                and o.value_coded in (1738,1016,4220)
                                and o.obs_group_id in (
                                        select oss.obs_group_id
                                        from obs oss inner join person p on oss.person_id=p.person_id 
                                        and oss.voided=0 
                                        and oss.value_coded in (1738,1016,4220) 
                                        and oss.concept_id = 4778 
    								    and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                            )                    
                            and o.concept_id in(4778) 
                            group by obs_group_id 
                        ) as c_status
            on contact_status.obs_group_id = c_status.status_obs_group_id

            group by obs_group_id
        
        ) as contacts_newly_tested

        order by contacts_newly_tested.contact_age
    )

union
    ( select Client_Name, Contact_Name, contact_age, contact_gender,Contact_HIV_Status from
    
        ( select Client_Name, Contact_Name, contact_age, contact_gender,c_status.Contact_HIV_Status from
        
            (
                SELECT concat(given_name,' ', family_name) as Client_Name, concat(firstname,' ',surname) as Contact_Name, contact_age, c_gender.contact_gender, contact_ages.obs_group_id
                    from
                    (
                        SELECT given_name, family_name, concept_id, firstname, surname,age_set.contact_age, obs_group_id from
                        (
                            -- Contact Firstname and surname
                            SELECT first_name_set.given_name, first_name_set.family_name, first_name_set.concept_id, firstname, surname, first_name_set.obs_group_id from
                            (   
                                select obs_id, o.person_id, given_name, family_name, concept_id, value_text as firstname, obs_group_id, o.voided
                                from obs o
                                     INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)	

                                    where concept_id in (4761)
                                group by obs_group_id) as first_name_set 

                            inner join 
                            (
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
                                -- Contact Age
                                select obs_id, o.person_id, value_numeric as contact_age, o.obs_group_id as age_obs_group_id, o.voided  
                                from obs o
                                        INNER JOIN patient ON o.person_id = patient.patient_id 
                                        INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                        INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                        INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
            
                                    AND o.voided=0   
                                    AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)									 
                                
                                and o.obs_group_id in (
                                            select oss.obs_group_id
                                            from obs oss 
                                            inner join person p on oss.person_id=p.person_id 
                                            and oss.concept_id = 4769 
                                            and oss.voided=0
        								    and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE) 
                                )
                                    
                                where concept_id = 4769
                                group by obs_group_id 
                            ) as age_set 
                        on names.obs_group_id = age_set.age_obs_group_id
                    
                    ) as contact_ages

                            inner join
                                ( -- Contact gender
                                    select obs_id, o.person_id, IF(value_coded = 1088,'F','M') as contact_gender, o.obs_group_id as gender_obs_group_id, o.voided  
                                    from obs o
                                        INNER JOIN patient ON o.person_id = patient.patient_id 
                                        INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                        INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                        INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
            
                                    AND o.voided=0   
                                    AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)					 
								 
                                    and o.value_coded in (1088,1087)

                                    and o.obs_group_id in (
                                        select oss.obs_group_id
                                        from obs oss inner join person p on oss.person_id=p.person_id 
                                        and oss.voided=0 
                                        and oss.value_coded in (2147) 
                                        and oss.concept_id = 4787
    								    and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                                    )                    
                                    and o.concept_id in(4770) 
                                    group by obs_group_id 
                                ) as c_gender 
                    on contact_ages.obs_group_id = c_gender.gender_obs_group_id

            ) as contact_status

                    inner join
                        (
                            -- Contact known HIV status
                            select obs_id, o.person_id, 
                                        case 
                                            when value_coded = 4783 then 'Known (+)'
                                            when value_coded = 4784 then 'Known (+) on Art'
                                            when value_coded = 4785 then 'Kwown (-)'
                                            when value_coded = 4321 then 'Declined'  
                                            else 'Not_Tested' end as Contact_HIV_Status,
                                            o.obs_group_id as status_obs_group_id 
                            from obs o
                                   INNER JOIN patient ON o.person_id = patient.patient_id 
                                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                    INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type IN (3,5) AND patient_identifier.preferred=1
        
                                AND o.voided=0   
                                AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)					 

                                and o.value_coded in (4783,4784,4785,4321) 
                                and o.obs_group_id in (
                                        select oss.obs_group_id
                                        from obs oss inner join person p on oss.person_id=p.person_id 
                                        and oss.voided=0 
                                        and oss.value_coded in (2147) 
                                        and oss.concept_id = 4787
								        and oss.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                               )                    
                            and o.concept_id in(4782) 
                            group by obs_group_id 
                        ) as c_status 
                        
            on contact_status.obs_group_id = c_status.status_obs_group_id

            group by obs_group_id
        
        ) as known_status

        order by known_status.contact_age
    )

) as all_contacts_with_status