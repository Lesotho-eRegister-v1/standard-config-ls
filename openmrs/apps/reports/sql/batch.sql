
Select Patient_Name "Patient_Name", Sex "Sex", Age "Age", Description "Description", QTY "Quantity_Dispensed", lot_Name "Lot Number"
From
(Select distinct spo.write_date, so.write_date, rp.id as ID,rp.display_name as Patient_Name, sol.qty_delivered as QTY,
spl.id as lot_id, spl.name lot_Name, sol.name as Description
From stock_pack_operation spo
inner join Sale_order so on spo.write_date = so.write_date
inner join res_partner rp on rp.id = so.partner_id
inner join stock_pack_operation_lot spol on spol.operation_id = spo.id
inner join Stock_production_lot spl on spl.id = spol.lot_id
inner join Sale_order_line sol on sol.order_id = so.id
inner join Procurement_order po on po.sale_line_id = sol.id
WHERE so.state = 'sale'
AND po.state != 'cancel'
AND CAST(so.create_date AS DATE) >= CAST('#startDate#' AS DATE)
AND CAST(so.create_date AS DATE) <= CAST('#endDate#' AS DATE)
)AS prescriptions
LEFT JOIN
(
    Select rpa.value as Sex, rpa.partner_id as ID
    from res_partner_attributes rpa
    where rpa.name = 'Sex'
)Gender
ON Gender.ID = prescriptions.ID
LEFT JOIN
(
    Select rpa.value as Age, rpa.partner_id as ID
    from res_partner_attributes rpa
    where rpa.name = 'Age'
)Age
ON Age.ID = prescriptions.ID

