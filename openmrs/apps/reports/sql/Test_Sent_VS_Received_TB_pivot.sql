SELECT Total_Aggregated_TB.AgeGroup
		, Total_Aggregated_TB.Male_VL_Tests
		, Total_Aggregated_TB.Female_VL_Tests
		-- , Total_Aggregated_TB.Male_Results_Received
		-- , Total_Aggregated_TB.Female_Results_Received
		, Total_Aggregated_TB.Total

FROM

(
	(SELECT TB_DETAILS.age_group AS 'AgeGroup'
			, IF(TB_DETAILS.Id IS NULL, 0, SUM(IF(TB_DETAILS.Test = 'Done' AND TB_DETAILS.Gender = 'M', 1, 0))) AS Male_VL_Tests
			, IF(TB_DETAILS.Id IS NULL, 0, SUM(IF(TB_DETAILS.Test = 'Done' AND TB_DETAILS.Gender = 'F', 1, 0))) AS Female_VL_Tests
			-- , IF(TB_DETAILS.Id IS NULL, 0, SUM(IF(TB_DETAILS.received = 'Received' AND TB_DETAILS.Gender = 'M', 1, 0))) AS Male_Results_Received
			-- , IF(TB_DETAILS.Id IS NULL, 0, SUM(IF(TB_DETAILS.received = 'Received' AND TB_DETAILS.Gender = 'F', 1, 0))) AS Female_Results_Received
            , IF(TB_DETAILS.Id IS NULL, 0, SUM(1)) as 'Total'
			, TB_DETAILS.sort_order
			
	FROM

	(
	
  Select Id,patientIdentifier,  patientName,age_group, Age, Gender,  date_collected,Test, Lab_Order_Number, GeneXpert_Results,GeneXpert_Results_Date,received,sort_order
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
            -- TB Tests Sent
                    INNER JOIN patient ON o.patient_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    AND o.concept_id in (1430,5938,5939)
                    -- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                WHERE observed_age_group.report_group_name = 'Modified_Ages'
                AND CAST(o.date_created AS DATE) >= CAST('#startDate#' AS DATE)
                AND CAST(o.date_created AS DATE) <= CAST('#endDate#' AS DATE)) as test

Left Outer Join
(Select person_id, Lab_Order_Number, lab_order.order_id as orders_id , geneXpert_result.order_id, GeneXpert_Results, GeneXpert_Results_Date, received 
FROM
(select person_id, cast(obs_datetime as date)as max_observation, SUBSTRING(CONCAT(obs_datetime, obs_id), 20) AS observation_id, order_id, value_text  as Lab_Order_Number
        from obs where concept_id = 5498 -- Lab order number
		and cast(obs_datetime as date) >= cast('#startDate#' as date)
        and cast(obs_datetime as date) <= cast('#endDate#' as date)
        and voided = 0
        -- group by person_id
)lab_order

left outer join

(Select pId, GeneXpert_Results, GeneXpert_Results_Date,order_id, "Received" as received 
	FROM(
	(
	select distinct o.person_id as pId, cast(o.obs_datetime as date) as GeneXpert_Results_Date,o.order_id,
	case
	when o.value_coded = 6069 then "Rifampicin Susceptible"
	when o.value_coded = 6070 then "Rifampicin Resistant"
	when o.value_coded = 6071 then "Rifampicin Indeterminate"
	else ""
	end AS GeneXpert_Results
	from obs o
	where o.concept_id = 6072 and o.voided = 0
	and o.obs_datetime >= CAST('#startDate#' AS DATE)
	Group by o.person_id
	)
	UNION
	(
	select distinct o.person_id as pId, cast(o.obs_datetime as date) as GeneXpert_Results_Date,o.order_id,
	case
	when o.value_coded = 6066 then "MTB Positive"
	when o.value_coded = 6067 then "MTB Negative"
	else ""
	end AS GeneXpert_Results
	from obs o
	where o.concept_id = 6068 and o.voided = 0
	and o.obs_datetime >= CAST('#startDate#' AS DATE)
	Group by o.person_id
	)
	)Result
)geneXpert_result
on lab_order.order_id = geneXpert_result.order_id

)lab_orders	
on test.order_id = lab_orders.orders_id

) AS TB_DETAILS

	GROUP BY TB_DETAILS.age_group
	ORDER BY TB_DETAILS.sort_order)

UNION ALL


(SELECT 'Total' AS AgeGroup
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Test = 'Done' AND Totals.Gender = 'M', 1, 0))) AS 'Male_VL_Tests'
		, IF(Totals.Id IS NULL, 0, SUM(IF(Totals.Test = 'Done' AND Totals.Gender = 'F', 1, 0))) AS 'Female_VL_Tests'
		-- , IF(Totals.Id IS NULL, 0, SUM(IF(Totals.received = 'Received' AND Totals.Gender = 'M', 1, 0))) AS 'Male_Results_Received'
		-- , IF(Totals.Id IS NULL, 0, SUM(IF(Totals.received = 'Received' AND Totals.Gender = 'F', 1, 0))) AS 'Female_Results_Received'
        , IF(Totals.Id IS NULL, 0, SUM(1)) as 'Total'
		, 99 AS 'sort_order'
		
FROM

		(SELECT  Total_TB.Id
					, Total_TB.patientIdentifier
					, Total_TB.patientName
					, Total_TB.Age
					, Total_TB.Gender
					, Total_TB.Test
                    , Total_TB.received
				
		FROM

	(

        Select Id,patientIdentifier,  patientName,age_group, Age, Gender,  date_collected,Test, Lab_Order_Number, GeneXpert_Results,GeneXpert_Results_Date,received,sort_order
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
            -- TB Tests Sent
                    INNER JOIN patient ON o.patient_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    AND o.concept_id in (1430,5938,5939)
                    -- LEFT OUTER JOIN patient_identifier p ON p.patient_id = person.person_id AND p.identifier_type = 5
                WHERE observed_age_group.report_group_name = 'Modified_Ages'
                AND CAST(o.date_created AS DATE) >= CAST('#startDate#' AS DATE)
                AND CAST(o.date_created AS DATE) <= CAST('#endDate#' AS DATE)) as test

Left Outer Join
(
    Select person_id, Lab_Order_Number, lab_order.order_id as orders_id , geneXpert_result.order_id, GeneXpert_Results, GeneXpert_Results_Date, received 
FROM
(select person_id, cast(obs_datetime as date)as max_observation, SUBSTRING(CONCAT(obs_datetime, obs_id), 20) AS observation_id, order_id, value_text  as Lab_Order_Number
        from obs where concept_id = 5498 -- Lab order number
		and cast(obs_datetime as date) >= cast('#startDate#' as date)
        and cast(obs_datetime as date) <= cast('#endDate#' as date)
        and voided = 0
        -- group by person_id
)lab_order

left outer join

(Select pId, GeneXpert_Results, GeneXpert_Results_Date,order_id, "Received" as received 
	FROM(
	(
	select distinct o.person_id as pId, cast(o.obs_datetime as date) as GeneXpert_Results_Date,o.order_id,
	case
	when o.value_coded = 6069 then "Rifampicin Susceptible"
	when o.value_coded = 6070 then "Rifampicin Resistant"
	when o.value_coded = 6071 then "Rifampicin Indeterminate"
	else ""
	end AS GeneXpert_Results
	from obs o
	where o.concept_id = 6072 and o.voided = 0
	and o.obs_datetime >= CAST('#startDate#' AS DATE)
	Group by o.person_id
	)
	UNION
	(
	select distinct o.person_id as pId, cast(o.obs_datetime as date) as GeneXpert_Results_Date,o.order_id,
	case
	when o.value_coded = 6066 then "MTB Positive"
	when o.value_coded = 6067 then "MTB Negative"
	else ""
	end AS GeneXpert_Results
	from obs o
	where o.concept_id = 6068 and o.voided = 0
	and o.obs_datetime >= CAST('#startDate#' AS DATE)
	Group by o.person_id
	)
	)Result
)geneXpert_result
on lab_order.order_id = geneXpert_result.order_id
) as lab_orders
on test.order_id = lab_orders.orders_id
) AS Total_TB
  ) AS Totals
 )
) AS Total_Aggregated_TB
ORDER BY Total_Aggregated_TB.sort_order