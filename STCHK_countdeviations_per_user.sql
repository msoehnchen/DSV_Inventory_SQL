/*
    Stock-Checks: Summary of count deviations per User
        set Users in line 49        
*/

select 
    sc2.user_id,
    sum(sc2."TOTAL") "Total Locations counted",
    sum(sc2."OK") "Loc qty same as CW",
    sum(sc2."afwijking") "Loc qty afwijking",
    concat(round(sum(sc2."afwijking")/sum(sc2."TOTAL") * 100,2),'%') "% afwijking"
    --sc2.client_id
from
(select 
    sc.user_id,
    count(sc.key) "TOTAL",
    case
        when sc.result = 'OK' then count(sc.key)
        else 0
    end "OK",
    case
        when sc.result = 'afwijking' then count(sc.key)
        else 0
    end "afwijking",
    sc.result,
    sc.client_id
    

from
(select
    it.key,
    it.FROM_LOC_ID,
    case
        when it.ORIGINAL_QTY is null then 0
        else it.original_qty
    end "ORIGINAL QTY",
    it.UPDATE_QTY,
    case
        when it.UPDATE_QTY <> 0 then 'afwijking'
        else 'OK'
    end "RESULT",
    it.user_id,
    it.sku_id,
    it.client_id
   
    
from V_INVENTORY_TRANSACTION it
where it.code = 'Stock Check'
and it.user_id in ('75MARI', '75GLRA', '75MAIT', '75PIBU')  -- SET Users here
and it.LIST_ID > 1000) sc
group by sc.user_id, sc.result, sc.client_id) sc2
group by sc2.user_id --,sc2.client_id
order by sc2.user_id--, sc2.client_id
