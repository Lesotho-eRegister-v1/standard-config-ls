-- drug
SELECT sm.name  Drug,CAST(sum(sol.qty_delivered) AS INTEGER) "Units Dispensed this Month",-- CAST(sum(pol.qty_received) AS INTEGER) "Units Received this Month",
stock_on_hand as "Stock on hand"
FROM stock_move sm
LEFT OUTER JOIN sale_order_line sol ON  sm.product_id = sol.product_id AND sol.state = 'sale'
LEFT OUTER JOIN purchase_order_line pol ON sm.product_id = pol.product_id AND sol.state = 'purchase'
LEFT OUTER JOIN
-- stock on hand this month end
( SELECT qty stock_on_hand,a.product_id
    FROM stock_quant a
    INNER JOIN
    (SELECT product_id,CAST(MAX(write_date) AS TIMESTAMP) maxdate 
            FROM stock_quant 
            WHERE CAST(write_date AS TIMESTAMP) <= CAST('#endDate#' AS DATE)
            group by product_id 
            )latest 
            on latest.product_id = a.product_id
    WHERE CAST(a.write_date AS TIMESTAMP) = maxdate
    AND a.write_date >= CAST('#startDate#' AS DATE)
    AND a.write_date <= CAST('#endDate#' AS DATE)
)stock ON sm.product_id = stock.product_id
GROUP BY sm.name,stock_on_hand