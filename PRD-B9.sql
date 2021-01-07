select
CLIENT_ID,
TAG_ID,
SKU_ID,
description
CONFIG_ID,
PALLET_CONFIG,
QTY_ON_HAND,
case
    when QTY_ON_HAND < 0 then 'SURPLUS'
    else 'MISSING'
end STATUS,
CONDITION_ID,
TO_CHAR(COUNT_DSTAMP,'YYYY/MM/DD') DATE_COUNTED,
to_number(substr(to_char(sysdate - COUNT_DSTAMP),2,9))+1 DAYS_ON_SUSPENSE
from V_INVENTORY
where location_id = 'SUSPENSE'

order by DATE_COUNTED