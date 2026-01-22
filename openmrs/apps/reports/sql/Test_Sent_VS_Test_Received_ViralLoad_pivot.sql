SELECT Total_Aggregated_VL.AgeGroup
		, Total_Aggregated_VL.Male_VL_Tests
		, Total_Aggregated_VL.Female_VL_Tests
        , Total_Aggregated_VL. Total
		-- , Total_Aggregated_VL.Male_Results_Received
		-- , Total_Aggregated_VL.Female_Results_Received
        

FROM

(
	(SELECT VL_DETAILS.age_group AS 'AgeGroup'
			, IF(VL_DETAILS.Id IS NULL, 0, SUM(IF(VL_DETAILS.Test = 'Done' AND VL_DETAILS.Gender = 'M', 1, 0))) AS Male_VL_Tests
			, IF(VL_DETAILS.Id IS NULL, 0, SUM(IF(VL_DETAILS.Test = 'Done' AND VL_DETAILS.Gender = 'F', 1, 0))) AS Female_VL_Tests
			-- , IF(VL_DETAILS.Id IS NULL, 0, SUM(IF(VL_DETAILS.received = 'Received' AND VL_DETAILS.Gender = 'M', 1, 0))) AS Male_Results_Received
			-- , IF(VL_DETAILS.Id IS NULL, 0, SUM(IF(VL_DETAILS.received = 'Received' AND VL_DETAILS.Gender = 'F', 1, 0))) AS Female_Results_Received
            , IF(VL_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, VL_DETAILS.sort_order
			
	FROM

	(
	
            Select Id, patientIdentifier as Patient_Identifier,  patientName as Patient_Name, age_group, Age, Gender, 
        date_collected as "Date Specimen Collected",Test,Results, sort_order
From
(select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                -- p.identifier as ART_Number,
                concat(person_name.given_name, " ", person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                cast(o.date_created as date) as date_collected,
                observed_age_group.name AS age_group,
                "Done" AS Test,
                observed_age_group.sort_order AS sort_order,
		        order_id

            from orders o
            -- Viral Load Tests Sent
                    INNER JOIN patient ON o.patient_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    AND o.concept_id = 5484
                    -- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                    WHERE observed_age_group.report_group_name = 'Modified_Ages'
                    AND CAST(o.date_created AS DATE) >= CAST('#startDate#' AS DATE)
                    AND CAST(o.date_created AS DATE) <= CAST('#endDate#' AS DATE)) as test

Left Outer Join

(Select person_id, Lab_Order_Number, lab_order.order_id as orders_id , VL_result.order_id, VL_result.Results, result_date 
FROM
(select person_id, cast(obs_datetime as date)as max_observation, SUBSTRING(CONCAT(obs_datetime, obs_id), 20) AS observation_id, order_id, value_text  as Lab_Order_Number
        from obs where concept_id = 5498 -- Lab order number
	    and cast(obs_datetime as date) >= cast('#startDate#' as date)
        and cast(obs_datetime as date) <= cast('#endDate#' as date)
        and voided = 0
        -- group by person_id
		)lab_order

left outer join

(Select pId, result.order_id, Results, cast(obs_datetime as date) as result_date
    From
      (
        select oss.person_id as pId, concat(oss.value_numeric, " ", "copies/ml")  as Results, order_id, oss.obs_datetime
            from obs oss
            where oss.concept_id = 5485
            and oss.voided=0
            and cast(oss.obs_datetime as date) >= cast('#startDate#' as date)
            -- group by oss.person_id

    UNION

    select oss.person_id as pId, "LDL"  as Results, order_id, oss.obs_datetime
            from obs oss
            where oss.concept_id = 5489
            and oss.voided=0
            and cast(oss.obs_datetime as date)  >= cast('#startDate#' as date)
            -- group by oss.person_id

      )result
      )VL_result
	  on lab_order.order_id = VL_result.order_id

)lab_orders	
on test.order_id = lab_orders.orders_id


	) AS VL_DETAILS

	GROUP BY VL_DETAILS.age_group
	ORDER BY VL_DETAILS.sort_order)

UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Test = 'Done' AND Totals.Gender = 'M', 1, 0))) AS 'Male_VL_Tests'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Test = 'Done' AND Totals.Gender = 'F', 1, 0))) AS 'Female_VL_Tests'
		-- , IF(Totals.Id IS NULL, 0, SUM(IF(Totals.received = 'Received' AND Totals.Gender = 'M', 1, 0))) AS 'Male_Results_Received'
		-- , IF(Totals.Id IS NULL, 0, SUM(IF(Totals.received = 'Received' AND Totals.Gender = 'F', 1, 0))) AS 'Female_Results_Received'
        , IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_VL.Id
					, Total_VL.Patient_Identifier
					, Total_VL.Patient_Name
					, Total_VL.Age
					, Total_VL.Gender
					, Total_VL.Test
				
		FROM

		(

             Select Id, patientIdentifier as Patient_Identifier,  patientName as Patient_Name, age_group, Age, Gender, 
        date_collected as "Date Specimen Collected",Test,Results sort_order
From
(select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                -- p.identifier as ART_Number,
                concat(person_name.given_name, " ", person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                cast(o.date_created as date) as date_collected,
                observed_age_group.name AS age_group,
                "Done" AS Test,
                observed_age_group.sort_order AS sort_order,
		order_id

            from orders o
            -- Viral Load Tests Sent
                    INNER JOIN patient ON o.patient_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    AND o.concept_id = 5484
                    -- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                    WHERE observed_age_group.report_group_name = 'Modified_Ages'
                    AND CAST(o.date_created AS DATE) >= CAST('#startDate#' AS DATE)
                    AND CAST(o.date_created AS DATE) <= CAST('#endDate#' AS DATE)) as test

Left Outer Join

(Select person_id, Lab_Order_Number, lab_order.order_id as orders_id , VL_result.order_id, VL_result.Results, result_date 
FROM
(select person_id, cast(obs_datetime as date)as max_observation, SUBSTRING(CONCAT(obs_datetime, obs_id), 20) AS observation_id, order_id, value_text  as Lab_Order_Number
        from obs where concept_id = 5498 -- Lab order number
	and cast(obs_datetime as date) >= cast('#startDate#' as date)
        and cast(obs_datetime as date) <= cast('#endDate#' as date)
        and voided = 0
        -- group by person_id
		)lab_order

left outer join

(Select pId, result.order_id, Results, cast(obs_datetime as date) as result_date
    From
      (
        select oss.person_id as pId, concat(oss.value_numeric, " ", "copies/ml")  as Results, order_id, oss.obs_datetime
            from obs oss
            where oss.concept_id = 5485
            and oss.voided=0
            and cast(oss.obs_datetime as date) >= cast('#startDate#' as date)
            -- group by oss.person_id

    UNION

    select oss.person_id as pId, "LDL"  as Results, order_id, oss.obs_datetime
            from obs oss
            where oss.concept_id = 5489
            and oss.voided=0
            and cast(oss.obs_datetime as date)  >= cast('#startDate#' as date)
            -- group by oss.person_id

      )result
      )VL_result
	  on lab_order.order_id = VL_result.order_id

)lab_orders	
on test.order_id = lab_orders.orders_id


	) AS Total_VL
  ) AS Totals
 )
) AS Total_Aggregated_VL
ORDER BY Total_Aggregated_VL.sort_order