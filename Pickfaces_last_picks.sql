select pf.CLIENT_ID, pf.SKU_ID, pf.LOCATION_ID, 
    case
        when it."LAST PICK" is null then '> 3 months'
        else TO_CHAR(it."LAST PICK", 'DD-MM-YYYY')
    end "LAST PICK"
from(
    select CLIENT_ID, SKU_ID, LOCATION_ID from V_PICK_FACE
) pf
left join
(
    select max(CODE), FROM_LOC_ID, CLIENT_ID, SKU_ID, max(DSTAMP) "LAST PICK" from V_inventory_transaction where CODE = 'Pick'
    group by FROM_LOC_ID, CLIENT_ID, SKU_ID 
) it
on pf.CLIENT_ID = it.CLIENT_ID and pf.SKU_ID = it.SKU_ID and pf.LOCATION_ID = it.FROM_LOC_ID
order by pf.location_id



