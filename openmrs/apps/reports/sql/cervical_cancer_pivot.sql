SELECT Total_Aggregated_TB_ART.AgeGroup
		, Total_Aggregated_TB_ART.New_Screening
		, Total_Aggregated_TB_ART.Repeat_Screening
		, Total_Aggregated_TB_ART.Cervical_VIA_Test
		, Total_Aggregated_TB_ART.Pap_Smear
		, Total_Aggregated_TB_ART.Both_VIA_Pap_Smear
		, Total_Aggregated_TB_ART.VIA_Positive
		, Total_Aggregated_TB_ART.VIA_Negative
		, Total_Aggregated_TB_ART.VIA_Positive_Suspected_Cancer
		, Total_Aggregated_TB_ART.Normal
		, Total_Aggregated_TB_ART.LSIL
		, Total_Aggregated_TB_ART.HSIL
		, Total_Aggregated_TB_ART.ASCUS
		, Total_Aggregated_TB_ART.ASCUS_H_AGC_AGUS
		, Total_Aggregated_TB_ART.Malignant_Cells_AIS
		, Total_Aggregated_TB_ART.Total

FROM

(
	(SELECT TB_ART_DETAILS.age_group AS 'AgeGroup'
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.Screening_Status = 'New' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS New_Screening
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.Screening_Status = 'Repeat' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS Repeat_Screening
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.Screening_Type = 'Cervical VIA Test' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS Cervical_VIA_Test
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.Screening_Type = 'Pap Smear' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS Pap_Smear
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.Screening_Type = 'Both VIA&Pap Smear' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS Both_VIA_Pap_Smear
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.VIA_Result = 'VIA +ve' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS VIA_Positive
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.VIA_Result = 'VIA -ve' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS VIA_Negative
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.VIA_Result = 'VIA +ve Suspected Cancer' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS VIA_Positive_Suspected_Cancer
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.PapSmear_Result = 'Normal' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS Normal
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.PapSmear_Result = 'LSIL' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS LSIL
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.PapSmear_Result = 'HSIL' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS HSIL
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.PapSmear_Result = 'ASCUS' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS ASCUS
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.PapSmear_Result = 'ASCUS - H AGC AGUS' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS ASCUS_H_AGC_AGUS
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(IF(TB_ART_DETAILS.PapSmear_Result = 'Malignant Cells AIS' AND TB_ART_DETAILS.Gender = 'F', 1, 0))) AS Malignant_Cells_AIS
			, IF(TB_ART_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, TB_ART_DETAILS.sort_order
			
	FROM

	(
			
(SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", age_group,DOB, Gender, Screening_Status, Screening_Type, VIA_Result, PapSmear_Result, sort_order
    FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order
									  

                from obs o
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0					 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 -- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						 -- LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Cervical_Cancer_Screened

inner join 
(
        select os.person_id,
       case
       -- Screening Type
           when os.value_coded = 4757 then "Cervical VIA Test"
           when os.value_coded = 4525 then "Pap Smear"
           when os.value_coded = 4526 then "Both VIA&Pap Smear"
           else ""
       end AS Screening_Type
       from obs os 
       where os.concept_id = 4527
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)screening_type
on screening_type.person_id = Cervical_Cancer_Screened.Id

left outer join 

(
        select os.person_id,
       -- Results of VIA Test
       case
           when os.value_coded = 328 then "VIA +ve"
           when os.value_coded = 329 then "VIA -ve"
           when os.value_coded = 4793 then "VIA +ve Suspected Cancer"
           else ""
       end AS VIA_Result
       from obs os 
       where os.concept_id = 327
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)via_result
on via_result.person_id = Cervical_Cancer_Screened.Id

left outer join 

(select
       o.person_id,
       case
           when o.value_coded = 2147 then "New"
		   when o.value_coded = 2146 then "Repeat"
           else ""
       end AS Screening_Status
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4513 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4513
	and  o.obs_datetime = max_observation

)Screening
on Screening.person_id = Cervical_Cancer_Screened.Id

left outer join 

(
        select os.person_id,
       -- Results of Pap Smear Test
       case
           when os.value_coded = 324 then "Normal"
           when os.value_coded = 4748 then "LSIL"
           when os.value_coded = 4529 then "HSIL"
           when os.value_coded = 4530 then "ASCUS"
           when os.value_coded = 4531 then "ASCUS - H AGC AGUS"
           when os.value_coded = 550 then "Malignant Cells AIS"
           else ""
       end AS PapSmear_Result
       from obs os 
       where os.concept_id = 4532
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)pap_smear_result
on pap_smear_result.person_id = Cervical_Cancer_Screened.Id

ORDER BY Cervical_Cancer_Screened.Age)





	) AS TB_ART_DETAILS

	GROUP BY TB_ART_DETAILS.age_group
	ORDER BY TB_ART_DETAILS.sort_order)

UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Screening_Status = 'New', 1, 0))) AS 'New_Screening'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Screening_Status = 'Repeat', 1, 0))) AS 'Repeat_Screening'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Screening_Type = 'Cervical VIA Test', 1, 0))) AS 'Cervical_VIA_Test'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Screening_Type = 'Pap Smear', 1, 0))) AS 'Pap_Smear'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Screening_Type = 'Both VIA&Pap Smear', 1, 0))) AS 'Both_VIA_Pap_Smear'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.VIA_Result = 'VIA +ve', 1, 0))) AS 'VIA_Positive'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.VIA_Result = 'VIA -ve', 1, 0))) AS 'VIA_Negative'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.VIA_Result = 'VIA +ve Suspected Cancer', 1, 0))) AS 'VIA_Positive_Suspected_Cancer'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.PapSmear_Result = 'Normal', 1, 0))) AS 'Normal'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.PapSmear_Result = 'LSIL', 1, 0))) AS 'LSIL'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.PapSmear_Result = 'HSIL', 1, 0))) AS 'HSIL'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.PapSmear_Result = 'ASCUS', 1, 0))) AS 'ASCUS'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.PapSmear_Result = 'ASCUS - H AGC AGUS', 1, 0))) AS 'ASCUS_H_AGC_AGUS'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.PapSmear_Result = 'Malignant Cells AIS', 1, 0))) AS 'Malignant_Cells_AIS'
		, IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_TB_ART.Id
					, Total_TB_ART.patientIdentifier AS "Patient Identifier"
					, Total_TB_ART.patientName AS "Patient Name"
					, Total_TB_ART.Age
					, Total_TB_ART.Gender
					, Total_TB_ART.Screening_Status
					, Total_TB_ART.Screening_Type
					, Total_TB_ART.VIA_Result
					, Total_TB_ART.PapSmear_Result
		FROM

		(
			SELECT Id, patientIdentifier, patientName, age_group,Age, Gender, Screening_Status, Screening_Type, VIA_Result, PapSmear_Result, sort_order
    FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   person.birthdate as DOB,
									   person.gender AS Gender,
									   observed_age_group.name AS age_group,
									   observed_age_group.sort_order AS sort_order
									  

                from obs o
						  INNER JOIN patient ON o.person_id = patient.patient_id 
						  AND patient.voided = 0 AND o.voided = 0					 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						 -- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
						 -- LEFT OUTER JOIN patient_identifier pi ON pi.patient_id = person.person_id AND pi.identifier_type = 11
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') AS Cervical_Cancer_Screened

inner join 
(
        select os.person_id,
       case
       -- Screening Type
           when os.value_coded = 4757 then "Cervical VIA Test"
           when os.value_coded = 4525 then "Pap Smear"
           when os.value_coded = 4526 then "Both VIA&Pap Smear"
           else ""
       end AS Screening_Type
       from obs os 
       where os.concept_id = 4527
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)screening_type
on screening_type.person_id = Cervical_Cancer_Screened.Id

left outer join 

(
        select os.person_id,
       -- Results of VIA Test
       case
           when os.value_coded = 328 then "VIA +ve"
           when os.value_coded = 329 then "VIA -ve"
           when os.value_coded = 4793 then "VIA +ve Suspected Cancer"
           else ""
       end AS VIA_Result
       from obs os 
       where os.concept_id = 327
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)via_result
on via_result.person_id = Cervical_Cancer_Screened.Id

left outer join 

(select
       o.person_id,
       case
           when o.value_coded = 2147 then "New"
		   when o.value_coded = 2146 then "Repeat"
           else ""
       end AS Screening_Status
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.obs_id)), 20) as observation_id
		 from obs oss
		 where oss.concept_id = 4513 and oss.voided=0
		 and cast(oss.obs_datetime as date) <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4513
	and  o.obs_datetime = max_observation

)Screening
on Screening.person_id = Cervical_Cancer_Screened.Id

left outer join 

(
        select os.person_id,
       -- Results of Pap Smear Test
       case
           when os.value_coded = 324 then "Normal"
           when os.value_coded = 4748 then "LSIL"
           when os.value_coded = 4529 then "HSIL"
           when os.value_coded = 4530 then "ASCUS"
           when os.value_coded = 4531 then "ASCUS - H AGC AGUS"
           when os.value_coded = 550 then "Malignant Cells AIS"
           else ""
       end AS PapSmear_Result
       from obs os 
       where os.concept_id = 4532
       and os.voided = 0
       AND CAST(os.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
       AND CAST(os.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)

)pap_smear_result
on pap_smear_result.person_id = Cervical_Cancer_Screened.Id

ORDER BY Cervical_Cancer_Screened.Age

		) AS Total_TB_ART
  ) AS Totals
 )
) AS Total_Aggregated_TB_ART
ORDER BY Total_Aggregated_TB_ART.sort_order