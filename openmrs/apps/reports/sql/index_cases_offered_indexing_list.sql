-- ART CLIENTS WITH HVL AND ACCEPTED INDEXING WITH MONITORING TYPE ROUTINE
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name', Age, Gender, age_group, vl_result AS 'Patient_Health_Status','HVL_Routine' as 'Client_Program','Accepted' AS 'Indexing', sort_order
FROM  
		 
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											  concat(o.value_numeric,' ',' m/l') AS vl_result,
											   observed_age_group.sort_order AS sort_order
 
						from obs o
								-- CLIENTS WITH A VIRAL LOAD RESULT DOCUMENTED WITHIN THE LAST 12 MONTHS 
								INNER JOIN patient ON o.person_id = patient.patient_id
								AND o.concept_id = 2254 and o.voided=0
								AND o.obs_id in (
										select os.obs_id
										from obs os
										where os.concept_id=2254
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 2254 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										)
								 		and os.value_numeric > 20
								)
								AND person_id in (
										select os.person_id
										from obs os
										where os.concept_id=4280
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 4280 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										) 
										-- ROUTINE VL MONITORING TYPE ROUTINE
										and os.value_coded = 4281
								)	
								--  ROUTINE VL MONITORING TYPE ROUTINE AND ACCEPTED INDEXING					 
								AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4759 and os.value_coded = 2146
									AND os.voided = 0
									AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								)
								AND o.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

								INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						    WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
		ORDER BY INDEX_CLIENTS.Age)  

UNION

-- ART CLIENTS WHO ACCEPTED/DECLINED INDEXING REGARDLESS OF THEIR VL STATUS 
								
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name', Age, Gender, age_group, ART_CLIENT AS 'Patient_Health_Status','ART Program' as 'Client_Program',Indexing, sort_order
FROM  
		 
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   'ART Patient' AS ART_CLIENT,
												observed_age_group.sort_order AS sort_order,case 
												    when o.value_coded = 2146 then 'Accepted'
												 Else 'Declined' END AS 'Indexing'
 
 
						from obs o
								INNER JOIN patient ON o.person_id = patient.patient_id
                                and o.concept_id = 4759 and o.value_coded IN (2146,2147) and o.voided = 0
                                and o.person_id in ( 
                                     select person_id 
                                     from obs 
                                     where concept_id = 4759 and value_coded IN (2146,2147) and voided = 0
                                     AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                                )
                                and o.person_id in ( 
                                     select person_id 
                                     from obs 
                                     where concept_id = 4814   and voided = 0
                                     AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
                                )

								and o.person_id not in (
									select person_id from 
									obs where concept_id = 4269
									and voided = 0 
									and obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								)							

								AND o.person_id NOT in (
									select os.person_id
									from obs os
									where os.concept_id=4280
									and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
									and os.obs_datetime in (
											select max(oss.obs_datetime)
											from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 4280 and oss.voided=0
											and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
											group by p.person_id
									)
									-- TARGETED VL MONITORING TYPE TARGETED
									and os.value_coded = 4282
								)

								AND
								
								o.person_id not in (
										select os.person_id
										from obs os
										where os.concept_id=4280
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 4280 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										) 
										-- ROUTINE VL MONITORING TYPE ROUTINE
										and os.value_coded = 4281
								)

								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type in (3,5) AND patient_identifier.preferred = 1

								INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						    WHERE observed_age_group.report_group_name = 'Modified_Ages' 
							AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
							) AS INDEX_CLIENTS		 
		ORDER BY INDEX_CLIENTS.Age) 
		
 UNION

-- ART CLIENTS WITH HVL AND DENIED INDEXING WITH MONITORING TYPE ROUTINE
(SELECT  patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name', Age, Gender, age_group, vl_result AS 'Patient_Health_Status','HVL_Routine' as 'Client_Program','Denied' AS 'Indexing', sort_order
FROM  
		 
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   concat(o.value_numeric,' ',' m/l') AS vl_result,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- CLIENTS WITH A VIRAL LOAD RESULT DOCUMENTED WITHIN THE LAST 12 MONTHS 
								INNER JOIN patient ON o.person_id = patient.patient_id
								AND o.concept_id = 2254 and o.voided=0
								AND o.obs_id in (
										select os.obs_id
										from obs os
										where os.concept_id=2254
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 2254 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										)
										and os.value_numeric > 20
								)
								AND person_id in (
										select os.person_id
										from obs os
										where os.concept_id=4280
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 4280 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										) 
										-- ROUTINE VL MONITORING TYPE ROUTINE
										and os.value_coded = 4281
								)	
								--  ROUTINE VL MONITORING TYPE ROUTINE AND DENIED INDEXING					 
								AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4759 and os.value_coded = 2147
									AND os.voided = 0
									AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								)
								AND o.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

								INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						    WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
		ORDER BY INDEX_CLIENTS.Age)  

UNION 

-- ART CLIENTS WITH HVL AND ACCEPTED INDEXING WITH MONITORING TYPE TARGED
(SELECT  patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name',  Age, Gender, age_group, vl_result AS 'Patient_Health_Status','HVL_Targeted' as 'Client_Program','Accepted' AS 'Indexing', sort_order
FROM  
		 (select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											  concat(o.value_numeric,' ',' m/l') AS vl_result,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- CLIENTS WITH A VIRAL LOAD RESULT DOCUMENTED WITHIN THE LAST 12 MONTHS
								INNER JOIN patient ON o.person_id = patient.patient_id
								AND o.concept_id = 2254 and o.voided=0
								AND o.obs_id in (
										select os.obs_id
										from obs os
										where os.concept_id=2254
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 2254 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										) 
										and os.value_numeric > 20
								)
								AND person_id in (
										select os.person_id
										from obs os
										where os.concept_id=4280
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 4280 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										)
										-- TARGETED VL MONITORING TYPE TARGETED
										and os.value_coded = 4282
								)
								 
								--  ROUTINE VL MONITORING TYPE TARGETED AND ACCEPTED INDEXING					 
					 			AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4759 and os.value_coded = 2146
									AND os.voided = 0
									AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								)
								AND o.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

								INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						    WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
		ORDER BY INDEX_CLIENTS.Age) 
		UNION


-- ART CLIENTS WITH HVL AND DENIED INDEXING WITH MONITORING TYPE TARGED
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name',  Age, Gender, age_group, vl_result AS 'Patient_Health_Status','HVL_Targeted' as 'Client_Program','Denied' AS 'Indexing', sort_order
FROM  
		 (select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											  concat(o.value_numeric,' ',' m/l') AS vl_result,
											   observed_age_group.sort_order AS sort_order

						from obs o
								-- CLIENTS WITH A VIRAL LOAD RESULT DOCUMENTED WITHIN THE LAST 12 MONTHS
								INNER JOIN patient ON o.person_id = patient.patient_id
								AND o.concept_id = 2254 and o.voided=0
								AND o.obs_id in (
										select os.obs_id
										from obs os
										where os.concept_id=2254
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 2254 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										) 
										and os.value_numeric > 20
								)
								AND person_id in (
										select os.person_id
										from obs os
										where os.concept_id=4280
										and os.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
										and os.obs_datetime in (
												select max(oss.obs_datetime)
												from obs oss inner join person p on oss.person_id=p.person_id and oss.concept_id = 4280 and oss.voided=0
												and oss.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
												group by p.person_id
										)
										-- TARGETED VL MONITORING TYPE TARGETED
										and os.value_coded = 4282
								)
								 
								--  ROUTINE VL MONITORING TYPE TARGETED AND DENIED INDEXING					 
					 			AND o.person_id in (
									select distinct os.person_id
									from obs os
									where os.concept_id = 4759 and os.value_coded = 2147
									AND os.voided = 0
									AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
								)
								AND o.obs_datetime BETWEEN DATE(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -12 MONTH)) AND CAST('#endDate#' AS DATE)
								INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								INNER JOIN person_name ON person.person_id = person_name.person_id
								INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

								INNER JOIN reporting_age_group AS observed_age_group ON
									CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						    WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
		ORDER BY INDEX_CLIENTS.Age)  

UNION

-- CLIENTS TESTED POSITIVE AND LINKED TO CARE AND ACCEPTED INDEXING
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name',  Age, Gender, age_group, 'Linked' AS 'Patient_Health_Status','HTS' as 'Client_Program','Accepted' AS 'Indexing', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o

						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT LINKED TO CARE
						 AND o.person_id in (
							select distinct os.person_id
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2146
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )
						
						-- EXCLUDE PATIENT THAT HAS TESTED NEGATIVE
						 AND o.person_id not in(
							 select distinct os.person_id
							from obs os
							where os.concept_id = 2165 and os.value_coded = 1016
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)							 
						 )

						 -- LINKED AND ACCEPTED INDEXING						 
						 AND o.person_id in (
							select distinct os.person_id
							from obs os
							where os.concept_id = 4759 and os.value_coded = 2146
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )						  
 						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
ORDER BY INDEX_CLIENTS.Age)

UNION 
-- CLIENTS TESTED POSITIVE AND LINKED TO CARE AND DENIED INDEXING
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name',  Age, Gender, age_group, 'Linked' AS 'Patient_Health_Status','HTS' as 'Client_Program','Denied' AS 'Indexing', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o

						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT LINKED TO CARE
						 AND o.person_id in (
							select distinct os.person_id
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2146
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )
						 -- EXCLUDE PATIENT THAT HAS TESTED NEGATIVE
						 AND o.person_id not in(
							 select distinct os.person_id
							from obs os
							where os.concept_id = 2165 and os.value_coded = 1016
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)							 
						 )

						 -- LINKED AND DENIED INDEXING						 
						 AND o.person_id in (
							select distinct os.person_id
							from obs os
							where os.concept_id = 4759 and os.value_coded = 2147
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )
						  
 						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
ORDER BY INDEX_CLIENTS.Age)

UNION

-- CLIENTS TESTED POSITIVE AND NOT LINKED TO CARE AND ACCEPTED INDEXING
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name',  Age, Gender, age_group, 'Not_Linked' AS 'Patient_Health_Status','HTS' as 'Client_Program','Accepted' AS 'Indexing', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
							          observed_age_group.sort_order AS sort_order

                from obs o
						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT NOT LINKED TO CARE
						 AND o.person_id in (
							select distinct os.person_id 
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2147
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )	
						 -- EXCLUDE PATIENT THAT HAS TESTED NEGATIVE
						 AND o.person_id not in(
							 select distinct os.person_id
							from obs os
							where os.concept_id = 2165 and os.value_coded = 1016
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)							 
						 )

						 -- PATIENT NOT LINKED AND ACCEPTED INDEX	
						 AND o.person_id in (
							select distinct os.person_id
							from obs os
							where os.concept_id = 4759 and os.value_coded = 2146
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )				 
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

						 INNER JOIN reporting_age_group AS observed_age_group ON
						 
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
ORDER BY INDEX_CLIENTS.Age)

UNION

-- CLIENTS TESTED POSITIVE AND NOT LINKED TO CARE AND DENIED INDEXING
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name',  Age, Gender, age_group, 'Not_Linked' AS 'Patient_Health_Status','HTS' as 'Client_Program','Denied' AS 'Indexing', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT NOT LINKED TO CARE
						 AND o.person_id in (
							select distinct os.person_id 
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2147
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )	
						 -- EXCLUDE PATIENT THAT HAS TESTED NEGATIVE
						 AND o.person_id not in(
							 select distinct os.person_id
							from obs os
							where os.concept_id = 2165 and os.value_coded = 1016
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)							 
						 )

						 -- PATIENT NOT LINKED AND DENIED INDEX	
						 AND o.person_id in (
							select distinct os.person_id
							from obs os
							where os.concept_id = 4759 and os.value_coded = 2147
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )				 
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

						 INNER JOIN reporting_age_group AS observed_age_group ON
						 
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
ORDER BY INDEX_CLIENTS.Age)

UNION

-- CLIENTS TESTED POSITIVE AND REFFERED TO OTHER FACILITIES AND ACCEPTED INDEXING
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name',  Age, Gender, age_group, 'Referred' AS 'Patient_Health_Status','HTS' as 'Client_Program','Accepted' AS 'Indexing', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order
 
                from obs o
						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT REFERRED TO OTHER FACILITY
						 AND o.person_id in (
							select distinct os.person_id 
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2922
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 ) 
						 -- EXCLUDE PATIENT THAT HAS TESTED NEGATIVE
						 AND o.person_id not in(
							 select distinct os.person_id
							from obs os
							where os.concept_id = 2165 and os.value_coded = 1016
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)							 
						 )
						 
						 -- PATIENT NOT REFFERED AND ACCEPTED INDEXING	
						 AND o.person_id in (
							select distinct os.person_id
							from obs os
							where os.concept_id = 4759 and os.value_coded = 2146
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )			
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

						 INNER JOIN reporting_age_group AS observed_age_group ON

						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
ORDER BY INDEX_CLIENTS.Age) 
 
UNION

-- CLIENTS TESTED POSITIVE AND REFFERED TO OTHER FACILITIES AND DENIED INDEXING
(SELECT patientIdentifier AS 'Patient Identifier', patientName AS 'Patient Name',  Age, Gender, age_group, 'Referred' AS 'Patient_Health_Status','HTS' as 'Client_Program','Denied' AS 'Indexing', sort_order
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order
 
                from obs o
						-- HTS CLIENTS WITH POSITIVE HIV STATUS BY SEX AND AGE
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 
						 -- PATIENT REFERRED TO OTHER FACILITY
						 AND o.person_id in (
							select distinct os.person_id 
							from obs os
							where os.concept_id = 4239 and os.value_coded = 2922
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 ) 
						 -- EXCLUDE PATIENT THAT HAS TESTED NEGATIVE
						 AND o.person_id not in(
							 select distinct os.person_id
							from obs os
							where os.concept_id = 2165 and os.value_coded = 1016
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)							 
						 )
						 
						 -- PATIENT NOT REFFERED AND DENIED INDEXING	
						 AND o.person_id in (
							select distinct os.person_id
							from obs os
							where os.concept_id = 4759 and os.value_coded = 2147
							AND os.voided = 0
							AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )			
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred = 1

						 INNER JOIN reporting_age_group AS observed_age_group ON

						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS INDEX_CLIENTS
ORDER BY INDEX_CLIENTS.Age)

