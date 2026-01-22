Select regimen_name,
IF(ID is null, 0,SUM(IF(outcome = 'drug_count',1,0))) AS "Total_Ordered"

FROM
(
SELECT ID, regimen_name, outcome, Weight	
from
(
		select distinct ID,B.person_id, C.value_numeric as Weight, regimen_name,weight_band, outcome
		FROM(select person_id, drug_inventory_id as ID, value_numeric, date_activated, 'drug_count' as outcome,
		case
		when drug_inventory_id = 390 then 'Abacavir (ABC) 300mg'
		when drug_inventory_id = 377 then 'Abacavir/Lamivudine (ABC/3TC) - 600/300mg'
		when drug_inventory_id = 379 then 'Atazanavir (ATV) _300mg'
		when drug_inventory_id = 391 then 'Atazanavir/Ritonavir (ATV/RIV) - 300/100mg'
		when drug_inventory_id = 385 then 'Darunavir_(DVR)_300mg'
		when drug_inventory_id = 386 then 'Darunavir (DVR) - 600mg'
		when drug_inventory_id = 355 then 'Dolutegravir (DTG) - 50mg'
		when drug_inventory_id = 357 then 'Efavirenz (EFV) - 600mg'
		when drug_inventory_id = 395 then 'Etravirine (ETV) - 100mg'
		when drug_inventory_id = 359 then 'Lamivudine (3TC) - 150mg'
		when drug_inventory_id = 374 then 'Lopinavir/Ritonavir (LPV/r) - 200/50mg'
		when drug_inventory_id = 358 then 'Nevirapine (NVP) - 200mg'
		when drug_inventory_id = 380 then 'Raltegravir (RAL) - 400mg'
		when drug_inventory_id = 378 then 'Ritonavir (RIV) - 100mg'
		when drug_inventory_id = 354 then 'Tenofovir (TDF) - 300mg'
		when drug_inventory_id = 376 then 'Tenofovir/Lamivudine (TDF/3TC) - 300/300mg'
		when drug_inventory_id = 368 then 'Tenofovir/Lamivudine/Dolutegravir (TDF/3TC/DTG) - 300/300/50mg'
		when drug_inventory_id = 396 THEN "Tenofovir/Lamivudine/Efavirenz (TDF/3TC/EFV) - 300/300/400mg"
		when drug_inventory_id = 388 THEN "Tenofovir/Lamivudine/Efavirenz (TDF/3TC/EFV) - 300/300/600mg"
		when drug_inventory_id = 360 THEN "Zidovudine (AZT) - 300mg"
		when drug_inventory_id = 375 THEN "Zidovudine/Lamivudine (AZT/3TC)- 300/150mg"
		when drug_inventory_id = 389 THEN "Zidovudine/Lamivudine/Nevirapine (AZT/3TC/NVP) - 300/150/200mg"
		when drug_inventory_id = 363 THEN "Abacavir (ABC) - 60mg"
		when drug_inventory_id = 369 THEN "Abacavir/lamivudine (ABC/3TC) - 120/60mg"
		when drug_inventory_id = 373 THEN "Darunavir (DRV) - 75mg"
		when drug_inventory_id = 351 THEN "Efavirenz (EFV) - 200mg"
		when drug_inventory_id = 370 THEN "Lopinavir/Ritonavir (LPV/r) - 80mg/20ml"
		when drug_inventory_id = 372 THEN "Lopinavir/Ritonavir (LPV/r) - 40/10mg"
		when drug_inventory_id = 371 THEN "Lopinavir/Ritonavir (LPV/r) - 100/25mg "
		when drug_inventory_id = 367 THEN "Nevirapine (NVP) - 50mg/5ml"
		when drug_inventory_id = 392 THEN "Raltegravir (RAL) - 100mg"
		when drug_inventory_id = 393 THEN "Zidovudine/Lamivudine (AZT/3TC) - 60/30mg"
		when drug_inventory_id = 394 THEN "Zidovudine/Lamivudine/Nevirapine (AZT/3TC/NVP) - 60/30/50mg"
		else 'OtherRegimen' end as regimen_name
		from					
					
					(select distinct o.person_id,e.encounter_id,encounter_type,value_numeric,drug_inventory_id, date_activated
										from encounter e
										inner join obs o on e.patient_id = person_id
										and MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
										inner join orders od on e.encounter_id = od.encounter_id
										inner join drug_order d on od.order_id = d.order_id
										where MONTH(od.date_activated) = MONTH(CAST('#endDate#' AS DATE))
										AND YEAR(od.date_activated) =  YEAR(CAST('#endDate#' AS DATE))
									)A
		)B
		left outer join
					(select person_id, value_numeric
						from obs o
						where concept_id = 119
						AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
						AND YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
						
						)C
					on B.person_id = C.person_id
		left outer join
						(select person_id,value_numeric,
						case
						when value_numeric >=25 and value_numeric < 34.9 then '25.0 - 34.9kg'
						when value_numeric >=3 and value_numeric < 5.9 then '3.0 - 5.9kg'
						when value_numeric >=6 and value_numeric < 9.9 then '6.0 - 9.9kg'
						when value_numeric >=10 and value_numeric < 13.9 then '10.0 - 13.9kg'
						when value_numeric >=14 and value_numeric < 19.9 then '14.0 - 19.9kg'
						when value_numeric >=20 and value_numeric < 24.9 then '20.0 - 24.9kg'
						when value_numeric is Null then '0'
						else '35 and above' end as weight_band
						from
								(select person_id, value_numeric
												from obs o
												where concept_id = 119
												AND MONTH(o.obs_datetime) = MONTH(CAST('#endDate#' AS DATE))
												AND YEAR(o.obs_datetime) =  YEAR(CAST('#endDate#' AS DATE))
									)E	
							)F
							on B.person_id = F.person_id							
)as K
)Q
group by regimen_name