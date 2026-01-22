-- Clients with ART follows up forms
SELECT DISTINCT
	Intakes_table.Location,
	SUM(1) AS 'Total Registered',
	SUM(IF(Intakes_table.Status = 'Intake', 1, 0)) AS Intakes,
	round((SUM(IF(Intakes_table.Status = 'Intake', 1, 0))/SUM(1))*100) AS '% with Intakes',
	round((SUM(IF(Intakes_table.Status = 'No Intake', 1, 0))/SUM(1))*100) AS '% without Intakes'
FROM
	(SELECT distinct patientIdentifier AS "Patient Identifier", ART_Number AS "ART Number", patientName AS "Patient Name", Age, Gender, location_name AS Location, Status

	FROM
        
	-- clients with ART Follow ups
	(	
		SELECT distinct 
			pi1.identifier AS patientIdentifier,
			pi2.identifier AS ART_Number,
			concat(pn.given_name, ' ', pn.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS Age,
			p.gender AS Gender,
			l.name as location_name,
			if(o.person_id in (select person_id from obs where concept_id = 2249),"Intake","No Intake") as Status
							
		FROM person p
		
		INNER JOIN obs o ON o.person_id = p.person_id AND o.voided = 0 AND o.person_id in (select person_id from obs where concept_id = 2403 and voided = 0) AND o.person_id not in (select person_id from obs where concept_id = 5416 and value_coded = 1 and voided = 0)
		INNER JOIN person_name pn ON p.person_id = pn.person_id
		INNER JOIN patient_identifier pi1 ON pi1.patient_id = p.person_id AND pi1.voided = 0 and pi1.preferred = 1 AND pi1.identifier_type = 3
		LEFT JOIN patient_identifier pi2 ON pi2.patient_id = p.person_id AND pi2.identifier_type = 5
		JOIN location l on o.location_id = l.location_id and l.retired=0
		WHERE 	p.voided = 0
		group by pi1.identifier

UNION
-- clients with ART unique numbers but no intakes

		SELECT distinct 
			patient_identifier.identifier AS patientIdentifier,
			p.identifier AS ART_Number,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender,
			l.name as location_name,
			if(o.person_id in (select person_id from obs where concept_id = 2249),"Intake","No Intake") as Status				
		FROM obs o
			INNER JOIN patient ON o.person_id = patient.patient_id
			INNER JOIN patient_identifier p ON o.person_id = p.patient_id
			INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
			INNER JOIN person_name ON person.person_id = person_name.person_id
			INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
			JOIN location l on o.location_id = l.location_id and l.retired=0
			WHERE p.identifier_type = 5
			AND o.voided = 0
			AND o.person_id not in (select person_id from obs where concept_id = 2403 and voided = 0)
			group by patient_identifier.identifier

	) AS Location_summary
) AS Intakes_table
group by Intakes_table.Location

UNION ALL

SELECT DISTINCT
	'Total' AS Location,
	SUM(1) AS 'Total Registered',
	SUM(IF(Intakes_table.Status = 'Intake', 1, 0)) AS Intakes,
	round((SUM(IF(Intakes_table.Status = 'Intake', 1, 0))/SUM(1))*100) AS '% with Intakes',
	round((SUM(IF(Intakes_table.Status = 'No Intake', 1, 0))/SUM(1))*100) AS '% without Intakes'
FROM
	(SELECT distinct patientIdentifier AS "Patient Identifier", ART_Number AS "ART Number", patientName AS "Patient Name", Age, Gender, location_name AS Location, Status

	FROM
        
	-- clients with ART Follow ups
	(	
		SELECT distinct 
			pi1.identifier AS patientIdentifier,
			pi2.identifier AS ART_Number,
			concat(pn.given_name, ' ', pn.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS Age,
			p.gender AS Gender,
			l.name as location_name,
			if(o.person_id in (select person_id from obs where concept_id = 2249),"Intake","No Intake") as Status
							
		FROM person p
		
		INNER JOIN obs o ON o.person_id = p.person_id AND o.voided = 0 AND o.person_id in (select person_id from obs where concept_id = 2403 and voided = 0) AND o.person_id not in (select person_id from obs where concept_id = 5416 and value_coded = 1 and voided = 0)
		INNER JOIN person_name pn ON p.person_id = pn.person_id
		INNER JOIN patient_identifier pi1 ON pi1.patient_id = p.person_id AND pi1.voided = 0 and pi1.preferred = 1 AND pi1.identifier_type = 3
		LEFT JOIN patient_identifier pi2 ON pi2.patient_id = p.person_id AND pi2.identifier_type = 5
		JOIN location l on o.location_id = l.location_id and l.retired=0
		WHERE 	p.voided = 0
		group by pi1.identifier

UNION
-- clients with ART unique numbers but no intakes

		SELECT distinct 
			patient_identifier.identifier AS patientIdentifier,
			p.identifier AS ART_Number,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender,
			l.name as location_name,
			if(o.person_id in (select person_id from obs where concept_id = 2249),"Intake","No Intake") as Status				
		FROM obs o
			INNER JOIN patient ON o.person_id = patient.patient_id
			INNER JOIN patient_identifier p ON o.person_id = p.patient_id
			INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
			INNER JOIN person_name ON person.person_id = person_name.person_id
			INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
			JOIN location l on o.location_id = l.location_id and l.retired=0
			WHERE p.identifier_type = 5
			AND o.voided = 0
			AND o.person_id not in (select person_id from obs where concept_id = 2403 and voided = 0)
			group by patient_identifier.identifier

	) AS Location_summary
) AS Intakes_table
