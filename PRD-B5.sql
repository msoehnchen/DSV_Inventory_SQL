select
TO_CHAR(DSTAMP,'IW') WEEKSTAMP,
CODE,
--CLIENT_ID,
case
    when CODE = 'Shipment' then count(distinct PALLET_ID)
    when CODE = 'Receipt' then count(TAG_ID)
end COUNT_OF_TASKS_OR_PALLETS

from V_INVENTORY_TRANSACTION

where (CODE = 'Shipment')
    or (CODE = 'Receipt')
    --or (CODE = 'Pick' and TO_LOC_ID = 'CONTAINER')

group by 
CODE,
--CLIENT_ID,
TO_CHAR(DSTAMP,'IW')

order by WEEKSTAMP
