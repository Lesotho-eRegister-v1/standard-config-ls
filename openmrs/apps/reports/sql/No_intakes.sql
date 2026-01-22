-- Clients with ART follows but no intakes
(SELECT distinct patientIdentifier AS "Patient Identifier", ART_Number AS "ART Number", File_Number AS "File Number", patientName AS "Patient Name", Age, Gender, location_name AS "Location", Status

FROM
        (
		SELECT distinct 
			pi1.identifier AS patientIdentifier,
			pi2.identifier AS ART_Number,
			pi3.identifier AS File_Number,
			concat(pn.given_name, ' ', pn.family_name) AS patientName,
			observed_age_group.name AS age_group,
			floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS Age,
			p.gender AS Gender,
			l.name as location_name,
			if(DATEDIFF(CAST('#endDate#' AS DATE),max(o.value_datetime)) <= 0," Active",
				if(DATEDIFF(CAST('#endDate#' AS DATE),max(o.value_datetime)) <= 28 ," Missed",
					if(DATEDIFF(CAST('#endDate#' AS DATE),max(o.value_datetime)) <= 89 ,"Defaulter","LTFU"))) as Status
							
		FROM person p
		
		INNER JOIN obs o ON o.person_id = p.person_id AND o.voided = 0 AND o.person_id in (select person_id from obs where concept_id = 2403 and voided = 0) AND o.person_id not in (select person_id from obs where concept_id = 5416 and value_coded = 1 and voided = 0)
		INNER JOIN person_name pn ON p.person_id = pn.person_id
		INNER JOIN patient_identifier pi1 ON pi1.patient_id = p.person_id AND pi1.voided = 0 and pi1.preferred = 1 AND pi1.identifier_type = 3
		LEFT JOIN patient_identifier pi2 ON pi2.patient_id = p.person_id AND pi2.identifier_type = 5
		LEFT JOIN patient_identifier pi3 ON pi3.patient_id = p.person_id AND pi3.identifier_type = 11
		JOIN location l on o.location_id = l.location_id and l.retired=0
		INNER JOIN reporting_age_group AS observed_age_group ON
			CAST('#endDate#' AS DATE) 
				BETWEEN (DATE_ADD(DATE_ADD(p.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
				AND (DATE_ADD(DATE_ADD(p.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
		WHERE observed_age_group.report_group_name = 'Modified_Ages'
		AND o.person_id not in
					(				
						select person_id from obs where concept_id = 2249
					)
		AND o.person_id 								
		AND p.voided = 0
		group by pi1.identifier
		order by Status
			
	) AS Patient_MissedAppointments
ORDER BY 2)

UNION
-- clients with ART unique numbers but no intakes
(SELECT distinct patientIdentifier AS "Patient Identifier", ART_Number AS "ART Number", File_Number AS "File Number", patientName AS "Patient Name", Age, Gender, location_name AS "Location", Status

FROM
        (
		SELECT distinct 
			patient_identifier.identifier AS patientIdentifier,
			p.identifier AS ART_Number,
			pi3.identifier AS File_Number,
			concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
			observed_age_group.name AS age_group,
			floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
			person.gender AS Gender,
			l.name as location_name,
			'No ART Form' AS Status				
		FROM obs o
			INNER JOIN patient ON o.person_id = patient.patient_id
			INNER JOIN patient_identifier p ON o.person_id = p.patient_id
			INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
			INNER JOIN person_name ON person.person_id = person_name.person_id
			INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3
			LEFT JOIN patient_identifier pi3 ON pi3.patient_id = person.person_id AND pi3.identifier_type = 11
			JOIN location l on o.location_id = l.location_id and l.retired=0
			INNER JOIN reporting_age_group AS observed_age_group ON
				CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
					AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
			WHERE observed_age_group.report_group_name = 'Modified_Ages'
			AND o.person_id not in
				(				
					select person_id from obs where concept_id in (2249,2403)
				)								
									
			AND p.identifier_type = 5
			AND o.voided = 0
			group by patient_identifier.identifier
			
		) AS Patient_MissedAppointments

ORDER BY 2);
