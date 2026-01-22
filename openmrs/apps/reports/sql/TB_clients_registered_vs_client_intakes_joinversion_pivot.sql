SELECT DISTINCT
	   Intakes_vs_Registrations_Agg.location_name AS Location,
	   SUM(1) AS 'Total Registered',	   
	   SUM(IF(Intakes_vs_Registrations_Agg.status = 'Intake', 1, 0)) AS Intakes,
	   round((SUM(IF(Intakes_vs_Registrations_Agg.status = 'Intake', 1, 0))/SUM(1))*100) AS '% with Intakes',
	   round((SUM(IF(Intakes_vs_Registrations_Agg.status = 'No Intake', 1, 0))/SUM(1))*100) AS '% without Intakes'	   
FROM
(

SELECT DISTINCT
		location_name
		, Identifier
		, Name
		, Gender
		, Age
		, Status
FROM 
(

		SELECT DISTINCT
				location_name
				, patientIdentifier as Identifier
				, patientName as Name
				, gender as Gender
				, age as Age
				, status as Status

		FROM
		(

			SELECT DISTINCT
					intake.location_name
					, intake.patientName
					, intake.gender
					, intake.age
					, intake.patientIdentifier
                    ,intake.status
			FROM
					(SELECT DISTINCT
							pi1.identifier AS patientIdentifier,
                            pi2.identifier AS TB_Number,
                            concat(pn.given_name, ' ', pn.family_name) AS patientName,
                            floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS Age,
                            p.gender AS Gender,
                            l.name as location_name,
                            if(o.person_id in 
                                        (select person_id from obs where concept_id = 4153  and voided = 0
                                        -- TB Intake form captured within a year of the start date
                                        and CAST(obs_datetime AS DATE) >= DATE_ADD(CAST('#startDate#'AS DATE), INTERVAL -12 MONTH) ),"Intake","No Intake") as Status
					FROM person p
							INNER JOIN obs o ON o.person_id = p.person_id AND o.voided = 0 
                            AND o.person_id in 
                                            (select person_id from obs where concept_id = 1158
                                            and CAST(obs_datetime AS Date) >= CAST('#startDate#'AS DATE) 
                                            and CAST(obs_datetime AS Date) <= CAST('#endDate#'AS DATE)
                                            and voided = 0)
                                INNER JOIN person_name pn ON p.person_id = pn.person_id and pn.preferred  = 1
                                INNER JOIN patient_identifier pi1 ON pi1.patient_id = p.person_id AND pi1.voided = 0 and pi1.preferred = 1 AND pi1.identifier_type = 3
                                LEFT JOIN patient_identifier pi2 ON pi2.patient_id = p.person_id AND pi2.identifier_type = 7
                                JOIN location l on o.location_id = l.location_id and l.retired=0
                                WHERE p.voided = 0
                                group by pi1.identifier) intake

					) AS IntakesRegistered

) AS RegistrationVsIntakes
ORDER BY  RegistrationVsIntakes.Identifier, RegistrationVsIntakes.location_name, RegistrationVsIntakes.status

) AS Intakes_vs_Registrations_Agg
GROUP BY Intakes_vs_Registrations_Agg.location_name


UNION ALL


SELECT DISTINCT
	   'Total' AS Location,
	   SUM(1) AS 'Total Registered',
	   SUM(IF(Intakes_vs_Registrations_Agg.status = 'Intake', 1, 0)) AS Intakes,
	   round((SUM(IF(Intakes_vs_Registrations_Agg.status = 'Intake', 1, 0))/SUM(1))*100) AS '% with Intakes',
	   round((SUM(IF(Intakes_vs_Registrations_Agg.status = 'No Intake', 1, 0))/SUM(1))*100) AS '% without Intakes'	   
FROM
(

SELECT DISTINCT
		location_name
		, Identifier
		, Name
		, Gender
		, Age
		, Status
FROM 
(

		SELECT DISTINCT
				location_name
				, patientIdentifier as Identifier
				, patientName as Name
				, gender as Gender
				, age as Age
				, status as Status

		FROM
		(

			SELECT DISTINCT
					intake.location_name
					, intake.patientName
					, intake.gender
					, intake.age
					, intake.patientIdentifier
                    ,intake.status
			FROM
					(SELECT DISTINCT
							pi1.identifier AS patientIdentifier,
                            pi2.identifier AS TB_Number,
                            concat(pn.given_name, ' ', pn.family_name) AS patientName,
                            floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS Age,
                            p.gender AS Gender,
                            l.name as location_name,
                            if(o.person_id in 
                                        (select person_id from obs where concept_id = 4153  and voided = 0
                                        -- TB Intake form captured within a year of the start date
                                        and CAST(obs_datetime AS DATE) >= DATE_ADD(CAST('#startDate#'AS DATE), INTERVAL -12 MONTH) ),"Intake","No Intake") as Status
					FROM person p
							INNER JOIN obs o ON o.person_id = p.person_id AND o.voided = 0 
                            AND o.person_id in 
                                            (select person_id from obs where concept_id = 1158
                                            and CAST(obs_datetime AS Date) >= CAST('#startDate#'AS DATE) 
                                            and CAST(obs_datetime AS Date) <= CAST('#endDate#'AS DATE)
                                            and voided = 0)
                                INNER JOIN person_name pn ON p.person_id = pn.person_id and pn.preferred  = 1
                                INNER JOIN patient_identifier pi1 ON pi1.patient_id = p.person_id AND pi1.voided = 0 and pi1.preferred = 1 AND pi1.identifier_type = 3
                                LEFT JOIN patient_identifier pi2 ON pi2.patient_id = p.person_id AND pi2.identifier_type = 7
                                JOIN location l on o.location_id = l.location_id and l.retired=0
                                WHERE p.voided = 0
                                group by pi1.identifier) intake

					) AS IntakesRegistered

) AS RegistrationVsIntakes
ORDER BY  RegistrationVsIntakes.Identifier, RegistrationVsIntakes.location_name, RegistrationVsIntakes.status

) AS Intakes_vs_Registrations_Agg
