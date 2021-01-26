select
LOCATION_ID,
SKU_ID,
QTY_ON_HAND,
'<html><strong>'||TAG_ID||'</strong>' TAG
from V_INVENTORY where SKU_ID in ('2112','1435','2343') and regexp_like(LOCATION_ID,'^1\w\d\d\d\d\d\w')
order by location_id