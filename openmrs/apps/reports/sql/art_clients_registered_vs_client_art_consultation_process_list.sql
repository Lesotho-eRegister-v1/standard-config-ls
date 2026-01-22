
(SELECT DISTINCT
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
					, IF(art_consultation.id is not null, 'Consulted', 'Not Consulted') AS status
			FROM
					((SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,				
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							-- concept_id,
							l.name as location_name,
							v.visit_type_id,
							v.date_started,
							v.voided
					FROM visit v
							INNER JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0
							INNER JOIN person p on p.person_id = v.patient_id
							LEFT JOIN patient_identifier pi ON v.patient_id = pi.patient_id 
							iNNER JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							INNER JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 2
							INNER JOIN obs o on o.encounter_id=en.encounter_id
							iNNER JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE v.date_started >= CAST('#startDate#' AS DATE) and v.date_started <= CAST('#endDate#' AS DATE)
					and v.visit_type_id in (10,19)
					and v.voided = 0
) reg

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
							LEFT JOIN patient_identifier pi ON v.patient_id = pi.patient_id 
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 1
							JOIN visit_type vt on vt.visit_type_id = vt.visit_type_id and vt.visit_type_id in (10,19)
							JOIN obs o on o.encounter_id=en.encounter_id and o.concept_id in (3843, 4276)
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) art_consultation
					
					ON reg.id = art_consultation.id)			
					
		) AS ARTConsultationsRegistered
		GROUP BY ARTConsultationsRegistered.id
		HAVING ARTConsultationsRegistered.status = 'Consulted'


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
					, IF(art_consultation.id is not null, 'Consulted', 'Not Consulted') AS status
			FROM
					((SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,				
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							-- concept_id,
							l.name as location_name,
							v.visit_type_id,
							v.date_started,
							v.voided
					FROM visit v
							INNER JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0
							INNER JOIN person p on p.person_id = v.patient_id
							LEFT JOIN patient_identifier pi ON v.patient_id = pi.patient_id 
							iNNER JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id 
							INNER JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 2
							INNER JOIN obs o on o.encounter_id=en.encounter_id
							iNNER JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE v.date_started >= CAST('#startDate#' AS DATE) and v.date_started <= CAST('#endDate#' AS DATE)
					and v.visit_type_id in (10,19)
					and v.voided = 0
) reg

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
							LEFT JOIN patient_identifier pi ON v.patient_id = pi.patient_id 
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id 
							JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 1
							JOIN visit_type vt on vt.visit_type_id = vt.visit_type_id and vt.visit_type_id in (10,19)
							JOIN obs o on o.encounter_id=en.encounter_id and o.concept_id in (3843, 4276) and o.voided =0
							JOIN location l on v.location_id = l.location_id and l.retired=0
					WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)) art_consultation
					
					ON reg.id = art_consultation.id)			
					
		) AS ARTConsultationsRegistered
		WHERE ARTConsultationsRegistered.id not in (
								select distinct os.person_id 
								from obs os 
								where os.concept_id=3843 
								AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
								AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
		)
		GROUP BY ARTConsultationsRegistered.id

) AS RegistrationVsIntakes) 





UNION


(SELECT DISTINCT
				location_name
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
					, 'Consulted' AS status
			FROM
					(SELECT DISTINCT
							p.person_id as id,
							concat(pn.given_name,' ', ifnull(pn.family_name,'')) as name,
							p.gender AS gender,				
							floor(datediff(CAST('#endDate#' AS DATE), p.birthdate)/365) AS age,				
							pi.identifier as identifier,
							concat("",p.uuid) as uuid,
							concept_id,
							l.name as location_name
					FROM obs o
							INNER JOIN patient ON o.person_id = patient.patient_id
							JOIN person p on p.person_id = patient.patient_id AND p.voided = 0
							INNER JOIN person_name pn ON p.person_id = pn.person_id AND pn.preferred = 1
							LEFT JOIN patient_identifier pi ON patient.patient_id = pi.patient_id AND pi.identifier_type in (5,12)
							JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
							JOIN location l on o.location_id = l.location_id and l.retired=0
							AND o.concept_id in (3843, 4276) and o.voided =0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							GROUP BY id) reg) ARTConsultationsRegistered)
