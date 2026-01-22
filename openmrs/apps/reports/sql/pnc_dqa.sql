SELECT distinct Patient_Identifier,
                PNC_Number,
                ANC_Number,
	  		    Patient_Name,
				Age,
				Date_Of_Delivery,
                Place_of_Delivery,
                Mode_Of_Delivery,
                Timing,
                Contact_Date,
                ARV_Prophylaxis,
                Vitamin_A,
                Known_HIV_Status_Before_Contact,
                HIV_Tests_In_PNC_Results,
                WHO_Clinical_Stage,
                On_ART,
                MUAC_Less_than_23cm,
                Breast_Feeding_Status,
                Counselling_On_Family_Planning,
                Family_Planing_Method,
                Syphillis_Screening,
                Syphillis_Treatment,
                Cervical_Cancer_Screening,
                Cervical_Cancer_Treatment
FROM
(SELECT Id, patientIdentifier AS "Patient_Identifier",PNC_Number,ANC_Number,patientName AS "Patient_Name", Age
FROM
                (select distinct patient.patient_id AS Id,
									   patient_identifier.identifier AS patientIdentifier,
                                       pi2.identifier AS PNC_Number,
                                       p.identifier AS ANC_Number,
									   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
									   floor(datediff(CAST('#endDate#' AS DATE), person.birthdate)/365) AS Age,
									   observed_age_group.sort_order AS sort_order

                from obs o
						-- CLIENTS SEEN FOR PNC
						 INNER JOIN patient ON o.person_id = patient.patient_id 
						 AND (o.concept_id = 4386 				 
						 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
                         AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					     AND patient.voided = 0 AND o.voided = 0											
					)	
						 
						 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
						 INNER JOIN person_name ON person.person_id = person_name.person_id
						 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
                         LEFT JOIN patient_identifier pi2 ON pi2.patient_id = o.person_id AND pi2.identifier_type = 10
						 LEFT JOIN patient_identifier p ON p.patient_id = o.person_id AND p.identifier_type = 8
						 INNER JOIN reporting_age_group AS observed_age_group ON
						  CAST('2022-12-31' AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
						  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY))
                   WHERE observed_age_group.report_group_name = 'Modified_Ages') as seen_for_pnc
				   )pnc_seen

left outer join 

(
	select oss.person_id, CAST(MAX(oss.value_datetime) AS DATE) as Date_Of_Delivery,
 	SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		 from obs oss
		 where oss.concept_id = 1914
		 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
)as dateOfdelivery
ON pnc_seen.Id = dateOfdelivery.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Place of Delivery
           when value_coded = 1915 then "Institutional Delivery"
           when value_coded = 1916 then "Home Delivery"
           when value_coded = 5096 then "Born Before Arrival"
           else ""
       end AS Place_of_Delivery
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as delivery_location
		 from obs oss
		 where oss.concept_id = 1917 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 1917
	and  o.obs_datetime = max_observation and o.voided = 0
) place_delivery
ON pnc_seen.Id = place_delivery.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Mode of Delivery
           when value_coded = 1925 then "Normal Vertex Delivery"
           when value_coded = 1927 then "Cesarean Section"
           when value_coded = 314 then "Breech"
           when value_coded = 1926 then "Assisted Vaginal Delivery"
           when value_coded = 1975 then "Not Applicable"
           else ""
       end AS Mode_Of_Delivery
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as mode_of_delivery
		 from obs oss
		 where oss.concept_id = 1928 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 1928
	and  o.obs_datetime = max_observation and o.voided = 0
) modeOfdelivery
ON pnc_seen.Id = modeOfdelivery.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Examination Timing
           when value_coded = 4394 then "1st Hour "
           when value_coded = 4395 then "12th Hour"
           when value_coded = 4396 then "24th Hour"
           when value_coded = 4397 then "1st Week"
           when value_coded = 4398 then "6th Week"
           when value_coded = 4399 then "10th Week"
           when value_coded = 4400 then "14th Week"
           when value_coded = 4401 then "6th Month"
           else ""
       end AS Timing
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as examination_timing
		 from obs oss
		 where oss.concept_id = 4393 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4393
	and  o.obs_datetime = max_observation and o.voided = 0
) timing
ON pnc_seen.Id = timing.person_id

left outer join 

(
	select oss.person_id, CAST(MAX(oss.obs_datetime) AS DATE) as Contact_Date,
 	SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
		 from obs oss
		 where oss.concept_id = 5275
		 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
)as contactDate
ON pnc_seen.Id = contactDate.person_id
left outer JOIN

(select
       o.person_id,
       case
	   -- ARV Prophylaxis
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS ARV_Prophylaxis
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as prophylaxix
		 from obs oss
		 where oss.concept_id = 4410 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4410
	and  o.obs_datetime = max_observation and o.voided = 0
) prophy
ON pnc_seen.Id = prophy.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Vitamin A
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS Vitamin_A
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as vitamina
		 from obs oss
		 where oss.concept_id = 2471 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 2471
	and  o.obs_datetime = max_observation and o.voided = 0
) vitamin
ON pnc_seen.Id = vitamin.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Known HIV Status
           when value_coded = 1016 then "Negative"
           when value_coded = 1738 then "Positive"
		   when value_coded = 1739 then "Unknown"
           else ""
       end AS Known_HIV_Status_Before_Contact
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as known_Status
		 from obs oss
		 where oss.concept_id = 4427 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4427
	and  o.obs_datetime = max_observation and o.voided = 0
) KnownStatus
ON pnc_seen.Id = KnownStatus.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Tests Results in PNC
           when value_coded = 1016 then "Negative"
           when value_coded = 1738 then "Positive"
		   when value_coded = 4321 then "Declined"
		   when value_coded = 1975 then "Not Applicable"
           else ""
       end AS HIV_Tests_In_PNC_Results
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as testedpnc
		 from obs oss
		 where oss.concept_id = 4428 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4428
	and  o.obs_datetime = max_observation and o.voided = 0
) pnctest
ON pnc_seen.Id = pnctest.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- WHO Staging
           when value_coded = 2167 then "Stage I"
           when value_coded = 2168 then "Stage II"
		   when value_coded = 2169 then "Stage III"
		   when value_coded = 2170 then "Stage IV"
           else ""
       end AS WHO_Clinical_Stage
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as whostaging
		 from obs oss
		 where oss.concept_id = 2342 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 2342
	and  o.obs_datetime = max_observation and o.voided = 0
) whostage
ON pnc_seen.Id = whostage.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- On ART
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
		   when value_coded = 1975 then "Not Applicable"
           else ""
       end AS On_ART
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as OnArt
		 from obs oss
		 where oss.concept_id = 4429 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4429
	and  o.obs_datetime = max_observation and o.voided = 0
) Onart
ON pnc_seen.Id = Onart.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Muac < 23
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS MUAC_Less_than_23cm
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Muac
		 from obs oss
		 where oss.concept_id = 4435 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4435
	and  o.obs_datetime = max_observation
) muac
ON pnc_seen.Id = muac.person_id

left outer JOIN

(
	select
       o.person_id,
       case
	   -- Breastfeeding Status
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS Breast_Feeding_Status
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as breastfeeding_status
		 from obs oss
		 where oss.concept_id = 5291 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 5291
	and  o.obs_datetime = max_observation and o.voided = 0
)status_breastfeeding
ON pnc_seen.Id = status_breastfeeding.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Family Planning Counselling
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS Counselling_On_Family_Planning
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as counselling_fp
		 from obs oss
		 where oss.concept_id = 4350 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4350
	and  o.obs_datetime = max_observation and o.voided = 0
) family_planning_counselling
ON pnc_seen.Id = family_planning_counselling.person_id

left outer JOIN			
								
(select
       o.person_id,
       case
	   -- Family Planning Method
           when value_coded = 5205 then "Progestrone only pill"
           when value_coded = 5206 then "Combined oral contraceptive"
		   when value_coded = 5207 then "DMPA-SC"
           when value_coded = 5208 then "DMPA-IM"
		   when value_coded = 5209 then "Noristrate"
           when value_coded = 2314 then "Implant"
		   when value_coded = 4551 then "Jadelle"
           when value_coded = 5212 then "Norplant"
		   when value_coded = 4441 then "Lactational Amenorrhea Method"
           when value_coded = 4552 then "Copper T380A"
		   when value_coded = 4440 then "Bilateral Tubal Ligation"
           when value_coded = 2497 then "Vasectomy"
		   when value_coded = 4229 then "Male Condoms"
           when value_coded = 4230 then "Female Condoms"
		   when value_coded = 4553 then "Standard Days Method"
           when value_coded = 5215 then "Emergency Pill"
		   when value_coded = 5214 then "IUCD"
           when value_coded = 1154 then "None"
           else ""
       		end AS Family_Planing_Method
			from obs o
			inner join
								(select B.person_id, B.obs_group_id, SUBSTRING(MAX(CONCAT(B.obs_datetime, B.value_coded)), 20) as method_fp
									from obs B
									inner join 
									(select oss.person_id, MAX(oss.obs_datetime) as max_observation,
									 SUBSTRING(MAX(CONCAT(obs_datetime, obs_id)), 20) AS observation_id
									from obs oss where oss.concept_id = 4386
									and oss.obs_datetime <= cast('#endDate#' as date)
									and oss.voided = 0
									group by person_id) as A
									on A.observation_id = B.obs_group_id
									where concept_id = 2481
									and A.observation_id = B.obs_group_id
                                    and voided = 0	
									group by B.person_id
								) family_planning_method
								On family_planning_method.person_id = o.person_id
								where concept_id = 2481
								and o.voided = 0
								-- and  o.obs_datetime = max_observation
								and o.voided =0
)fp_method
ON pnc_seen.Id = fp_method.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Syphillis Screening
           when value_coded = 4306 then "Reactive"
           when value_coded = 4307 then "Non-Reactive"
		   when value_coded = 1975 then "N/A"
           else ""
       end AS Syphillis_Screening
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as screening_syphillis
		 from obs oss
		 where oss.concept_id = 5304 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 5304
	and  o.obs_datetime = max_observation and o.voided = 0
) Screening
ON pnc_seen.Id = Screening.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Syphillis Treatment
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
		   when value_coded = 1975 then "Not Applicable"
           else ""
       end AS Syphillis_Treatment
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as syphilis_treatment
		 from obs oss
		 where oss.concept_id = 5305 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 5305
	and  o.obs_datetime = max_observation and o.voided = 0
) treatment
ON pnc_seen.Id = treatment.person_id


left outer join 

(select
       o.person_id,
       case
	   -- Cervical Cancer Screening
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
           else ""
       end AS Cervical_Cancer_Screening
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as screening_cancer
		 from obs oss
		 where oss.concept_id = 4445 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4445
	and  o.obs_datetime = max_observation and o.voided = 0
) Cervical_Cancer
ON pnc_seen.Id = Cervical_Cancer.person_id

left outer JOIN

(select
       o.person_id,
       case
	   -- Cervical Cancer Treatment Treatment
           when value_coded = 2146 then "Yes"
           when value_coded = 2147 then "No"
		   when value_coded = 1975 then "Not Applicable"
           else ""
       end AS Cervical_Cancer_Treatment
from obs o
inner join
		(
		 select oss.person_id, MAX(oss.obs_datetime) as max_observation,
		 SUBSTRING(MAX(CONCAT(oss.obs_datetime, oss.value_coded)), 20) as Cervical_treatment
		 from obs oss
		 where oss.concept_id = 4446 and oss.voided=0
		 and oss.obs_datetime <= cast('#endDate#' as date)
		 group by oss.person_id
		)latest
	on latest.person_id = o.person_id
	where concept_id = 4446
	and  o.obs_datetime = max_observation and o.voided = 0
) cervical_treatment
ON pnc_seen.Id = cervical_treatment.person_id