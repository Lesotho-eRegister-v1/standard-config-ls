		SELECT DISTINCT
				name as "Patient Name"
				,Gender.Sex as "Sex" 
				,Age.Age as "Age"
				,status as "Status"
				,Location as "Location"

		FROM
		(

			SELECT DISTINCT
					prescribed.ID
					, prescribed.name
					,(CASE WHEN dispensed.id = prescribed.id THEN 'Dispensed'
              		ELSE 'Not Dispensed'
       				END) As status
					,Location
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

	    GROUP BY APharmacyConsultation.id, Apharmacyconsultation.name, apharmacyconsultation.status, Gender.Sex, Age.Age, apharmacyconsultation.location
		-- HAVING APharmacyConsultation.status = 'Dispensed'

