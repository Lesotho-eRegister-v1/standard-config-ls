SELECT DISTINCT
					reg.location_name as "Location Name"
					, reg.identifier as "Patient Identifier"
					, reg.name as "Name"
					, reg.gender as "Gender"
					, reg.age as "Age"
					, IF(cancer_screening_consultation.id is not null, 'Consulted', 'Not Consulted') AS Status
			FROM
					(
						-- Registered Cervical Cancer Screening Clients
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
								JOIN person_name pn on v.patient_id = pn.person_id and pn.voided=0 and pn.preferred = 1
								JOIN person p on p.person_id = v.patient_id
								JOIN patient_identifier pi on v.patient_id = pi.patient_id and pi.identifier_type=3 and pi.preferred=1
								JOIN patient_identifier_type pit on pi.identifier_type = pit.patient_identifier_type_id
								JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 2
								JOIN visit_type vt on v.visit_type_id=vt.visit_type_id AND vt.visit_type_id = 21
								JOIN obs o on o.encounter_id=en.encounter_id
								JOIN location l on v.location_id = l.location_id and l.retired=0
								WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)
								
								) reg
								

					LEFT JOIN 
					-- Cervical Cancer Screening Consulted Clients
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
							JOIN obs o on o.encounter_id=en.encounter_id 
							JOIN location l on v.location_id = l.location_id and l.retired=0
                            Where o.concept_id = 4511
							AND en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)
							) cancer_screening_consultation
					
					ON reg.id = cancer_screening_consultation.id)