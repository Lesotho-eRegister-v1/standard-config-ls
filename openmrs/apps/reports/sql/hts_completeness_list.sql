SELECT DISTINCT
					reg.location_name
					, reg.name
					, reg.gender
					, reg.age
					, reg.identifier
					, IF(hts_consultation.id is not null, 'Consulted', 'Not Consulted') AS status
			FROM
					(
						-- REGISTERED HTS CLIENTS
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
								JOIN encounter en on en.visit_id = v.visit_id and en.voided=0 and en.encounter_type = 2
								JOIN visit_type vt on v.visit_type_id=vt.visit_type_id AND vt.visit_type_id = 15
								JOIN obs o on o.encounter_id=en.encounter_id
								JOIN location l on v.location_id = l.location_id and l.retired=0
								WHERE en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)
								
								) reg
								

					LEFT JOIN 
					-- CONSULTED CLIENTS
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
                            Where o.concept_id in (2386, 4269)
							AND en.encounter_datetime >= CAST('#startDate#' AS DATE) and en.encounter_datetime <= CAST('#endDate#' AS DATE)
							) hts_consultation
					
					ON reg.id = hts_consultation.id)