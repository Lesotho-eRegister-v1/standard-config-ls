SELECT patientIdentifier as "Patient Identifier" , patientName as "Patient Name" , Age, Gender, age_group as "Age Group", ART_Status
FROM (

select distinct patient.patient_id AS Id,
                                   patient_identifier.identifier AS patientIdentifier,
                                   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
                                   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                                   person.gender AS Gender,
                                   observed_age_group.name AS age_group,
                                   observed_age_group.sort_order AS sort_order
        from obs o
                                                                -- Pregnant on ART
                                 INNER JOIN patient ON o.person_id = patient.patient_id
                                 AND o.person_id in(
                                        select person_id
                                        from
                                        (
                                        (select o.person_id
                                                from obs o
                                                inner join
                                                (select person_id, max(obs_datetime)as max_observation, SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
                                                                from obs where concept_id = 4338 -- HIV Prophylaxis/Treatment in ANC
                                                                and cast(obs_datetime as date) >= cast('#startDate#' as date)
                                                                and cast(obs_datetime as date) <= cast('#endDate#' as date)
                                                                and voided = 0
                                                                --
                                                                group by person_id) as hiv_status
                                                on hiv_status.person_id = o.person_id
                                                where o.concept_id = 4343 and o.value_coded in (4341,4342) -- Already on ART or initiated during pregnancy
                                                and cast(o.obs_datetime as date) >= cast('#startDate#' as date)
                                                and cast(o.obs_datetime as date) <= cast('#endDate#' as date)
                                        )

                                        )On_ART

                                        )
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#'AS DATE)
								 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
                                 AND patient.voided = 0 AND o.voided = 0
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                                 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
                                 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                                 INNER JOIN reporting_age_group AS observed_age_group ON
                                 CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                                 AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                                 WHERE observed_age_group.report_group_name = 'Modified_Ages'

) AS pregnant_on_ART

inner join

(
        select distinct os.person_id, os.obs_id,
        case
       -- ART Status
           when os.value_coded = 4341 then "Already on ART"
           when os.value_coded = 4342 then "Initiated on ART in pregnancy"
           else ""
       end AS ART_Status
       from obs os 
       where os.concept_id = 4343
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	   group by person_id
)ART_Status
on pregnant_on_ART.Id = ART_Status.person_id

inner join

(
        select distinct os.person_id
       -- First ANC
       from obs os 
       where os.concept_id = 4658 and os.value_coded = 4659 -- 1st ANC
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
	   group by person_id
)first_ANC
on pregnant_on_ART.Id = first_ANC.person_id



