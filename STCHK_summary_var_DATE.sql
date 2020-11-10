select
CODE,
FROM_LOC_ID,
TO_LOC_ID,
FINAL_LOC_ID,
SKU_ID,
CONFIG_ID,
TAG_ID,
CONDITION_ID,
LIST_ID,
DSTAMP,
REASON_ID,
STATION_ID,
USER_ID,
UPDATE_QTY,
ORIGINAL_QTY,
ELAPSED_TIME,
PALLET_CONFIG,
RDT_USER_MODE    
    
from V_INVENTORY_TRANSACTION

where code = 'Stock Check'
and client_id = 'NLVESTAS'
and dstamp between to_timestamp(:FROMDATE,'DD/MM/YYYY') and to_timestamp(:TODATE,'DD/MM/YYYY')
and LIST_ID is not null
and RDT_USER_MODE = 'exstk'

UNION ALL

select
CODE,
FROM_LOC_ID,
TO_LOC_ID,
FINAL_LOC_ID,
SKU_ID,
CONFIG_ID,
TAG_ID,
CONDITION_ID,
LIST_ID,
DSTAMP,
REASON_ID,
STATION_ID,
USER_ID,
UPDATE_QTY,
ORIGINAL_QTY,
ELAPSED_TIME,
PALLET_CONFIG,
RDT_USER_MODE    
    
from V_INVENTORY_TRANSACTION_ARC

where code = 'Stock Check'
and client_id = 'NLVESTAS'
and dstamp between to_timestamp(:FROMDATE,'DD/MM/YYYY') and to_timestamp(:TODATE,'DD/MM/YYYY')
and LIST_ID is not null
and RDT_USER_MODE = 'exstk'