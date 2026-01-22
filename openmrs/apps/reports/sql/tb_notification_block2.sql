select age_group, 
	IF(Id is null, 0,SUM(IF(TB_Treatment_History = 'New Patient',1,0))) AS "New Patient",
	IF(Id is null, 0,SUM(IF(TB_Treatment_History = 'Relapsed Patient',1,0))) AS "Relapsed Patient",
	IF(Id is null, 0,SUM(IF(TB_Treatment_History = 'Treatment after loss to follow up',1,0))) AS "Treatment after loss to follow up",
    IF(Id is null, 0,SUM(IF(TB_Treatment_History = 'Treatment after failure',1,0))) AS "Treatment after failure"

from(
    SELECT distinct Id, Patient_Identifier, Patient_Name, Age , Gender, age_group, TB_Treatment_History
FROM
(
    (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age , Gender, age_group, 'New Patient' AS 'TB_Treatment_History'
        FROM
                        
            (select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group,
                observed_age_group.sort_order AS sort_order

            from obs o
            -- New TB Patient
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE)
                            and ob.voided = 0
                        )
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            where ob.person_id in (
                                        -- New Clients
                                            select distinct person_id
                                                from obs
                                                where concept_id = 3785 and value_coded = 1034
                                                and obs_datetime >= CAST('#startDate#'AS DATE)
                                                and obs_datetime <= CAST('#endDate#'AS DATE)
                                            )
                        )

                    
                    AND o.person_id not in (
                        select distinct os.person_id 
                            from obs os
                                -- Patient must not be a tranfer in	
                            where os.concept_id = 	3772 and os.value_coded =2095
                        AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                        AND patient.voided = 0 AND os.voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS NEW_TB_CLIENTS
        ORDER BY NEW_TB_CLIENTS.Age)


    UNION

        (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age , Gender, age_group, 'Relapsed Patient' AS 'TB_Treatment_History'
            FROM
                (select distinct patient.patient_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group,
                    observed_age_group.sort_order AS sort_order

                from obs o
            -- Relapsed TB Client
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE) 
                        )
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            where ob.person_id in (
                                        -- Relapsed Clients
                                            select distinct person_id
                                                from obs
                                                where concept_id = 3785 and value_coded = 1084
                                                and ob.value_datetime >= CAST('#startDate#'AS DATE)
                                                and ob.value_datetime <= CAST('#endDate#'AS DATE)
                                            )
                        )



                    AND o.person_id not in (
                        select distinct os.person_id 
                        from obs os
                            -- Client must not be a transfer in
                        where os.concept_id = 3772 and os.value_coded =2095
                        AND os.obs_datetime >= CAST('#startDate#' AS DATE)
                        and os.obs_datetime <= CAST('#endDate#'AS DATE)
                        AND patient.voided = 0 AND os.voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS RELAPSE_TB_CLIENTS
    ORDER BY RELAPSE_TB_CLIENTS.Age)

    UNION


    (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age , Gender, age_group, 'Treatment after loss to follow up' AS 'TB_Treatment_History'
            FROM
                (select distinct patient.patient_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group,
                    observed_age_group.sort_order AS sort_order

                from obs o
            -- Relapsed TB Client
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE) 
                        )
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            where ob.person_id in (
                                        -- Treatment after loss to follow up
                                            select distinct person_id
                                                from obs
                                                where concept_id = 3785 and value_coded = 3786
                                                and ob.value_datetime >= CAST('#startDate#'AS DATE)
                                                and ob.value_datetime <= CAST('#endDate#'AS DATE)
                                            )
                        )



                    AND o.person_id not in (
                        select distinct os.person_id 
                        from obs os
                            -- Client must not be a transfer in
                        where os.concept_id = 3772 and os.value_coded = 3786
                        AND os.obs_datetime >= CAST('#startDate#' AS DATE)
                        and os.obs_datetime <= CAST('#endDate#'AS DATE)
                        AND patient.voided = 0 AND os.voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TREATMENT_AFTER_LTFU
    ORDER BY TREATMENT_AFTER_LTFU.Age)

    UNION


    (SELECT distinct Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age , Gender, age_group, 'Treatment after failure' AS 'TB_Treatment_History'
            FROM
                (select distinct patient.patient_id AS Id,
                    patient_identifier.identifier AS patientIdentifier,
                    concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                    floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                    person.gender AS Gender,
                    observed_age_group.name AS age_group,
                    observed_age_group.sort_order AS sort_order

                from obs o
                    -- TB Treatment start date
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE) 
                        )
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            where ob.person_id in (
                                        -- Treatment after failure 
                                            select distinct person_id
                                                from obs
                                                where concept_id = 3785 and value_coded = 1037
                                                and ob.value_datetime >= CAST('#startDate#'AS DATE)
                                                and ob.value_datetime <= CAST('#endDate#'AS DATE)
                                            )
                        )



                    AND o.person_id not in (
                        select distinct os.person_id 
                        from obs os
                            -- Client must not be a transfer in
                        where os.concept_id = 3772 and os.value_coded = 1037
                        AND os.obs_datetime >= CAST('#startDate#' AS DATE)
                        and os.obs_datetime <= CAST('#endDate#'AS DATE)
                        -- AND (os.obs_datetime BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE))
                        AND patient.voided = 0 AND os.voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TREATMENT_AFTER_FAILURE
    ORDER BY TREATMENT_AFTER_FAILURE.Age)

) AS TB_HISTORY

) pivotTable
group by age_group