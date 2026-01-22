Select Patient_Identifier, ART_Number, Patient_Name, Age, Gender, TPT_Start_Date
From
(SELECT distinct Id,patientIdentifier AS "Patient_Identifier", ART_Number, patientName AS "Patient_Name", Age , Gender
        FROM
                        
            (select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                pi2.identifier AS ART_Number,
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
                            where ob.concept_id = 3843 and ob.value_coded in (3841,3842)
                            and DATEDIFF(CAST('#startDate#' AS DATE),ob.obs_datetime) >= 180
                            and DATEDIFF(CAST('#startDate#' AS DATE),ob.obs_datetime) <= 360
                            and ob.voided = 0
                        )
                        AND o.person_id in 
                        (
                            select distinct ob.person_id
                            from obs ob
                            -- TPT Clients
                            where ob.concept_id = 2227 and ob.value_coded = 2146
                            and DATEDIFF(CAST('#startDate#' AS DATE),ob.obs_datetime) >= 180
                            and DATEDIFF(CAST('#startDate#' AS DATE),ob.obs_datetime) <= 360
                            and ob.voided = 0
                        )

                        AND o.person_id in 
                        (
                            select distinct ob.person_id
                            from obs ob
                            -- TPT Completed on this period
                            where ob.concept_id = 2227 and ob.value_coded = 2928
                            AND ob.obs_datetime >= CAST('#startDate#' AS DATE)
                            and ob.obs_datetime <= CAST('#endDate#'AS DATE)
                            and ob.voided = 0
                        )
                        -- AND o.person_id in (
                        --     select distinct o.person_id
                        --     from obs o 
                        --     where o.concept_id = 5401
                        --     and DATEDIFF(CAST('#startDate#' AS DATE),o.obs_datetime) >= 180
                        --     and DATEDIFF(CAST('#startDate#' AS DATE),o.obs_datetime) <= 360
                        -- )
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    LEFT JOIN patient_identifier pi2 ON pi2.patient_id = person.person_id AND pi2.identifier_type in (5,12)
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                WHERE observed_age_group.report_group_name = 'Modified_Ages') AS TPT_Clients
        ORDER BY TPT_Clients.Age) as tpt_clients
		-- DISTRIBUTION DATE
left outer join
	(select o.person_id,CAST(latest_tpt_date AS DATE) as TPT_Start_Date
	from obs o 
	inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as latest_tpt_date
     from obs oss
     where oss.concept_id = 5401 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest 
  on latest.person_id = o.person_id
  where concept_id = 5401
  and  o.obs_datetime = max_observation 
  ) as tpt_startDate
	on tpt_clients.Id = tpt_startDate.person_id

