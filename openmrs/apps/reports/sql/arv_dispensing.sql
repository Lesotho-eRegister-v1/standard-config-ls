select sm.name as Product_Description,pp.name as Pack_Size,sum(pp.qty) as Total_Pack_dispensed 
from stock_move sm
LEFT OUTER JOIN sale_order_line so ON sm.product_id = so.product_id
LEFT OUTER join product_packaging pp on so.product_packaging = pp.id  
WHERE sm.write_date >= CAST('2020-02-01' AS DATE)
AND sm.write_date <= CAST('2020-02-28' AS DATE)
AND so.state = 'sale'
AND sm.name in(
'Abacavir (ABC) 300mg',
'Abacavir/Lamivudine (ABC/3TC) - 600/300mg',
'Atazanavir (ATV) _300mg',
'Atazanavir/Ritonavir (ATV/RIV) - 300/100mg',
'Darunavir_(DVR)_300mg',
'Darunavir (DVR) - 600mg',
'Dolutegravir (DTG) - 50mg',
'Efavirenz (EFV) - 600mg',
'Etravirine (ETV) - 100mg',
'Lamivudine (3TC) - 150mg',
'Lopinavir/Ritonavir (LPV/r) - 200/50mg',
'Nevirapine (NVP) - 200mg',
'Raltegravir (RAL) - 400mg',
'Ritonavir (RIV) - 100mg',
'Tenofovir (TDF) - 300mg',
'Tenofovir/Lamivudine (TDF/3TC) - 300/300mg',
'Tenofovir/Lamivudine/Dolutegravir (TDF/3TC/DTG) - 300/300/50mg',
'Tenofovir/Lamivudine/Efavirenz (TDF/3TC/EFV) - 300/300/400mg',
'Tenofovir/Lamivudine/Efavirenz (TDF/3TC/EFV) - 300/300/600mg',
'Zidovudine (AZT) - 300mg',
'Zidovudine/Lamivudine (AZT/3TC)- 300/150mg',
'Zidovudine/Lamivudine/Nevirapine (AZT/3TC/NVP) - 300/150/200mg',
'Abacavir (ABC) - 60mg',
'Abacavir/lamivudine (ABC/3TC) - 120/60mg',
'Darunavir (DRV) - 75mg',
'Efavirenz (EFV) - 200mg',
'Lopinavir/Ritonavir (LPV/r) - 80mg/20ml',
'Lopinavir/Ritonavir (LPV/r) - 40/10mg',
'Lopinavir/Ritonavir (LPV/r) - 100/25mg ',
'Nevirapine (NVP) - 50mg/5ml',
'Raltegravir (RAL) - 100mg',
'Zidovudine/Lamivudine (AZT/3TC) - 60/30mg',
'Zidovudine/Lamivudine/Nevirapine (AZT/3TC/NVP) - 60/30/50mg')
group by sm.name,pp.name;