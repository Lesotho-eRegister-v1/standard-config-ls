Select patientIdentifier as "Patient Identifier",  patientName as "Patient Name",age_group, Age, Gender, 
        date_collected as "Date Specimen Collected",Test, Lab_Order_Number as "Lab Order Number", Results,result_date as "Date Results Received", 
        datediff(result_date, date_collected) as "Turn Around Time(days)"
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
-- order by 2

UNION ALL

-- Totals
SELECT  " Average Turn Around Time" as patientIdentifier, "" as  patientName,'' as age_group, '' as Age, '' as Gender, 
        '' as date_collected,'' as Test, '' as Lab_Order_Number, '' as Results,'' as result_date, round((total_turn_around_time/total_results_received),1) as "Average"
        
FROM(
Select patientIdentifier,  patientName,age_group, Age, Gender, 
        date_collected,Test, Lab_Order_Number, Results,result_date, sum(turn_around_time) as total_turn_around_time, count(turn_around_time) as total_results_received
FROM
(Select  patientIdentifier,  patientName,age_group, Age, Gender, 
        date_collected,Test, Lab_Order_Number, Results,result_date, 
        datediff(result_date, date_collected) as turn_around_time
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
)tests
)lab_orders_with_TAT
-- order by 2