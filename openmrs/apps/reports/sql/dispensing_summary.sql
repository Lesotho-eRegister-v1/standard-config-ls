Select Batch.Product_ID, Product.Description, Batch.Lot, Batch.Done, Batch.Expiry_date
From
(Select Distinct sol.name Description, sol.product_id as ID
from sale_order_line sol
where sol.state = 'sale'
AND CAST(sol.create_date AS DATE) >= CAST('#startDate#' AS DATE)
AND CAST(sol.create_date AS DATE) <= CAST('#endDate#' AS DATE)) as Product
Left Join
(
Select Product_ID,Lot, Done, Expiry_date
From
(
SELECT DISTINCT sol.product_id as Product_ID,spo.lot_name as Lot, spo.expiry_date as Expiry_date,
sp.qty_done as Done
FROM sale_order_line sol
INNER JOIN stock_pack_operation sp ON sol.product_id = sp.product_id
INNER JOIN procurement_order po ON sol.id = po.sale_line_id
INNER JOIN stock_pack_operation_lot spo ON sp.id = spo.operation_id
WHERE sol.state = 'sale' and po.state ='done'
AND CAST(sol.create_date AS DATE) >= CAST('#startDate#' AS DATE)
AND CAST(sol.create_date AS DATE) <= CAST('#endDate#' AS DATE)
) as batch) as Batch
On Product.ID = Batch.Product_ID
WHERE Batch.Lot != ' '
Group by Product.ID, Batch.Product_ID, Product.Description, Batch.Lot, Batch.Done, Batch.Expiry_date






