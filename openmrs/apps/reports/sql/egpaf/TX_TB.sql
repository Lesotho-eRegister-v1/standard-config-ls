(SELECT distinct patientIdentifier AS "Patient_Identifier", TB_Number, patientName AS "Patient_Name", Age , Gender
        FROM
                        
            (select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                pi2.identifier AS TB_Number,
                concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group,
                observed_age_group.sort_order AS sort_order

            from obs o
            -- ART Patient
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Start Date
                            where ob.concept_id = 2237
                            and ob.value_datetime >= CAST('#startDate#'AS DATE)
                            and ob.value_datetime <= CAST('#endDate#'AS DATE) 
                            and voided = 0
                        )
                        AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- ART Patient
                            where ob.concept_id = 3843 and ob.value_coded in (3841,3842)
                            and voided = 0
                        )
                        AND o.person_id in 
                        (
                            select distinct ob.person_id 
                            from obs ob
                            -- TB Screened
                            where ob.concept_id = 3710 and ob.value_coded in (3709,1876,3639,5849)
                            AND ob.obs_datetime >= CAST('#startDate#' AS DATE)
                            and ob.obs_datetime <= CAST('#endDate#'AS DATE) 
                            and voided = 0
                        )
                    
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type in (7)
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TX_TB
        ORDER BY TX_TB.Age)
