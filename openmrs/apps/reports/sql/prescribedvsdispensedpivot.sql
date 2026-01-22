Select 
Location as "Location"
,Total_Clients_Prescribed "Clients Prescribed"
,Dispensed "Dispensed"
,Not_Dispensed "Not Dispensed"
,percentage_dispensed "Percentage Dispensed"
,percentage_not_dispensed "Percentage Not Dispensed"

FROM 
(
SELECT DISTINCT
	   Prescribed_vs_Dispensed.Location AS Location,
	   SUM(1) AS Total_Clients_Prescribed,   
	   SUM(CASE WHEN Status = 'Dispensed' THEN '1':: INT ELSE '0':: INT END) AS Dispensed,
	   SUM(CASE WHEN Status = 'Not Dispensed' THEN '1':: INT ELSE '0':: INT END) AS Not_Dispensed,
	   round((SUM(CASE WHEN Status = 'Dispensed' THEN '1'::INT ELSE '0'::INT END)::decimal/SUM(1)*100)) AS percentage_dispensed,
	   round((SUM(CASE WHEN Status = 'Not Dispensed' THEN '1':: INT ELSE '0'::INT END)::decimal/SUM(1)*100)) AS percentage_not_dispensed	  

	   
FROM
(
	SELECT DISTINCT
				name as Name
				,Gender.Sex as Gender 
				,Age.Age as Age
				,status as Status
				,Location

		FROM
		(

			SELECT DISTINCT
					prescribed.ID
					, prescribed.name
					,(CASE WHEN dispensed.id = prescribed.id THEN 'Dispensed'
              		ELSE 'Not Dispensed'
       				END) As status
					,prescribed.Location
			FROM
					((SELECT DISTINCT
							rp.id as ID, 
							rp.display_name As name,
							so.write_date,
							sl.name as Location

							from res_partner rp
							inner join sale_order so on so.partner_id = rp.id
							inner join stock_location sl on sl.id = so.location_id
							where CAST(so.write_date AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(so.write_date AS DATE) <= CAST('#endDate#' AS DATE)
							
							) prescribed

					LEFT JOIN 

					(Select distinct 
							rp.id ID,
							sm.state
							from res_partner rp
							inner join stock_move sm on sm.partner_id = rp.id
							where CAST(sm.write_date AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(sm.write_date AS DATE) <= CAST('#endDate#' AS DATE)
							AND sm.state = 'done'
							) dispensed
					
					ON prescribed.id = dispensed.id)			
					
		) AS APharmacyConsultation
		
		LEFT JOIN
			(
				Select rpa.value as Sex, rpa.partner_id as gID
				from res_partner_attributes rpa
				where rpa.name = 'Sex'
			)Gender
			ON Gender.gID = APharmacyConsultation.ID
		LEFT JOIN
		(
			Select rpa.value as Age, rpa.partner_id as aID
			from res_partner_attributes rpa
			where rpa.name = 'Age'
		)Age
		ON Age.aID = APharmacyConsultation.ID

	    GROUP BY APharmacyConsultation.id, Apharmacyconsultation.name, apharmacyconsultation.status, apharmacyconsultation.Location ,Gender.Sex, Age.Age 
		--HAVING APharmacyConsultation.status = 'Not Dispensed'





) AS Prescribed_vs_Dispensed
Group by Prescribed_vs_Dispensed.Location
) As Prescribed_Dispensed


UNION ALL

Select 
Location as "Location"
,Total_Clients_Prescribed "Total Clients Prescribed"
,Dispensed "Dispensed"
,Not_Dispensed "Not Dispensed"
,percentage_dispensed "Percentage Dispensed"
,percentage_not_dispensed "Percentage Not Dispensed"

FROM 
(
SELECT DISTINCT
	   'Total' AS Location,
	   SUM(1) AS Total_Clients_Prescribed,	   
	   SUM(CASE WHEN Status = 'Dispensed' THEN '1':: INT ELSE '0':: INT END) AS Dispensed,
	   SUM(CASE WHEN Status = 'Not Dispensed' THEN '1':: INT ELSE '0':: INT END) AS Not_Dispensed,
	   round((SUM(CASE WHEN Status = 'Dispensed' THEN '1'::INT ELSE '0'::INT END)::decimal/SUM(1))*100) AS percentage_dispensed,
	   round((SUM(CASE WHEN Status = 'Not Dispensed' THEN '1':: INT ELSE '0'::INT END)::decimal/SUM(1)*100)) AS percentage_not_dispensed	  
FROM
(

SELECT DISTINCT
				name as Name
				,Gender.Sex as Gender 
				,Age.Age as Age
				,status as Status
				,Location

		FROM
		(

			SELECT DISTINCT
					prescribed.ID
					, prescribed.name
					,(CASE WHEN dispensed.id = prescribed.id THEN 'Dispensed'
              		ELSE 'Not Dispensed'
       				END) As status
					, prescribed.Location
			FROM
					((SELECT DISTINCT
							rp.id as ID, 
							rp.display_name As name,
							so.write_date,
							sl.name as Location

							from res_partner rp
							inner join sale_order so on so.partner_id = rp.id
							inner join stock_location sl on sl.id = so.location_id
							where CAST(so.write_date AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(so.write_date AS DATE) <= CAST('#endDate#' AS DATE)
							
							) prescribed

					LEFT JOIN 

					(Select distinct 
							rp.id ID,
							sm.state
							from res_partner rp
							inner join stock_move sm on sm.partner_id = rp.id
							where CAST(sm.write_date AS DATE) >= CAST('#startDate#' AS DATE)
							AND CAST(sm.write_date AS DATE) <= CAST('#endDate#' AS DATE)
							AND sm.state = 'done'
							) dispensed
					
					ON prescribed.id = dispensed.id)			
					
		) AS APharmacyConsultation
		
		LEFT JOIN
			(
				Select rpa.value as Sex, rpa.partner_id as gID
				from res_partner_attributes rpa
				where rpa.name = 'Sex'
			)Gender
			ON Gender.gID = APharmacyConsultation.ID
		LEFT JOIN
		(
			Select rpa.value as Age, rpa.partner_id as aID
			from res_partner_attributes rpa
			where rpa.name = 'Age'
		)Age
		ON Age.aID = APharmacyConsultation.ID

	    GROUP BY APharmacyConsultation.id, Apharmacyconsultation.name, apharmacyconsultation.status,apharmacyconsultation.location, Gender.Sex, Age.Age
		--HAVING APharmacyConsultation.status = 'Not Dispensed'




) AS Prescribed_vs_Dispensed
)As Prescribed_Dispensed


