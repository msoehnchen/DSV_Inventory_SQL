select
CODE, FROM_LOC_ID, TO_LOC_ID, CLIENT_ID, SKU_ID, TAG_ID, CONDITION_ID, DSTAMP,to_number(substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) "Date (for Excel)", USER_ID
from V_INVENTORY_TRANSACTION
where code in ('Putaway','Relocate')
and CONDITION_ID = 'DM2'
and TO_LOC_ID = 'DAMAGE'