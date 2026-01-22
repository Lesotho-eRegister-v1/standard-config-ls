Select patientIdentifier as "Patient Identifier",  patientName as "Patient Name",age_group, Age, Gender,Lab_Order_Number as "Lab Order Number", 
        Results,result_date as "Date Results Received"
From
(select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                -- p.identifier as ART_Number,
                concat(person_name.given_name, " ", person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group,
                observed_age_group.sort_order AS sort_order,
                order_id
                
            from obs o
            -- Viral Load Results Received
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    AND o.concept_id in (5485,5489)
                    -- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                WHERE observed_age_group.report_group_name = 'Modified_Ages'
                AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)) as VL_results

Left Outer Join

(Select person_id, Lab_Order_Number, lab_order.order_id as orders_id , VL_result.order_id, VL_result.Results, result_date 
FROM
(select person_id, cast(obs_datetime as date)as max_observation, SUBSTRING(CONCAT(obs_datetime, obs_id), 20) AS observation_id, order_id, value_text  as Lab_Order_Number
        from obs where concept_id = 5498 -- Lab order number
        and cast(obs_datetime as date) <= cast('#endDate#' as date)
        and voided = 0
        -- group by person_id
		)lab_order

left outer join

(Select pId, result.order_id as order_id, Results, cast(obs_datetime as date) as result_date
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
on VL_results.order_id = lab_orders.orders_id
order by 2, 7, 8

