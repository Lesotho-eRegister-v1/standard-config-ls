SELECT distinct Patient_Identifier, Patient_Name, Age, TB_diagnosis, TB_Start, HIV_Status, HIV_Initiated
FROM 

 (

	SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age AS 'Age', 'Line_Probe_Assay' AS 'TB_diagnosis'

		FROM
			(
				SELECT distinct patient.patient_id AS Id,
								p.identifier AS patientIdentifier,
								concat(pn.given_name, ' ', pn.family_name) AS patientName,
								floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age
								
								
				FROM obs o

										INNER JOIN patient ON o.person_id = patient.patient_id
										INNER JOIN patient_identifier p ON o.person_id = p.patient_id AND p.identifier_type = 3 AND p.preferred=1
										INNER JOIN person_name pn ON p.patient_id = pn.person_id
										INNER JOIN person ps on ps.person_id = p.patient_id
										AND o.person_id in
										(				
											select distinct person_id from obs o
											where concept_id = 3805 and value_coded = 1016
                                            AND voided = 0
											AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

									
										) 								
										AND o.voided = 0
													
			) AS Line_Probe_Assay

    UNION

   SELECT distinct Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age AS 'Age', 'Phenotypic_Test' AS 'TB_diagnosis'

	FROM
			(
				SELECT distinct patient.patient_id AS Id,
								p.identifier AS patientIdentifier,
								concat(pn.given_name, ' ', pn.family_name) AS patientName,
								floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age
								
								
				FROM obs o


										INNER JOIN patient ON o.person_id = patient.patient_id
										INNER JOIN patient_identifier p ON o.person_id = p.patient_id AND p.identifier_type = 3 AND p.preferred=1
										INNER JOIN person_name pn ON p.patient_id = pn.person_id
										INNER JOIN person ps on ps.person_id = p.patient_id
										AND o.person_id in
										(				
											select distinct person_id from obs o
											where concept_id = 3815 
                                            AND voided = 0
											AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
											

									
										) 								
										AND o.voided = 0
													
			) AS Phenotypic_Test

UNION

SELECT distinct Id, patientIdentifier AS "Patient Identifier", patientName AS "Patient Name", Age AS 'Age', 'Xray_diagnosis' AS 'TB_diagnosis'

	FROM
			(
				SELECT distinct patient.patient_id AS Id,
								p.identifier AS patientIdentifier,
								concat(pn.given_name, ' ', pn.family_name) AS patientName,
								floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age
								
								
				FROM obs o
				
										INNER JOIN patient ON o.person_id = patient.patient_id	
										INNER JOIN patient_identifier p ON o.person_id = p.patient_id AND p.identifier_type = 3 AND p.preferred=1
										INNER JOIN person_name pn ON p.patient_id = pn.person_id
										INNER JOIN person ps on ps.person_id = p.patient_id
										AND o.person_id in
										(				
											select distinct person_id from obs o
											where concept_id = 4673 and value_coded = 4171
                                            AND voided =0
											AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

									
										) 								
										AND o.voided = 0
													
			) AS Xray_diagnosis


UNION

SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age AS 'Age', 'GeneXpert' AS 'TB_diagnosis'

	FROM
			(
				SELECT distinct patient.patient_id AS Id,
								p.identifier AS patientIdentifier,
								concat(pn.given_name, ' ', pn.family_name) AS patientName,
								floor(datediff(CAST('#endDate#' AS DATE), ps.birthdate)/365) AS Age
								
								
				FROM obs o

										INNER JOIN patient ON o.person_id = patient.patient_id
										INNER JOIN patient_identifier p ON o.person_id = p.patient_id AND p.identifier_type = 3 AND p.preferred=1
										INNER JOIN person_name pn ON p.patient_id = pn.person_id
										INNER JOIN person ps on ps.person_id = p.patient_id
										AND o.person_id in
										(				
											select distinct person_id from obs o
											where concept_id = 3787 and value_coded in (3816,3817,3818)
                                            AND voided = 0
											AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
											AND YEAR(o.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))

									
										) 								
										AND o.voided = 0
													
			) AS GeneXpert

	
) AS TB_diagnosis

-- TB START	
left outer join
	(
	select person_id,CAST(value_datetime AS DATE) as TB_Start
	from obs where concept_id = 2237 and voided = 0
	)tb_start_date

on tb_start_date.person_id = TB_diagnosis.Id


-- HIV STATUS	
left outer join
	(
	select person_id, value_coded as Status_Code
	from obs where concept_id = 4666 and voided = 0
	)Status

	inner join
	(
		select concept_id, name AS HIV_Status
			from concept_name 
				where name in ('Known Positive', 'Known Negative', 'New Positive', 'New Negative') 
	) concept_name
	on concept_name.concept_id = Status.Status_Code 

on Status.person_id = TB_diagnosis.Id 

-- ART START	
left outer join
	(
		SELECT person_id, value_datetime, 'Started_ART_This_Month' AS 'HIV_Initiated'
			FROM obs 
			WHERE concept_id = 2249 
			AND MONTH(value_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
			AND YEAR(value_datetime) = YEAR(CAST('#endDate#' AS DATE))
			AND voided = 0

			AND person_id not in (
						select distinct os.person_id from obs os
							where os.concept_id = 3634 
							AND os.value_coded = 2095 
							AND MONTH(os.obs_datetime) = MONTH(CAST('#endDate#' AS DATE)) 
							AND YEAR(os.obs_datetime) = YEAR(CAST('#endDate#' AS DATE))
						 )	



	) ART_started
on ART_started.person_id = TB_diagnosis.Id 


