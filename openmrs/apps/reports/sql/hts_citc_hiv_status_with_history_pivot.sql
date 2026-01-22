-- ==============================
-- Main Summary by AgeGroup and Sex
-- ==============================
SELECT
    ag.name AS AgeGroup,
    p.gender AS Sex,

    SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Positives,
    SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Negatives,
    SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'New' THEN 1 ELSE 0 END) AS New_Indeterminate,

    SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Positives,
    SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Negatives,
    SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END) AS Repeat_Indeterminate,

    SUM(CASE WHEN tr.value_coded IN (1738,1016,4220) THEN 1 ELSE 0 END) AS Total

FROM person p
JOIN patient_identifier pi 
    ON pi.patient_id = p.person_id
    AND pi.identifier_type = 3
    AND pi.preferred = 1
    AND pi.voided = 0
LEFT JOIN person_name pn
    ON pn.person_id = p.person_id
    AND pn.preferred = 1
    AND pn.voided = 0
JOIN obs tr 
    ON tr.person_id = p.person_id
    AND tr.concept_id = 2165 -- HIV Final Status
    AND tr.voided = 0
    AND CAST(tr.obs_datetime AS DATE) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)

-- ✅ Latest Testing History per patient
JOIN (
    SELECT o.person_id,
           IF(o.value_coded = 2146, 'Repeat', 'New') AS Testing_History
    FROM obs o
    INNER JOIN (
        SELECT person_id, MAX(obs_datetime) AS latest_date
        FROM obs
        WHERE concept_id = 4798
          AND voided = 0
          AND CAST(obs_datetime AS DATE) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
        GROUP BY person_id
    ) latest 
        ON latest.person_id = o.person_id 
       AND o.obs_datetime = latest.latest_date
    WHERE o.concept_id = 4798
      AND o.voided = 0
) th 
    ON th.person_id = p.person_id

-- ✅ CITC Only
JOIN (
    SELECT person_id
    FROM obs
    WHERE concept_id = 4228
      AND value_coded = 4226 -- CITC
      AND voided = 0
      AND CAST(obs_datetime AS DATE) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
    GROUP BY person_id
) pitc 
    ON pitc.person_id = p.person_id

-- ✅ Age Grouping
JOIN reporting_age_group ag
  ON CAST('#endDate#' AS DATE) BETWEEN 
        DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.min_years YEAR), INTERVAL ag.min_days DAY)
    AND DATE_ADD(DATE_ADD(p.birthdate, INTERVAL ag.max_years YEAR), INTERVAL ag.max_days DAY)
   AND ag.report_group_name = 'Modified_Ages'

WHERE p.voided = 0
GROUP BY ag.name, p.gender


UNION ALL


-- ==============================
-- Grand Total Row
-- ==============================
SELECT
    'Total' AS AgeGroup,
    'ALL' AS Sex,

    SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'New' THEN 1 ELSE 0 END),
    SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'New' THEN 1 ELSE 0 END),
    SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'New' THEN 1 ELSE 0 END),
    SUM(CASE WHEN tr.value_coded = 1738 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END),
    SUM(CASE WHEN tr.value_coded = 1016 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END),
    SUM(CASE WHEN tr.value_coded = 4220 AND th.Testing_History = 'Repeat' THEN 1 ELSE 0 END),
    SUM(CASE WHEN tr.value_coded IN (1738,1016,4220) THEN 1 ELSE 0 END)

FROM person p
JOIN patient_identifier pi 
    ON pi.patient_id = p.person_id
    AND pi.identifier_type = 3
    AND pi.preferred = 1
    AND pi.voided = 0
JOIN obs tr 
    ON tr.person_id = p.person_id
    AND tr.concept_id = 2165
    AND tr.voided = 0
    AND CAST(tr.obs_datetime AS DATE) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
JOIN (
    SELECT o.person_id,
           IF(o.value_coded = 2146, 'Repeat', 'New') AS Testing_History
    FROM obs o
    INNER JOIN (
        SELECT person_id, MAX(obs_datetime) AS latest_date
        FROM obs
        WHERE concept_id = 4798
          AND voided = 0
          AND CAST(obs_datetime AS DATE) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
        GROUP BY person_id
    ) latest 
        ON latest.person_id = o.person_id 
       AND o.obs_datetime = latest.latest_date
    WHERE o.concept_id = 4798
      AND o.voided = 0
) th 
    ON th.person_id = p.person_id

-- ✅ CITC Only
JOIN (
    SELECT person_id
    FROM obs
    WHERE concept_id = 4228
      AND value_coded = 4226 -- CITC
      AND voided = 0
      AND CAST(obs_datetime AS DATE) BETWEEN CAST('#startDate#' AS DATE) AND CAST('#endDate#' AS DATE)
    GROUP BY person_id
) pitc 
    ON pitc.person_id = p.person_id
WHERE p.voided = 0

-- ==============================
-- Custom Sort Order:
--  - "Under 1yr" always first
--  - "Total" always last
-- ==============================
ORDER BY 
    CASE 
        WHEN AgeGroup = 'Under 1yr' THEN 0
        WHEN AgeGroup = '1-4yrs' THEN 1
        WHEN AgeGroup = '5-9yrs' THEN 2
        WHEN AgeGroup = 'Total' THEN 4
        ELSE 3
    END,
    AgeGroup,
    Sex;
