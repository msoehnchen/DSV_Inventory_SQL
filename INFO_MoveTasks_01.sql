select
TASK_TYPE,
DECODE(TASK_TYPE,'O','Order','R','Replenish','K','Kitting','P','Putaway','T','Marshal Header','M','Relocate') TT_NAME,
TASK_ID,
CLIENT_ID,
SKU_ID,
DESCRIPTION,
TAG_ID,
CONDITION_ID,
QTY_TO_MOVE,
OLD_QTY_TO_MOVE,
FROM_LOC_ID,
TO_LOC_ID,
FINAL_LOC_ID,
STATUS,
LIST_ID,
USER_ID,
DSTAMP,
START_DSTAMP,
FINISH_DSTAMP,
WORK_GROUP,
CONSIGNMENT,
TAG_ID,
CONTAINER_ID,
TO_CONTAINER_ID,
PALLET_ID,
TO_PALLET_ID,
PALLET_CONFIG,
OLD_STATUS,
STAGE_ROUTE_ID,
SERIAL_NUMBER,
LAST_RELEASED_DATE,
LAST_RELEASED_REASON_CODE,
LAST_RELEASED_USER
from 
DSVVIEW.V_MOVE_TASK
--where STATUS in ('Released','In Progress')
where TASK_TYPE = 'P'
;
