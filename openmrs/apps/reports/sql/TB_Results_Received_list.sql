Select patientIdentifier as "Patient Identifier",  patientName as "Patient Name",age_group, Age, Gender, 
        Lab_Order_Number as "Lab Order Number", GeneXpert_Results,GeneXpert_Results_Date as "Date Results Received"
From
(select distinct patient.patient_id AS Id,
                patient_identifier.identifier AS patientIdentifier,
                concat(person_name.given_name, " ", person_name.family_name) AS patientName,
                floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
                person.gender AS Gender,
                observed_age_group.name AS age_group,
                observed_age_group.sort_order AS sort_order,
				order_id

            from obs o
            -- TB Results Received
                    INNER JOIN patient ON o.person_id = patient.patient_id 
                    INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
                    INNER JOIN person_name ON person.person_id = person_name.person_id
                    INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                    INNER JOIN reporting_age_group AS observed_age_group ON
                    CAST('#endDate#' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
                    AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                    AND o.concept_id in (6072,6068)
					WHERE observed_age_group.report_group_name = 'Modified_Ages'
					AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)) as tb_results

Left Outer Join

(Select person_id, Lab_Order_Number, lab_order.order_id as orders_id , geneXpert_result.order_id, GeneXpert_Results, GeneXpert_Results_Date 
FROM
(select person_id, cast(obs_datetime as date)as max_observation, SUBSTRING(CONCAT(obs_datetime, obs_id), 20) AS observation_id, order_id, value_text  as Lab_Order_Number
        from obs where concept_id = 5498 -- Lab order number
        and cast(obs_datetime as date) <= cast('#endDate#' as date)
        and voided = 0
)lab_order

left outer join

(Select pId, GeneXpert_Results, GeneXpert_Results_Date,order_id 
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
	-- Group by o.person_id
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
	-- Group by o.person_id
	)
	)Result
)geneXpert_result
on lab_order.order_id = geneXpert_result.order_id

)lab_orders	
on tb_results.order_id = lab_orders.orders_id

