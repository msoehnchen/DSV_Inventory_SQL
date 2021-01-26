/* INV_Pickfaces_last_picks.sql
    Get the last picks and actual quantities of all pickfaces, if not longer than 3 months, otherwise mark them with "> 3 months".
    Field "LAST PICK DATEVALUE" is numeric to be changed to datatype DATE/SHORTDATE in excel afterwards. */       

select pf.CLIENT_ID, pf.SKU_ID, pf.LOCATION_ID, 
    case
        when it."LAST PICK" is null then '> 12 months'
        else TO_CHAR(it."LAST PICK", 'DD-MM-YYYY')
    end "LAST PICK",

    case
        when it."LAST PICK" is null then 1
        else to_number(substr(it."LAST PICK" - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2)
    end "LAST PICK DATEVALUE",

    inv.QTY_ON_HAND,
    it."NUMBER_OF_PICKS" "NUMBER_PICKS_LAST_30_DAYS"
from(
    select CLIENT_ID, SKU_ID, LOCATION_ID from V_PICK_FACE
    where (regexp_like(location_id,'^1C(07|08)\d\d\dAA') or regexp_like(location_id,'^1C(17|18)\d\d\dA')) -- LOCATIONS
) pf
left join
(
    select max(CODE), FROM_LOC_ID, CLIENT_ID, SKU_ID, max(DSTAMP) "LAST PICK", count(FROM_LOC_ID) "NUMBER_OF_PICKS" from V_INVENTORY_TRANSACTION
    where CODE = 'Pick'
        and (regexp_like(FROM_LOC_ID,'^1C(07|08)\d\d\dAA') or regexp_like(FROM_LOC_ID,'^1C(17|18)\d\d\dA')) -- LOCATIONS
        and client_id = 'NLVESTAS' -- client
    group by FROM_LOC_ID, CLIENT_ID, SKU_ID 
    union all
    select max(CODE), FROM_LOC_ID, CLIENT_ID, SKU_ID, max(DSTAMP) "LAST PICK", count(FROM_LOC_ID) "NUMBER_OF_PICKS" from V_INVENTORY_TRANSACTION_ARC where CODE = 'Pick' 
        and DSTAMP > SYSDATE - 365
        and (regexp_like(FROM_LOC_ID,'^1C(07|08)\d\d\dAA') or regexp_like(FROM_LOC_ID,'^1C(17|18)\d\d\dA')) -- LOCATIONS
        and client_id = 'NLVESTAS' -- client
    group by FROM_LOC_ID, CLIENT_ID, SKU_ID 
    
) it
on pf.CLIENT_ID = it.CLIENT_ID and pf.SKU_ID = it.SKU_ID and pf.LOCATION_ID = it.FROM_LOC_ID
left join
(
    select sum(i.QTY_ON_HAND) QTY_ON_HAND, i.LOCATION_ID, i.SKU_ID from V_Inventory i
    group by i.LOCATION_ID, i.SKU_ID
) inv
on pf.LOCATION_ID = inv.LOCATION_ID and pf.SKU_ID = inv.SKU_ID
order by pf.location_id;



