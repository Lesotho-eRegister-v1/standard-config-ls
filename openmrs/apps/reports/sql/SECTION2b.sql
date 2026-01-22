            
SELECT Heading,	   
 IF(Id IS NULL, 0, COUNT(Id)) AS Totals 

FROM
    ( 
    SELECT DISTINCT Id,Heading
    FROM(
        (SELECT  Id,'Transfer_In_This_Month' as Heading
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
            AND o.concept_id = 2396 
            AND MONTH(obs_datetime) = MONTH(CAST('2020-07-31' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2020-07-31' AS DATE))
        )transferin)

        UNION

        (SELECT  Id,'Transfer_Out_This_Month' as Heading
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
            AND o.concept_id = 4155 and o.value_coded = 2146 
            AND MONTH(obs_datetime) = MONTH(CAST('2020-07-31' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2020-07-31' AS DATE))
        )transferout)

        UNION

        (SELECT DISTINCT Id,'ART_Restart' as Heading
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
            AND o.concept_id = 3708 
            AND MONTH(obs_datetime) = MONTH(CAST('2020-07-31' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2020-07-31' AS DATE))
        )restarted)

        UNION

        (SELECT DISTINCT Id,'Dead' as Heading
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
            AND MONTH(death_date) = MONTH(CAST('2020-07-31' AS DATE)) 
            AND YEAR(death_date) = YEAR(CAST('2020-07-31' AS DATE))
            AND o.person_id in
                            (
                select person_id 
                from obs 
                where concept_id = 2249
                ) 
            
        )Dead)

        UNION

        (SELECT DISTINCT Id,'Stopped' as Heading
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
            AND o.concept_id = 2300 
            AND MONTH(obs_datetime) = MONTH(CAST('2020-07-31' AS DATE)) 
            AND YEAR(obs_datetime) = YEAR(CAST('2020-07-31' AS DATE))
        )stopped)

        UNION

        (SELECT DISTINCT Id,'Lost' as Heading
        FROM(
select distinct o.person_id AS Id,
                            patient_identifier.identifier AS patientIdentifier,
                            floor(datediff(CAST('2020-07-31' AS DATE), person.birthdate)/365) AS Age,
                            person.gender AS Gender,
                            observed_age_group.name AS age_group
from obs o 
	 -- PATIENTS WHO HAVE NOT SHOWED UP FOR THEIR APPOINTMENT FOR 4 WEEKS to 3 MONTHS (i.e. 29 to 89 days)
	 inner join patient on o.person_id = patient.patient_id
						 and patient.voided = 0 AND o.voided = 0
						 and o.concept_id = 3752
						 and o.obs_id in (
								select os.obs_id
								from obs os
								where os.concept_id=3752
								and os.obs_id in (
									select observation_id
									from
										(select SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) AS observation_id, max(oss.obs_datetime)
										from obs oss 
											inner join person p on oss.person_id=p.person_id and oss.concept_id = 3752 and oss.voided=0
											and oss.value_datetime <= cast('2020-07-31' as date)
										group by p.person_id) as latest_followup_obs
								)
								and os.value_datetime < cast('2020-07-31' as date)
								and datediff(cast('2020-07-31' as date), os.value_datetime) > 90
						 )
						 
				and o.person_id not in (
							select distinct os.person_id
							from obs os
							where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
							AND MONTH(os.obs_datetime) = MONTH(CAST('2020-07-31' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('2020-07-31' AS DATE))
							)

				and o.person_id not in (
							select distinct(o.person_id)
							from obs o
							where o.person_id in (
							-- TOUTS
									select distinct person_id
											from
											(
												select os.person_id, CAST(max(os.value_datetime) AS DATE) as latest_transferout
												from obs os
												where os.concept_id=2266
												group by os.person_id
												having latest_transferout <= CAST('2020-07-31' AS DATE)
											) as TOUTS
										
											 where TOUTS.person_id not in
												 (
													 select oss.person_id
													 from obs oss
													 where concept_id = 3843
													 and CAST(oss.obs_datetime AS DATE) > latest_transferout
													 and CAST(oss.obs_datetime AS DATE) <= CAST('2020-07-31' AS DATE)
												 )
						   
										)
							and o.person_id not in(
										select distinct os.person_id
										from obs os
										where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
										AND MONTH(os.obs_datetime) = MONTH(CAST('2020-07-31' AS DATE)) 
										AND YEAR(os.obs_datetime) = YEAR(CAST('2020-07-31' AS DATE))
							)
										)					

						 and o.person_id not in (
									select person_id 
									from person 
									where death_date <= cast('2020-07-31' as date)
									and dead = 1
						 )
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1						 
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('2020-07-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE 	observed_age_group.report_group_name = 'Modified_Ages'
				   and o.person_id not in (
							-- HAVE TO FIND A BETTER SOLUTION FOR THIS INNER QUERY (STORED PROC OR STORED FUNCTION)
						    select patient.patient_id
										from obs os
												-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
												 INNER JOIN patient ON os.person_id = patient.patient_id
												  AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -1 MONTH)) and YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -1 MONTH))
												  AND patient.voided = 0 AND os.voided = 0 
												  AND (os.concept_id = 4174 and (os.value_coded = 4176 or os.value_coded = 4177 or os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247)))
						    AND 
							o.person_id not in (
							select patient.patient_id
											from obs os
											-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -2 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -2 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0
												 AND os.concept_id = 4174 and (os.value_coded = 4177 or os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247))

						    AND
							o.person_id not in (						  
							select patient.patient_id
											from obs os
											-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -3 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -3 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and (os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247))

							AND
							o.person_id not in (
							select patient.patient_id

											from obs os
											-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -4 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -4 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and (os.value_coded = 4246 or os.value_coded = 4247))
							AND
							o.person_id not in (
							select patient.patient_id

											from obs os
											-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -5 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -5 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and os.value_coded = 4247)
									
							AND
							o.person_id not in (
							select patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -1 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -1 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4175
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -1 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -1 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('2020-07-31' AS DATE)) BETWEEN 0 AND 28			
											))
							AND
							o.person_id not in (
											select patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -2 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -2 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4176
												 AND o.person_id in (
													select distinct os.person_id 
													from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -2 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -2 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('2020-07-31' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id AS Id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -3 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -3 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4177
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -3 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -3 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('2020-07-31' AS DATE)) BETWEEN 0 AND 28
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -4 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -4 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4245
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -4 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -4 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('2020-07-31' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id AS Id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -5 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -5 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4246
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -5 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -5 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('2020-07-31' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -6 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -6 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4247
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -6 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('2020-07-31' AS DATE), INTERVAL -6 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('2020-07-31' AS DATE)) BETWEEN 0 AND 28
											))
        )lost)
		
		UNION ALL
		SELECT  '','Transfer_In_This_Month'
		UNION ALL
		SELECT  '','Transfer_Out_This_Month'
		UNION ALL
		SELECT  '','ART_Restart'
		UNION ALL
		SELECT  '','Dead'
		UNION ALL
		SELECT  '','Stopped'
		UNION ALL
		SELECT  '','Lost'
	
    )all_lost
    )all_agg
    GROUP BY Heading
	ORDER By FIELD (Heading,'Transfer_In_This_Month','Transfer_Out_This_Month','ART_Restart','Dead','Stopped','Lost' )