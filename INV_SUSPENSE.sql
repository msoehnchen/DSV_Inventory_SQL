select 
client_id,
sku_id,
sum(QTY_ON_HAND) total_qty,
TO_CHAR(min(MOVE_DSTAMP),'YYYY-MM-DD') Movedate
from V_INVENTORY where location_id = 'SUSPENSE'
group by client_id, SKU_id
order by Movedate