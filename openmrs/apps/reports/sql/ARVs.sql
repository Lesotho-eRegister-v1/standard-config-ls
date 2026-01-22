Select Product_description "Product", Stock_on_hand "Stock on Hand", expiry.Expiry_Date as "Expiry Date",damaged.Quantity_expired_and_damaged as "Quantity Expired/Damaged"
From
    (select Id, name Product_description,sum(stock_on_hand) Stock_on_hand
        FROM
        (
            select distinct template.id as Id,SQuatity.qty stock_on_hand ,template.name
            FROM product_template template
            INNER JOIN stock_quant SQuatity on SQuatity.product_id = template.id
        AND CAST(SQuatity.write_date AS DATE) >= CAST('#startDate#' AS DATE)
        AND CAST(SQuatity.write_date AS DATE) <= CAST('#endDate#' AS DATE)
            ) product_name_quant
        Group by product_name_quant.name,product_name_quant.id) as stock_pro
        Left OUTER Join
        (select product_id,min(expiry_date) Expiry_Date
        FROM stock_pack_operation_lot sp
        inner join stock_pack_operation spo on spo.id = operation_id
        AND spo.write_date >= CAST('#startDate#' AS DATE)
        AND spo.write_date <= CAST('#endDate#' AS DATE)
        group by product_id
        )expiry ON stock_pro.Id = expiry.product_id
LEFT OUTER JOIN
( -- EXPIRED/DAMAGED
select product_id,Quantity_Expired Quantity_expired_and_damaged
FROM
(
    (
    select distinct sp.product_id,sum(qty) as Quantity_Expired
    from stock_pack_operation sp
    inner join stock_pack_operation_lot spo on sp.id = spo.operation_id AND expiry_date < CAST('#endDate#' AS DATE)
    AND sp.write_date >= CAST('#startDate#' AS DATE)
    AND sp.write_date <= CAST('#endDate#' AS DATE)
    group by sp.product_id
    )
UNION ALL
    (
    select distinct ss.product_id,sum(scrap_qty)
    from stock_pack_operation sp
    inner join stock_scrap ss on sp.product_id = ss.product_id
    AND sp.write_date >= CAST('#startDate#' AS DATE)
    AND sp.write_date <= CAST('#endDate#' AS DATE)
    GROUP BY ss.product_id
    )
)damaged

)damaged ON stock_pro.Id = damaged.product_id
















