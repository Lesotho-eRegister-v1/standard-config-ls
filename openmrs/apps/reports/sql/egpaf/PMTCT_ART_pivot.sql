SELECT distinct PMTCT_ART_COLS_ROWS.AgeGroup
		    , PMTCT_ART_COLS_ROWS.Already_on_ART
	    	, PMTCT_ART_COLS_ROWS.Initiated_in_Pregnancy

FROM (

			(SELECT PMTCT_ART_ROWS.age_group AS 'AgeGroup'
				, IF(PMTCT_ART_ROWS.Id IS NULL, 0, SUM(IF(PMTCT_ART_ROWS.ART_Status = 'Already on ART', 1, 0))) AS Already_on_ART
				, IF(PMTCT_ART_ROWS.Id IS NULL, 0, SUM(IF(PMTCT_ART_ROWS.ART_Status = 'Initiated on ART in pregnancy', 1, 0))) AS Initiated_in_Pregnancy
				, PMTCT_ART_ROWS.sort_order
			FROM (

					
(SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, ART_Status, sort_order
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
)
) AS PMTCT_ART_ROWS

GROUP BY PMTCT_ART_ROWS.age_group, PMTCT_ART_ROWS.Gender
ORDER BY PMTCT_ART_ROWS.sort_order
)

			
UNION ALL

(SELECT 'Total' AS 'AgeGroup'
	, IF(PMTCT_ART_DRVD_COLS.Id IS NULL, 0, SUM(IF(PMTCT_ART_DRVD_COLS.ART_Status = 'Already on ART', 1, 0))) AS Already_on_ART
	, IF(PMTCT_ART_DRVD_COLS.Id IS NULL, 0, SUM(IF(PMTCT_ART_DRVD_COLS.ART_Status = 'Initiated on ART in pregnancy', 1, 0))) AS Initiated_in_Pregnancy
	, 99 AS sort_order
FROM (

					
(SELECT Id, patientIdentifier, patientName, Age, Gender, age_group, ART_Status, sort_order
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
on pregnant_on_ART.Id = first_ANC.person_id)

) AS PMTCT_ART_DRVD_COLS
	)
		
	) AS PMTCT_ART_COLS_ROWS
ORDER BY PMTCT_ART_COLS_ROWS.sort_order

