SELECT DISTINCT
	   Under5_Registration_vs_Consultation_Agg.location_name AS Location,
	   SUM(1) AS 'Total Visits Registered',	   
	   SUM(IF(Under5_Registration_vs_Consultation_Agg.status = 'Consulted', 1, 0)) AS Consulted,
	   round((SUM(IF(Under5_Registration_vs_Consultation_Agg.status = 'Consulted', 1, 0))/SUM(1))*100) AS '% with Under5 Consultations',
	   round((SUM(IF(Under5_Registration_vs_Consultation_Agg.status = 'Not Consulted', 1, 0))/SUM(1))*100) AS '% without Under5 Consultations'	   
FROM
(

SELECT DISTINCT
		location_name
		, id
		, Identifier
		, Name
		, Gender
		, Age
		, Status
FROM 
(

		SELECT DISTINCT
				location_name
				, id
				, identifier as Identifier
				, name as Name
				, gender as Gender
				, age as Age
				, status as Status

		FROM
		(

			SELECT DISTINCT
					reg.location_name
					, reg.id
					, reg.name
					, reg.gender
					, reg.age
					, reg.identifier
					, IF(Under5_Consultation.id is not null, 'Consulted', 'Not Consulted') AS status
			FROM
					((SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,				
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM visit v
							JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0 and pn.preferred = 1
							JOIN person p on p.person_id = v.patient_id
							JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type=3 and pi.preferred=1
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and v.visit_type_id = 20 and en.voided=0 and en.encounter_type = 2
							JOIN obs o on o.encounter_id=en.encounter_id
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) reg

					LEFT JOIN 

					(SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM visit v
							JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0
							JOIN person p on p.person_id = v.patient_id
							JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type=3
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 1
							JOIN obs o on o.encounter_id=en.encounter_id and o.concept_id=4285
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) Under5_Consultation
					
					ON reg.id = Under5_Consultation.id)			
					
		) AS Under5RegisteredConsultations
		GROUP BY Under5RegisteredConsultations.id
		HAVING Under5RegisteredConsultations.status = 'Consulted'


		UNION 

		SELECT DISTINCT
				location_name
				, id
				, identifier as Identifier
				, name as Name
				, gender as Gender
				, age as Age
				, status as Status

		FROM
		(

			SELECT DISTINCT
					reg.location_name
					, reg.id
					, reg.name
					, reg.gender
					, reg.age
					, reg.identifier
					, IF(Under5_Consultation.id is not null, 'Consulted', 'Not Consulted') AS status
			FROM
					((SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,				
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM visit v
							JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0 and pn.preferred = 1
							JOIN person p on p.person_id = v.patient_id
							JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type = 3 and pi.preferred=1
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and v.visit_type_id = 20 and en.voided=0 and en.encounter_type = 2
							JOIN obs o on o.encounter_id=en.encounter_id
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) reg

					LEFT JOIN 

					(SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM visit v
							JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0
							JOIN person p on p.person_id = v.patient_id
							JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 1
							JOIN obs o on o.encounter_id=en.encounter_id and o.concept_id=4285
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) Under5_Consultation
					
					ON reg.id = Under5_Consultation.id)			
					
		) AS Under5RegisteredConsultations
		WHERE Under5RegisteredConsultations.id not in (
								select distinct os.person_id 
								from obs os 
								where os.concept_id=4285 
								and os.obs_datetime >= CAST('#startDate#' AS DATE) and os.obs_datetime <= CAST('#endDate#' AS DATE)
		)
		GROUP BY Under5RegisteredConsultations.id

) AS RegisteredvsConsultations
ORDER BY  RegisteredvsConsultations.id, RegisteredvsConsultations.location_name, RegisteredvsConsultations.status




) AS Under5_Registration_vs_Consultation_Agg
GROUP BY Under5_Registration_vs_Consultation_Agg.location_name


UNION ALL


SELECT DISTINCT
	   'Total' AS Location,
	   SUM(1) AS 'Total Visits Registered',	   
	   SUM(IF(Under5_Registration_vs_Consultation_Agg.status = 'Consulted', 1, 0)) AS Consulted,
	   round((SUM(IF(Under5_Registration_vs_Consultation_Agg.status = 'Consulted', 1, 0))/SUM(1))*100) AS '% with Under5 Consultations',
	   round((SUM(IF(Under5_Registration_vs_Consultation_Agg.status = 'Not Consulted', 1, 0))/SUM(1))*100) AS '% without Under5 Consultations'
FROM
(


SELECT DISTINCT
		location_name
		, id
		, Identifier
		, Name
		, Gender
		, Age
		, Status
FROM 
(

		SELECT DISTINCT
				location_name
				, id
				, identifier as Identifier
				, name as Name
				, gender as Gender
				, age as Age
				, status as Status

		FROM
		(

			SELECT DISTINCT
					reg.location_name
					, reg.id
					, reg.name
					, reg.gender
					, reg.age
					, reg.identifier
					, IF(Under5_Consultation.id is not null, 'Consulted', 'Not Consulted') AS status
			FROM
					((SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,				
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM visit v
							JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0 and pn.preferred = 1
							JOIN person p on p.person_id = v.patient_id
							JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type = 3 and pi.preferred=1
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and v.visit_type_id = 20 and en.voided=0 and en.encounter_type = 2
							JOIN obs o on o.encounter_id=en.encounter_id
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) reg

					LEFT JOIN 

					(SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM visit v
							JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0
							JOIN person p on p.person_id = v.patient_id
							JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type=3
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 1
							JOIN obs o on o.encounter_id=en.encounter_id and o.concept_id=4285
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) Under5_Consultation
					
					ON reg.id = Under5_Consultation.id)			
					
		) AS Under5RegisteredConsultations
		GROUP BY Under5RegisteredConsultations.id
		HAVING Under5RegisteredConsultations.status = 'Consulted'


		UNION 

		SELECT DISTINCT
				location_name
				, id
				, identifier as Identifier
				, name as Name
				, gender as Gender
				, age as Age
				, status as Status

		FROM
		(

			SELECT DISTINCT
					reg.location_name
					, reg.id
					, reg.name
					, reg.gender
					, reg.age
					, reg.identifier
					, IF(Under5_Consultation.id is not null, 'Consulted', 'Not Consulted') AS status
			FROM
					((SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,				
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM visit v
							JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0 and pn.preferred = 1
							JOIN person p on p.person_id = v.patient_id
							JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type = 3 and pi.preferred=1
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and v.visit_type_id = 20 and en.voided=0 and en.encounter_type = 2
							JOIN obs o on o.encounter_id=en.encounter_id
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) reg

					LEFT JOIN 

					(SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM visit v
							JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0
							JOIN person p on p.person_id = v.patient_id
							JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type=3
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and v.visit_type_id = 20 and en.voided=0 and en.encounter_type = 1
							JOIN obs o on o.encounter_id=en.encounter_id and o.concept_id=4285
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) Under5_Consultation
					
					ON reg.id = Under5_Consultation.id)
					
		) AS Under5RegisteredConsultations
		WHERE Under5RegisteredConsultations.id not in (
								select distinct os.person_id 
								from obs os 
								where os.concept_id=4285
								and os.obs_datetime >= CAST('#startDate#' AS DATE) and os.obs_datetime <= CAST('#endDate#' AS DATE)
		)
		GROUP BY Under5RegisteredConsultations.id

) AS RegisteredvsConsultations
ORDER BY  RegisteredvsConsultations.id, RegisteredvsConsultations.location_name, RegisteredvsConsultations.status


) AS Under5_Registration_vs_Consultation_Agg
