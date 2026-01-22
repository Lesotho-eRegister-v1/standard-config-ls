					 
SELECT  Patient_Identifier, Patient_Name, Age, age_group, Gender, mode_of_delivery, gestation_age_admission,anc_attendance,	
		hiv_status, hiv_status_at_maternity,ANC_arv_received,InitiatedART_at_LAD,Number_of_feotus,Doula,intrapartum_complications,intrapartum_inverventions,
		live_birth,	child_sex,Death,Newborth_Maturity,HIE_Prophylaxis,feeding_options,feeding_initiation,Immunization,baby_condition,mother_condition
    FROM(
	        (SELECT Id, patientIdentifier AS "Patient_Identifier", patientName AS "Patient_Name", Age, age_group, Gender,       
                             CASE
                                WHEN code = 1925 THEN 'Normal Vertex Delivery'
                                WHEN code = 1926 THEN 'Assisted Vagenal Delivery'
                                WHEN code = 1927 THEN 'Cesarean Section'
                                WHEN code = 5364 THEN 'Vaginal Breech Delivery'
                                WHEN code = 4288 THEN 'Normal Vertex Delivery and Cesarean Section'
                                ELSE 'no selection made'
                            END AS 'mode_of_delivery', sort_order
		        FROM
						(select distinct patient.patient_id AS Id,
											   patient_identifier.identifier AS patientIdentifier,
											   concat(person_name.given_name, ' ', person_name.family_name) AS patientName,
											   floor(datediff(CAST("#endDate#" AS DATE), person.birthdate)/365) AS Age,
											   observed_age_group.name AS age_group,
                                                person.gender AS Gender,
											   observed_age_group.sort_order AS sort_order,
                                               o.value_coded as 'code'

						from obs o
								-- [A] Institutional Deliveries sectin : Intergrated facility report

								 INNER JOIN patient ON o.person_id = patient.patient_id 
								 AND o.concept_id = 5363 and o.value_coded IN (1925,1926,1927,5364,4288)
								 AND patient.voided = 0 AND o.voided = 0
								 AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
					    		 AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
							
                                 INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0
								 INNER JOIN person_name ON person.person_id = person_name.person_id AND person_name.preferred = 1								 
								 INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1
								 
								 INNER JOIN reporting_age_group AS observed_age_group ON
								  CAST("#endDate#" AS DATE) BETWEEN (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.min_years YEAR), INTERVAL observed_age_group.min_days DAY))
								  AND (DATE_ADD(DATE_ADD(person.birthdate, INTERVAL observed_age_group.max_years YEAR), INTERVAL observed_age_group.max_days DAY)) 
						   WHERE observed_age_group.report_group_name = 'Delivery_ages'
						) AS CLIENT_DELIVERY
		    ORDER BY CLIENT_DELIVERY.Age)CLIENT_DELIVERY_MODE

			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN (o.value_numeric < 37) THEN '< 37 GA'
						WHEN (o.value_numeric > 36 AND o.value_numeric < 43) THEN '37 - 42 GA'
						WHEN (o.value_numeric > 42) THEN '> 42 GA'
						ELSE 'no gestation selection'
					END AS 'gestation_age_admission' 

				from obs o
						-- Gestation Age at Admission
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 1923 and (o.value_numeric > 14) 
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
						
				) AS CLIENT_GESTATION		    

		ON CLIENT_DELIVERY_MODE.Patient_Identifier = CLIENT_GESTATION.identifier 

		LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN (o.value_numeric < 8) THEN '< 8 visits'
						WHEN (o.value_numeric > 7) THEN '8+ visits'
						WHEN (o.value_numeric = 0) THEN 'Not Attend ANC'
						ELSE 'no attendance provided'
					END AS 'anc_attendance' 

				from obs o
						-- Get number of ANC attendances
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5106 and (o.value_numeric >= 0) 
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS ANC_VISITS

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = ANC_VISITS.identifier
				
			LEFT JOIN 		 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 1738 THEN 'Positive'
						WHEN o.value_coded = 1016 THEN 'Negative'
						WHEN o.value_coded = 4324 THEN 'Known Negative'
						WHEN o.value_coded = 4323 THEN 'Known Positive'
						WHEN o.value_coded = 1739 THEN 'Unknown'
						ELSE 'no status provided'
					END AS 'hiv_status' 

				from obs o
						-- Get the HIV status of the clients at ANC
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 1741 and o.value_coded IN (1738,1016,4324,4323,1739)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS HIV_STATUS

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = HIV_STATUS.identifier
	
			LEFT JOIN 		 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 1738 THEN 'Positive'
						WHEN o.value_coded = 1016 THEN 'Negative' 
						WHEN o.value_coded = 1975 THEN 'Not Applicable'
						WHEN o.value_coded = 1739 THEN 'Unknown'
						ELSE 'no status provided'
					END AS 'hiv_status_at_maternity' 

				from obs o
						-- Get HIV status at maternity
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5118 and o.value_coded IN (1738,1016,4324,4323,1739)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS HIV_STATUS_AT_MATERNITY

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = HIV_STATUS_AT_MATERNITY.identifier
				
			LEFT JOIN 		 
		
				(select distinct patient_identifier.identifier ,        
						CASE
							WHEN o.value_coded = 2146 THEN 'Yes'
							WHEN o.value_coded = 2147 THEN 'No' 
							WHEN o.value_coded = 1975 THEN 'Not Applicable' 
							ELSE 'no status provided'
						END AS 'ANC_arv_received' 

				from obs o
						-- Client receiving ART regimen at ANC
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5119 and o.value_coded IN (2146,2147,1975)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS ANC_ARV_RECEIVED

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = ANC_ARV_RECEIVED.identifier

			LEFT JOIN 		 
		
				(select distinct patient_identifier.identifier ,        
						CASE
							WHEN o.value_coded = 2146 THEN 'Yes'
							WHEN o.value_coded = 2147 THEN 'No'
							WHEN o.value_coded = 4341 THEN 'Already on ART' 
							WHEN o.value_coded = 1975 THEN 'Not Applicable' 
							ELSE 'no status provided'
						END AS 'InitiatedART_at_LAD' 

				from obs o
						-- Client initiated on ART at Labour and Delivery
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5120 and o.value_coded IN (2146,2147,4341,1975)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS LAD_INITIATED

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = LAD_INITIATED.identifier

			LEFT JOIN 		 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 5125 THEN 'Singleton'
						WHEN o.value_coded = 5126 THEN 'Twins'
						WHEN o.value_coded = 5127 THEN 'Triplets' 
						WHEN o.value_coded = 1033 THEN 'Quadtriples +' 
						ELSE 'no status provided'
					END AS 'Number_of_feotus' 

				from obs o
						-- Client number of foetus
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5124 and o.value_coded IN (5125,5126,5127,1033)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS NUMBER_OF_FOETUS

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = NUMBER_OF_FOETUS.identifier
				
			LEFT JOIN 		 
		
				(select distinct patient_identifier.identifier ,        
						CASE
							WHEN o.value_coded = 1 THEN 'Yes'
							WHEN o.value_coded = 2 THEN 'No'
							ELSE 'N/A'
						END AS 'Doula' 

				from obs o
						-- Doula
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5128 and o.value_coded IN (1,2)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS DOULA

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = DOULA.identifier
				 				
			LEFT JOIN 		 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 4368 THEN 'No complications'
						WHEN o.value_coded = 5131 THEN 'Prolonged rapture of membranes'
						WHEN o.value_coded = 5132 THEN 'Prolonged labour'
						WHEN o.value_coded = 926 THEN 'Obstructed labour'
						WHEN o.value_coded = 5108 THEN 'Pregnanc Induced Hypertension'
						WHEN o.value_coded = 5133 THEN 'Postpartum hemorrhage'
						WHEN o.value_coded = 4374 THEN 'Malpresentation'
						WHEN o.value_coded = 1958 THEN '3rd degree perineal laceration'
						WHEN o.value_coded = 5134 THEN '4th degree pereneal laceration'
						WHEN o.value_coded = 5135 THEN 'Retention of the placenta'
						WHEN o.value_coded = 5136 THEN 'Abruption of the Placenta'
						WHEN o.value_coded = 5137 THEN 'Placenta praevia'
						WHEN o.value_coded = 4408 THEN 'Infection'
						WHEN o.value_coded = 5138 THEN 'Rapture of the urerus'
						WHEN o.value_coded = 1033 THEN 'Other'
						ELSE 'N/A'
					END AS 'intrapartum_complications' 

				from obs o
						-- Postpartum complications
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5130 and o.value_coded IN 
												(
													4368, 5134, 5132, 926, 
												    5108, 5133, 4374, 1958,
													5134, 5135, 5136, 5137,
													4408, 5138, 1033  
												)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS INTRAPARTUM_COMPLICATIONS

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = INTRAPARTUM_COMPLICATIONS.identifier
				
			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 5140 THEN 'No complications'
						WHEN o.value_coded = 1653 THEN 'Oxytocin'
						WHEN o.value_coded = 1955 THEN 'Episiotomy on mother'
						WHEN o.value_coded = 5141 THEN 'Repair of tears'
						WHEN o.value_coded = 5142 THEN 'Manual removal of placenta'
						WHEN o.value_coded = 1963 THEN 'Delivery Note, Blood transfusion provided'
						WHEN o.value_coded = 5143 THEN 'AnitiD'
						WHEN o.value_coded = 5144 THEN 'IV fluids'
						WHEN o.value_coded = 5146 THEN 'Oxygen'
						WHEN o.value_coded = 5147 THEN 'Vacuum extraction'
						WHEN o.value_coded = 1033 THEN 'Other'
						WHEN o.value_coded = 5145 THEN 'Antibiotics'
						ELSE 'N/A'
					END AS 'intrapartum_inverventions' 

				from obs o
						-- Postpartum INTERVENTIONS
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5139 and o.value_coded IN 
												(
													5140, 1653, 1955, 5141, 5142,
													1963, 5143, 5144, 5145, 5146, 5147,1033  
												)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS INTRAPARTUM_INTERVENSIONS

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = INTRAPARTUM_INTERVENSIONS.identifier

			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_numeric < 2500 THEN 'weight < 2500g' 
						WHEN o.value_numeric >= 2500  THEN 'weight >= 2500g'
						ELSE 'N/A'
					END AS 'live_birth' 

				from obs o
						-- LIVE BIRTHS WEIGHT							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5247
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS LIVE_BIRHS_WEIGHT

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = LIVE_BIRHS_WEIGHT.identifier

			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 1033  THEN 'Other'
						WHEN o.value_coded = 1087 THEN 'Male' 
						WHEN o.value_coded = 1088  THEN 'Female'
						ELSE 'N/A'
					END AS 'child_sex' 

				from obs o
						-- CHILD SEX							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5236 and o.value_coded in (1087, 1088, 1033)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS CHILD_SEX

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = CHILD_SEX.identifier
			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 5153  THEN 'Live/Maternal Death'
						WHEN o.value_coded = 5154 THEN 'Fresh still birth' 
						WHEN o.value_coded = 5155  THEN 'Macerated still birth'
						ELSE 'N/A'
					END AS 'Death' 

				from obs o
						-- CHILD SEX							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5152 and o.value_coded in (5153, 5154, 5155)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS DEATH_DETAILS

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = DEATH_DETAILS.identifier
			
			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 4290  THEN 'Term'
						WHEN o.value_coded = 4289 THEN 'Preterm' 
						WHEN o.value_coded = 4291  THEN 'Post Term'
						ELSE 'N/A'
					END AS 'Newborth_Maturity' 

				from obs o
						-- NEWBORN MARTURITY							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5249 and o.value_coded in (4289, 4290, 4291)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS NEWBORN_MARURITY

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = NEWBORN_MARURITY.identifier
			
			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 5261  THEN 'No prophylaxis given'
						WHEN o.value_coded = 4261 THEN 'Nevirapine' 
						WHEN o.value_coded = 5262  THEN 'NVP and AZT'
						WHEN o.value_coded = 4321  THEN 'Declined'
						WHEN o.value_coded = 5263  THEN 'HIV Negative mother/baby died'
						ELSE 'N/A'
					END AS 'HIE_Prophylaxis' 

				from obs o
						-- HIV EXPOSURE							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5260 and o.value_coded in (5261, 4261, 4321, 5262, 5263)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS HIE_PROPHYLAXIS

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = HIE_PROPHYLAXIS.identifier
				
			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 4731  THEN 'Exclusice Breastfeeding'
						WHEN o.value_coded = 4732 THEN 'Exclusive Replacement Feeding' 
						WHEN o.value_coded = 4733  THEN 'Mixed Feeding'
						WHEN o.value_coded = 1975  THEN 'Not Applicable'
						ELSE 'N/A'
					END AS 'feeding_options' 

				from obs o
						-- INFANT FEEDING OPTIONS							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5276 and o.value_coded in (4731, 4732, 4733, 1975)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS FEEDING_OPTIONS

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = FEEDING_OPTIONS.identifier
			
			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 5282  THEN 'Within 1 hour'
						WHEN o.value_coded = 5284 THEN 'More than 1 hour' 
						WHEN o.value_coded = 1975  THEN 'Not Applicable'
						ELSE 'N/A'
					END AS 'feeding_initiation' 

				from obs o
						-- INFANT FEEDING 							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5280 and o.value_coded in (5282, 5284, 1975)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS FEEDING_INITIATION

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = FEEDING_INITIATION.identifier
				
			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 4454  THEN 'Polio(OPV)'
						WHEN o.value_coded = 4453 THEN 'BCG' 
						WHEN o.value_coded = 5160  THEN 'BCG and Polio 0'
						WHEN o.value_coded = 1975  THEN 'Not Applicable'
						ELSE 'N/A'
					END AS 'Immunization' 

				from obs o
						-- INFANT IMMUNIZATION							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5287 and o.value_coded in (4454, 4453, 5160, 1975)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS IMMUNIZATION

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = IMMUNIZATION.identifier
				
			LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 5327  THEN 'Alive'
						WHEN o.value_coded = 5328 THEN 'Near Miss' 
						WHEN o.value_coded = 3164  THEN 'Dead' 
						ELSE 'N/A'
					END AS 'baby_condition' 

				from obs o
						-- BABY CONDITIONS							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5326 and o.value_coded in (5327, 5328, 3164)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS BABY_CONDITION

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = BABY_CONDITION.identifier
		
		LEFT JOIN  			 
		
				(select distinct patient_identifier.identifier ,        
						CASE
						WHEN o.value_coded = 5327  THEN 'Alive'
						WHEN o.value_coded = 5328 THEN 'Near Miss' 
						WHEN o.value_coded = 3164  THEN 'Dead' 
						ELSE 'N/A'
					END AS 'mother_condition' 

				from obs o
						-- MOTHER CONDITIONS							
							INNER JOIN patient ON o.person_id = patient.patient_id 
							AND o.concept_id = 5330 and o.value_coded in (5327, 5328, 3164)
							AND patient.voided = 0 AND o.voided = 0
							AND CAST(o.obs_datetime AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(o.obs_datetime AS DATE) <= CAST('#endDate#' AS DATE)
					
							INNER JOIN person ON person.person_id = patient.patient_id AND person.voided = 0							
							INNER JOIN patient_identifier ON patient_identifier.patient_id = person.person_id AND patient_identifier.identifier_type = 3 AND patient_identifier.preferred=1							
							
				) AS MOTHER_CONDITION

				ON 	CLIENT_DELIVERY_MODE.Patient_Identifier = MOTHER_CONDITION.identifier
				
	)
