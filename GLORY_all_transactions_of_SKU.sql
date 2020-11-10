select 
 to_number(substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) EXCEL_DSTAMP,TO_CHAR(DSTAMP,'HH24:MI:SS') EXCEL_TIME,CODE, FROM_LOC_ID, TO_LOC_ID, FINAL_LOC_ID, SHIP_DOCK, CLIENT_ID, SKU_ID, ORIGINAL_QTY, UPDATE_QTY, TAG_ID, CONTAINER_ID, PALLET_ID, ORIGIN_ID, CONDITION_ID, LIST_ID, DSTAMP, WORK_GROUP, CONSIGNMENT, REFERENCE_ID, REASON_ID, USER_ID, NOTES, MASTER_PAH_ID
from V_INVENTORY_TRANSACTION it
where it.SKU_ID = :SKU
UNION ALL
select 
 to_number(substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) EXCEL_DSTAMP,TO_CHAR(DSTAMP,'HH24:MI:SS') EXCEL_TIME,CODE, FROM_LOC_ID, TO_LOC_ID, FINAL_LOC_ID, SHIP_DOCK, CLIENT_ID, SKU_ID, ORIGINAL_QTY, UPDATE_QTY, TAG_ID, CONTAINER_ID, PALLET_ID, ORIGIN_ID, CONDITION_ID, LIST_ID, DSTAMP, WORK_GROUP, CONSIGNMENT, REFERENCE_ID, REASON_ID, USER_ID, NOTES, MASTER_PAH_ID
from V_INVENTORY_TRANSACTION_ARC ita
where ita.SKU_ID = :SKU
order by DSTAMP