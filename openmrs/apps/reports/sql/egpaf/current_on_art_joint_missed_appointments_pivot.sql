SELECT TotalPatientAppointmentStatus.AgeGroup
		, TotalPatientAppointmentStatus.Missed_Males
		, TotalPatientAppointmentStatus.Missed_Females 
		, TotalPatientAppointmentStatus.Defaulted_Males
		, TotalPatientAppointmentStatus.Defaulted_Females
		, TotalPatientAppointmentStatus.LTFU_Males
		, TotalPatientAppointmentStatus.LTFU_Females
		, TotalPatientAppointmentStatus.Total

FROM 

(

(SELECT PatientAppointmentStatus.age_group AS 'AgeGroup'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'Missed' AND PatientAppointmentStatus.Gender = 'M', 1, 0))) AS 'Missed_Males'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'Missed' AND PatientAppointmentStatus.Gender = 'F', 1, 0))) AS 'Missed_Females'
	    , IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'Defaulted' AND PatientAppointmentStatus.Gender = 'M', 1, 0))) AS 'Defaulted_Males'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'Defaulted' AND PatientAppointmentStatus.Gender = 'F', 1, 0))) AS 'Defaulted_Females'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'LTFU' AND PatientAppointmentStatus.Gender = 'M', 1, 0))) AS 'LTFU_Males'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'LTFU' AND PatientAppointmentStatus.Gender = 'F', 1, 0))) AS 'LTFU_Females'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(1)) as 'Total'
		, PatientAppointmentStatus.sort_order
FROM

(SELECT  Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age, age_group, Gender, App_Status, sort_order

FROM
        (
		   select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   'Missed' AS App_Status,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- PATIENTS WHO HAVE NOT RECEIVED ARV's WITHIN 4 WEEKS (i.e. 28 days) OF THIER LAST MISSED DRUG PICK-UP
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.concept_id = 3752 and o.value_datetime in
						 (				
								select latestFU
								from
									(
										select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having Num_Days > 0 and Num_Days <= 28
									) AS Defauled
						 )
						 AND o.person_id in (
								select person_id
								from (
										select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 and os.value_datetime < CAST('#endDate#' AS DATE)
										group by os.person_id
										having Num_Days > 0 and Num_Days <= 28
								) AS MissedAppointWithin28Days
						 )
						 AND o.person_id not in (
								select distinct os.person_id
								from obs os
								where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
								AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )

						AND o.person_id not in (																		 
									select distinct os.person_id 
										from obs os
										where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
										(select person_id from
											(select person_id who, max(value_datetime) latest
											from obs 
											where concept_ID = 2266
																group by person_id) one,
											
											 (
											select person_id,obs_datetime 
											from obs 
											where concept_id = 3843 ) two
											
											where who = person_id
											and DATE(obs_datetime) > DATE(latest))
											)													  														 							 
									)
						AND o.person_id not in (
									select person_id 
									from person 
									where death_date <= '#endDate#' 
									and dead = 1
						)
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1						 
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE 	observed_age_group.report_group_name = 'Modified_Ages' AND
							o.person_id not in (
							-- HAVE TO FIND A BETTER SOLUTION FOR THIS INNER QUERY (STORED PROC OR STORED FUNCTION)
						    select patient.patient_id
										from obs os
												-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
												 INNER JOIN patient ON os.person_id = patient.patient_id
												  AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												  AND patient.voided = 0 AND os.voided = 0 
												  AND (os.concept_id = 4174 and (os.value_coded = 4176 or os.value_coded = 4177 or os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247)))
						    AND 
							o.person_id not in (
							select patient.patient_id
											from obs os
											-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0
												 AND os.concept_id = 4174 and (os.value_coded = 4177 or os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247))

						    AND
							o.person_id not in (						  
							select patient.patient_id
											from obs os
											-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and (os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247))

							AND
							o.person_id not in (
							select patient.patient_id

											from obs os
											-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and (os.value_coded = 4246 or os.value_coded = 4247))
							AND
							o.person_id not in (
							select patient.patient_id

											from obs os
											-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and os.value_coded = 4247)
									
							AND
							o.person_id not in (
							select patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4175
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28			
											))
							AND
							o.person_id not in (
							select patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4176
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id AS Id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4177
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4245
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id AS Id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4246
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4247
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
											))
			
			
			UNION
			
			
			SELECT distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											  'Defaulted' AS App_Status,
											   observed_age_group.sort_order AS sort_order
			FROM obs o
									INNER JOIN patient ON o.person_id = patient.patient_id 
									 AND patient.voided = 0 AND o.voided = 0
									and o.concept_id = 3752 and o.value_datetime in
									(				
										select latestFU
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days > 28 and Num_Days < 90
											) AS Defauled
									)									
									and o.person_id in
									(				
										select person_id
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days > 28 and Num_Days < 90
											) AS Defauled
									)
									AND o.person_id not in (																		 
									select distinct os.person_id 
										from obs os
										where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
										(select person_id from
											(select person_id who, max(value_datetime) latest
											from obs 
											where concept_ID = 2266
																group by person_id) one,
											
											 (
											select person_id,obs_datetime 
											from obs 
											where concept_id = 3843 ) two
											
											where who = person_id
											and DATE(obs_datetime) > DATE(latest))
											)													  														 							 
									)
									AND o.person_id not in (
									select person_id 
									from person 
									where death_date <= '#endDate#' 
									and dead = 1
												)
									 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
									 INNER JOIN person_name ON person.person_id = person_name.person_id
									 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
									 INNER JOIN reporting_age_group AS observed_age_group ON CAST('#endDate#' AS DATE) 
									 BETWEEN
									(DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
										AND 
									(DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))

			WHERE observed_age_group.report_group_name = 'Modified_Ages'
			
			
			UNION
			
			
			SELECT distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   'LTFU' AS App_Status,
											   observed_age_group.sort_order AS sort_order
			FROM obs o
									INNER JOIN patient ON o.person_id = patient.patient_id 
									AND patient.voided = 0 AND o.voided = 0
									and o.concept_id = 3752 and o.value_datetime in
									(				
										select latestFU
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days >= 90
											) AS Lost
									)									
									and o.person_id in
									(				
										select person_id
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days >= 90
											) AS Lost
									)
									AND o.person_id not in (																		 
									select distinct os.person_id 
										from obs os
										where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
										(select person_id from
											(select person_id who, max(value_datetime) latest
											from obs 
											where concept_ID = 2266
																group by person_id) one,
											
											 (
											select person_id,obs_datetime 
											from obs 
											where concept_id = 3843 ) two
											
											where who = person_id
											and DATE(obs_datetime) > DATE(latest))
											)													  														 							 
									)
									AND o.person_id not in (
									select person_id 
									from person 
									where death_date <= '#endDate#' 
									and dead = 1
												)
								 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 INNER JOIN reporting_age_group AS observed_age_group ON CAST('#endDate#' AS DATE)
								 BETWEEN 
								(DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
									AND 
								(DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))

			WHERE observed_age_group.report_group_name = 'Modified_Ages'
			
		) AS Patient_MissedAppointments
		
) AS PatientAppointmentStatus

GROUP BY PatientAppointmentStatus.age_group
ORDER BY PatientAppointmentStatus.sort_order)

UNION ALL


(SELECT 'Total' AS 'AgeGroup'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'Missed' AND PatientAppointmentStatus.Gender = 'M', 1, 0))) AS 'Missed_7days_Males'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'Missed' AND PatientAppointmentStatus.Gender = 'F', 1, 0))) AS 'Missed_7Days_Females'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'Defaulted' AND PatientAppointmentStatus.Gender = 'M', 1, 0))) AS 'Defaulted_Males'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'Defaulted' AND PatientAppointmentStatus.Gender = 'F', 1, 0))) AS 'Defaulted_Females'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'LTFU' AND PatientAppointmentStatus.Gender = 'M', 1, 0))) AS 'LTFU_Males'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(IF(PatientAppointmentStatus.App_Status = 'LTFU' AND PatientAppointmentStatus.Gender = 'F', 1, 0))) AS 'LTFU_Females'
		, IF(PatientAppointmentStatus.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
FROM

(SELECT  Total_MissedAppointments.Id
			, Total_MissedAppointments.patientIdentifier AS "Patient Identifier"
			, Total_MissedAppointments.patientName AS "Patient Name"
			, Total_MissedAppointments.Age
			, Total_MissedAppointments.Gender
			, Total_MissedAppointments.App_Status
FROM
        (
		   select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   'Missed' AS App_Status,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- PATIENTS WHO HAVE NOT RECEIVED ARV's WITHIN 4 WEEKS (i.e. 28 days) OF THIER LAST MISSED DRUG PICK-UP
						 INNER JOIN patient ON o.person_id = patient.patient_id
						 AND patient.voided = 0 AND o.voided = 0
						 AND o.concept_id = 3752 and o.value_datetime in
						 (				
								select latestFU
								from
									(
										select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 
										group by os.person_id
										having Num_Days > 0 and Num_Days <= 28
									) AS Defauled
						 )
						 AND o.person_id in (
								select person_id
								from (
										select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
										from obs os
										inner join person_name pn on os.person_id = pn.person_id
										inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
										inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
										where os.concept_id = 3752 and os.value_datetime < CAST('#endDate#' AS DATE)
										group by os.person_id
										having Num_Days > 0 and Num_Days <= 28
								) AS MissedAppointWithin28Days
						 )
						 AND o.person_id not in (
								select distinct os.person_id
								from obs os
								where (os.concept_id = 3843 AND os.value_coded = 3841 OR os.value_coded = 3842)
								AND os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
						 )

						AND o.person_id not in (																		 
									select distinct os.person_id 
										from obs os
										where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
										(select person_id from
											(select person_id who, max(value_datetime) latest
											from obs 
											where concept_ID = 2266
																group by person_id) one,
											
											 (
											select person_id,obs_datetime 
											from obs 
											where concept_id = 3843 ) two
											
											where who = person_id
											and DATE(obs_datetime) > DATE(latest))
											)													  														 							 
									)
						AND o.person_id not in (
									select person_id 
									from person 
									where death_date <= '#endDate#' 
									and dead = 1
						)
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1						 
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE 	observed_age_group.report_group_name = 'Modified_Ages' AND
							o.person_id not in (
							-- HAVE TO FIND A BETTER SOLUTION FOR THIS INNER QUERY (STORED PROC OR STORED FUNCTION)
						    select patient.patient_id
										from obs os
												-- CAME IN PREVIOUS 1 MONTH AND WAS GIVEN (2, 3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
												 INNER JOIN patient ON os.person_id = patient.patient_id
												  AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) and YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
												  AND patient.voided = 0 AND os.voided = 0 
												  AND (os.concept_id = 4174 and (os.value_coded = 4176 or os.value_coded = 4177 or os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247)))
						    AND 
							o.person_id not in (
							select patient.patient_id
											from obs os
											-- CAME IN PREVIOUS 2 MONTHS AND WAS GIVEN (3, 4, 5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0
												 AND os.concept_id = 4174 and (os.value_coded = 4177 or os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247))

						    AND
							o.person_id not in (						  
							select patient.patient_id
											from obs os
											-- CAME IN PREVIOUS 3 MONTHS AND WAS GIVEN (4, 5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and (os.value_coded = 4245 or os.value_coded = 4246 or os.value_coded = 4247))

							AND
							o.person_id not in (
							select patient.patient_id

											from obs os
											-- CAME IN PREVIOUS 4 MONTHS AND WAS GIVEN (5, 6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and (os.value_coded = 4246 or os.value_coded = 4247))
							AND
							o.person_id not in (
							select patient.patient_id

											from obs os
											-- CAME IN PREVIOUS 5 MONTHS AND WAS GIVEN (6 MONHTS SUPPLY OF DRUGS)
											 INNER JOIN patient ON os.person_id = patient.patient_id 
												 AND MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												 AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												 AND patient.voided = 0 AND os.voided = 0 
												 AND os.concept_id = 4174 and os.value_coded = 4247)
									
							AND
							o.person_id not in (
							select patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4175
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -1 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28			
											))
							AND
							o.person_id not in (
							select patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4176
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -2 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id AS Id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4177
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -3 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4245
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -4 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id AS Id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4246
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -5 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
															
											))
							AND
							o.person_id not in (
							select distinct patient.patient_id
											from obs o
											 INNER JOIN patient ON o.person_id = patient.patient_id
												 AND MONTH(o.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												 AND YEAR(o.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
												 AND patient.voided = 0 AND o.voided = 0 
												 AND o.concept_id = 4174 and o.value_coded = 4247
												 AND o.person_id in (
													select distinct os.person_id from obs os
													where 
														MONTH(os.obs_datetime) = MONTH(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH)) 
														AND YEAR(os.obs_datetime) = YEAR(DATE_ADD(CAST('#endDate#' AS DATE), INTERVAL -6 MONTH))
														AND os.concept_id = 3752 AND DATEDIFF(os.value_datetime, CAST('#endDate#' AS DATE)) BETWEEN 0 AND 28
											))
														
									 
			
			UNION
			
			
			
			SELECT distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   'Defaulted' AS App_Status,
											   observed_age_group.sort_order AS sort_order

			FROM obs o
									INNER JOIN patient ON o.person_id = patient.patient_id 
									AND patient.voided = 0 AND o.voided = 0
									and o.concept_id = 3752 and o.value_datetime in
									(				
										select latestFU
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days > 28 and Num_Days < 90
											) AS Defauled
									)									
									and o.person_id in
									(				
										select person_id
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days > 28 and Num_Days < 90
											) AS Defauled
									)
									AND o.person_id not in (																		 
									select distinct os.person_id 
										from obs os
										where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
										(select person_id from
											(select person_id who, max(value_datetime) latest
											from obs 
											where concept_ID = 2266
																group by person_id) one,
											
											 (
											select person_id,obs_datetime 
											from obs 
											where concept_id = 3843 ) two
											
											where who = person_id
											and DATE(obs_datetime) > DATE(latest))
											)													  														 							 
									)
									AND o.person_id not in (
									select person_id 
									from person 
									where death_date <= '#endDate#' 
									and dead = 1
												)
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1						 
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE 	observed_age_group.report_group_name = 'Modified_Ages'
									 
									 
			
			UNION
			
			
			SELECT distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
											   person.gender AS Gender,
											   observed_age_group.name AS age_group,
											   'LTFU' AS App_Status,
											   observed_age_group.sort_order AS sort_order
											   
											  
			FROM obs o
									INNER JOIN patient ON o.person_id = patient.patient_id 
									AND patient.voided = 0 AND o.voided = 0
									and o.concept_id = 3752 and o.value_datetime in
									(				
										select latestFU
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days >= 90
											) AS Lost
									)									
									and o.person_id in
									(				
										select person_id
										from
											(
												select distinct os.person_id, given_name, family_name, max(os.value_datetime) AS latestFU, datediff(CAST('#endDate#' AS DATE), max(value_datetime)) AS Num_Days
												from obs os
												inner join person_name pn on os.person_id = pn.person_id
												inner join patient p  on pn.person_id = p.patient_id and pn.voided = 0
												inner join person ps on ps.person_id = p.patient_id and ps.voided = 0
												where os.concept_id = 3752 
												group by os.person_id
												having Num_Days >= 90
											) AS Lost
									)
									AND o.person_id not in (																		 
									select distinct os.person_id 
										from obs os
										where (os.concept_id = 4155 and os.value_coded = 2146 and obs_datetime < '#endDate#' and person_id not in 
										(select person_id from
											(select person_id who, max(value_datetime) latest
											from obs 
											where concept_ID = 2266
																group by person_id) one,
											
											 (
											select person_id,obs_datetime 
											from obs 
											where concept_id = 3843 ) two
											
											where who = person_id
											and DATE(obs_datetime) > DATE(latest))
											)													  														 							 
									)
									AND o.person_id not in (
									select person_id 
									from person 
									where death_date <= '#endDate#' 
									and dead = 1
												)
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1						 
						 INNER JOIN reporting_age_group AS observed_age_group ON
						 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE 	observed_age_group.report_group_name = 'Modified_Ages'
							

		) AS Total_MissedAppointments
) AS PatientAppointmentStatus)

) AS TotalPatientAppointmentStatus

ORDER BY TotalPatientAppointmentStatus.sort_order;
