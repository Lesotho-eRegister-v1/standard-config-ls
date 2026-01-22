SELECT Total_Aggregated_Cases.Age_Group
		, Total_Aggregated_Cases.Total_TB_Screened 
		, Total_Aggregated_Cases.TB_Suspected
		, Total_Aggregated_Cases.Total_Diagnosed
		, Total_Aggregated_Cases.Total_On_Treatment

FROM

(
	(SELECT case_detection.Age_Group AS 'Age_Group',
			IF(case_detection.Id IS NULL, 0, SUM(IF(TB_Status = 'No Signs' OR TB_Status = 'Suspected/Probable' OR TB_Status = 'On TB Treatment', 1, 0))) AS Total_TB_Screened,
			IF(case_detection.Id IS NULL, 0, SUM(IF(TB_Status = 'Suspected/Probable', 1, 0))) AS TB_Suspected,
			IF(case_detection.Id IS NULL, 0, SUM(IF(Presumptive_Case = 'GeneXpert' OR Presumptive_Case = 'Line Probe Assay' OR Presumptive_Case = 'Sputum Smear Microscopy' OR Presumptive_Case = 'X-Ray' , 1, 0))) AS Total_Diagnosed,
			IF(case_detection.Id IS NULL, 0, SUM(IF(TB_Status = 'On TB Treatment' , 1, 0))) AS Total_On_Treatment,
			case_detection.sort_order
			
			
	FROM

	(
SELECT distinct Id, patientIdentifier, patientName, Age,age_group, Gender, TB_Status, IFNULL(Presumptive_Case, "N/A") as Presumptive_Case, IFNULL(Diagnosis, "N/A"), IFNULL(TB_Start_Date, "N/A"), IFNULL(Died_Before_Treatment,"N/A"), IFNULL(Key_Populations,"N/A"), IFNULL(Referred_By,"N/A"), sort_order
 FROM (
(Select distinct Id, patientIdentifier , patientName, Age, age_group, Gender, Sign as "TB_Status",sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order, 
						case
						when o.value_coded = 3709 then "No Signs"
						when o.value_coded = 1876 then "Suspected/Probable"
						when o.value_coded = 3639 then "On TB Treatment"
						else "N/A" 
						end AS Sign
					from obs o
					--  TB Screened
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3710
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)
) as signs 
left JOIN
(Select distinct Person_Id, Presumptive_Case
		From(
				select distinct patient.patient_id AS Person_Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order,
						case
						when o.value_coded = 3824 then "GeneXpert"
						when o.value_coded = 3825 then "Line Probe Assay"
						when o.value_coded = 3819 then "Sputum Smear Microscopy"
						when o.value_coded = 1045 then "X-Ray"
						else "N/A" 
						end AS Presumptive_Case 
					from obs o
					--  TB Clients diagnosed by GeneXpert
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id in (3814,3815)
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)presumptive 
on signs.Id = presumptive.Person_Id
Left Join 
-- TEST RESULTS
(select person_id, Diagnosis
from
(
(
 -- Phenotypic Test Results
 select o.person_id,case 
 when o.value_coded = 1016 then "Negative"
 when o.value_coded = 3828 then "Scanty 1"
 when o.value_coded = 3829 then "Scanty 2"
 when o.value_coded = 3830 then "Scanty 3"
 when o.value_coded = 3831 then "Scanty 4"
 when o.value_coded = 3832 then "Scanty 5"
 when o.value_coded = 3833 then "Scanty 6"
 when o.value_coded = 3834 then "Scanty 7"
 when o.value_coded = 3835 then "Scanty 8"
 when o.value_coded = 3836 then "Scanty 9"
 when o.value_coded = 3837 then "Pos 1+"
 when o.value_coded = 3838 then "Pos 2+"
 when o.value_coded = 3839 then "Pos 3+"
else "N/A" 
end AS Diagnosis
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3840 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3840
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)

UNION

(
 -- GeneXpert Test Results
 select o.person_id,case
 when o.value_coded = 3816 then "MTB Detected,RS"
 when o.value_coded = 3817 then "MTB Detected,RR"
 when o.value_coded = 3818 then "MTB Detected,RSI"
 when o.value_coded = 3820 then "MTB not Detected"
else "N/A" 
end AS Diagnosis
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3787 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3787
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)

UNION

(
 -- LPA Test Results
 select o.person_id,case
 when o.value_coded = 1738 then "Positive"
 when o.value_coded = 1016 then "Negative"
 when o.value_coded = 3801 then "Contaminated"
else "N/A" 
end AS Diagnosis
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3805 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3805
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)
)test
)test_result
on signs.Id = test_result.person_id
Left Outer Join
(
-- TB Treatment Start Date
	(select o.person_id, CAST(start_date AS DATE) as TB_Start_Date
	from obs o
    inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as start_date
     from obs oss
     where oss.concept_id = 2237 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest
    on latest.person_id = o.person_id)
	UNION
	(
		select o.person_id, "N/A" as "TB_Start_Date"
	from obs o
	where o.concept_id = 3789 and o.value_coded = 3791
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id
	) 
) as tb_start_date
on signs.Id = tb_start_date.person_id
Left Outer Join
(
-- Died before treatment
	(select o.person_id, "Yes" as "Died_Before_Treatment"
	from obs o
	where o.concept_id = 3789 and o.value_coded = 3791
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id)
	UNION(
		select o.person_id, "No" as "Died_Before_Treatment"
	from obs o
	where o.concept_id = 3789 and o.value_coded not in (3791)
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id
	)
) as died
on signs.Id = died.person_id
Left Outer Join
(
-- High Risk Population
 select o.person_id,case
 when o.value_coded = 3669 then "Factory worker"
 when o.value_coded = 3667 then "Miner"
 when o.value_coded = 3670 then "Health Worker"
 when o.value_coded = 3777 then "Household member of current miner"
 when o.value_coded = 3778 then "Household member of ex miner"
 when o.value_coded = 3779 then "Prison Staff"
 when o.value_coded = 3671 then "Prisoner"
 when o.value_coded = 3668 then "Ex-miner"
 when o.value_coded = 4654 then "Public Transport"
 when o.value_coded = 4919 then "Contact of DRTB patient"
else "N/A" 
end AS Key_Populations
from obs o
where o.concept_id = 3776 and o.voided = 0
and o.obs_datetime >= cast('#startDate#' as date)
and o.obs_datetime <= cast('#endDate#' as date)
Group by o.person_id
) risk
on signs.Id = risk.person_id
Left Outer Join
(
-- Referred By
	(select distinct o.person_id, "CHW" as "Referred_By"
	from obs o
	where o.concept_id = 3780 and o.value_coded = 3784
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id)
	UNION(
		select distinct o.person_id, "CBO or CSO" as "Referred_By"
	from obs o
	where o.concept_id = 3780 and o.value_coded not in (3637)
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id
	)
) as referred
on signs.Id = referred.person_id

) AS case_detection

	GROUP BY case_detection.Age_group
	Order by case_detection.sort_order)
	
	
UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Status = 'No Signs' OR TB_Status = 'Suspected/Probable' OR TB_Status = 'On TB Treatment', 1, 0))) AS 'Total_TB_Screened'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Status = 'Suspected/Probable', 1, 0))) AS 'TB_Suspected'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Presumptive_Case = 'GeneXpert' OR Presumptive_Case = 'Line Probe Assay' OR Presumptive_Case = 'Sputum Smear Microscopy' OR Presumptive_Case = 'X-Ray', 1, 0))) AS 'Total_Diagnosed'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.TB_Status = 'On TB Treatment', 1, 0))) AS 'Total_On_Treatment'
		, 99 AS 'sort_order'
FROM

		(SELECT  Total_case_detection.Id
					, Total_case_detection.Age
					, Total_case_detection.TB_Status
					, Total_case_detection.Presumptive_Case
					, Total_case_detection.sort_order
				
		FROM

		(
SELECT distinct Id, patientIdentifier, patientName, Age,age_group, Gender, TB_Status, IFNULL(Presumptive_Case, "N/A") as Presumptive_Case, IFNULL(Diagnosis, "N/A"), IFNULL(TB_Start_Date, "N/A"), IFNULL(Died_Before_Treatment,"N/A"), IFNULL(Key_Populations,"N/A"), IFNULL(Referred_By,"N/A"), sort_order
 FROM (
(Select distinct Id, patientIdentifier , patientName, Age, age_group, Gender, Sign as "TB_Status",sort_order
		From(
				select distinct patient.patient_id AS Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order, 
						case
						when o.value_coded = 3709 then "No Signs"
						when o.value_coded = 1876 then "Suspected/Probable"
						when o.value_coded = 3639 then "On TB Treatment"
						else "N/A" 
						end AS Sign
					from obs o
					--  TB Screened
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id = 3710
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)
) as signs 
left JOIN
(Select distinct Person_Id, Presumptive_Case
		From(
				select distinct patient.patient_id AS Person_Id,
						patient_identifier.identifier AS patientIdentifier,
						concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
						floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
						observed_age_group.name AS age_group,
						person.gender AS Gender,
						observed_age_group.sort_order AS sort_order,
						case
						when o.value_coded = 3824 then "GeneXpert"
						when o.value_coded = 3825 then "Line Probe Assay"
						when o.value_coded = 3819 then "Sputum Smear Microscopy"
						when o.value_coded = 1045 then "X-Ray"
						else "N/A" 
						end AS Presumptive_Case 
					from obs o
					--  TB Clients diagnosed by GeneXpert
						INNER JOIN patient ON o.person_id = patient.patient_id 
						INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1
						INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
						AND o.voided=0
						INNER JOIN reporting_age_group AS observed_age_group ON
						CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
						WHERE observed_age_group.report_group_name = 'Modified_Ages'
						AND o.concept_id in (3814,3815)
						AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
						AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
						AND patient.voided = 0 AND o.voided = 0
						Group by o.person_id) AS TB_TESTING
)presumptive 
on signs.Id = presumptive.Person_Id
Left Join 
-- TEST RESULTS
(select person_id, Diagnosis
from
(
(
 -- Phenotypic Test Results
 select o.person_id,case 
 when o.value_coded = 1016 then "Negative"
 when o.value_coded = 3828 then "Scanty 1"
 when o.value_coded = 3829 then "Scanty 2"
 when o.value_coded = 3830 then "Scanty 3"
 when o.value_coded = 3831 then "Scanty 4"
 when o.value_coded = 3832 then "Scanty 5"
 when o.value_coded = 3833 then "Scanty 6"
 when o.value_coded = 3834 then "Scanty 7"
 when o.value_coded = 3835 then "Scanty 8"
 when o.value_coded = 3836 then "Scanty 9"
 when o.value_coded = 3837 then "Pos 1+"
 when o.value_coded = 3838 then "Pos 2+"
 when o.value_coded = 3839 then "Pos 3+"
else "N/A" 
end AS Diagnosis
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3840 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3840
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)

UNION

(
 -- GeneXpert Test Results
 select o.person_id,case
 when o.value_coded = 3816 then "MTB Detected,RS"
 when o.value_coded = 3817 then "MTB Detected,RR"
 when o.value_coded = 3818 then "MTB Detected,RSI"
 when o.value_coded = 3820 then "MTB not Detected"
else "N/A" 
end AS Diagnosis
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3787 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3787
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)

UNION

(
 -- LPA Test Results
 select o.person_id,case
 when o.value_coded = 1738 then "Positive"
 when o.value_coded = 1016 then "Negative"
 when o.value_coded = 3801 then "Contaminated"
else "N/A" 
end AS Diagnosis
from obs o
inner join 
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as latest_results
		 from obs oss
		 where oss.concept_id = 3805 and oss.voided=0
		 and oss.obs_datetime >= cast('#startDate#' as date)
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest 
	on latest.person_id = o.person_id
	where concept_id = 3805
	and o.obs_datetime = max_observation
	and o.voided = 0	
	)
)test
)test_result
on signs.Id = test_result.person_id
Left Outer Join
(
-- TB Treatment Start Date
	(select o.person_id, CAST(start_date AS DATE) as TB_Start_Date
	from obs o
    inner join 
    (
     select oss.person_id, MAX(oss.obs_datetime) as max_observation,
     SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_datetime)), 20) as start_date
     from obs oss
     where oss.concept_id = 2237 and oss.voided=0
     and oss.obs_datetime < cast('#endDate#' as date)
     group by oss.person_id
    )latest
    on latest.person_id = o.person_id)
	UNION
	(
		select o.person_id, "N/A" as "TB_Start_Date"
	from obs o
	where o.concept_id = 3789 and o.value_coded = 3791
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id
	) 
) as tb_start_date
on signs.Id = tb_start_date.person_id
Left Outer Join
(
-- Died before treatment
	(select o.person_id, "Yes" as "Died_Before_Treatment"
	from obs o
	where o.concept_id = 3789 and o.value_coded = 3791
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id)
	UNION(
		select o.person_id, "No" as "Died_Before_Treatment"
	from obs o
	where o.concept_id = 3789 and o.value_coded not in (3791)
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id
	)
) as died
on signs.Id = died.person_id
Left Outer Join
(
-- High Risk Population
 select o.person_id,case
 when o.value_coded = 3669 then "Factory worker"
 when o.value_coded = 3667 then "Miner"
 when o.value_coded = 3670 then "Health Worker"
 when o.value_coded = 3777 then "Household member of current miner"
 when o.value_coded = 3778 then "Household member of ex miner"
 when o.value_coded = 3779 then "Prison Staff"
 when o.value_coded = 3671 then "Prisoner"
 when o.value_coded = 3668 then "Ex-miner"
 when o.value_coded = 4654 then "Public Transport"
 when o.value_coded = 4919 then "Contact of DRTB patient"
else "N/A" 
end AS Key_Populations
from obs o
where o.concept_id = 3776 and o.voided = 0
and o.obs_datetime >= cast('#startDate#' as date)
and o.obs_datetime <= cast('#endDate#' as date)
Group by o.person_id
) risk
on signs.Id = risk.person_id
Left Outer Join
(
-- Referred By
	(select distinct o.person_id, "CHW" as "Referred_By"
	from obs o
	where o.concept_id = 3780 and o.value_coded = 3784
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id)
	UNION(
		select distinct o.person_id, "CBO or CSO" as "Referred_By"
	from obs o
	where o.concept_id = 3780 and o.value_coded not in (3637)
	and o.voided = 0
	and o.obs_datetime >= cast('#startDate#' as date)
	and o.obs_datetime <= cast('#endDate#' as date)
	group by o.person_id
	)
) as referred
on signs.Id = referred.person_id
) AS Total_case_detection
-- Order by Total_case_detection.sort_order
  ) AS Totals
 )
) AS Total_Aggregated_Cases
Order by Total_Aggregated_Cases.sort_order

