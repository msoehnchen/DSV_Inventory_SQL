/*
    ZEON: batch updates of the last 3 months
*/

select *

from
(
select 
FROM_LOC_ID, SKU_ID, TAG_ID, BATCH_ID, substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5) "DSTAMP", USER_ID, NOTES, USER_DEF_NOTE_1, EXTRA_NOTES
from V_inventory_transaction

where code = 'Batch Update'
and CLIENT_ID = 'NLZEON'

order by dstamp
) it1
left join
(
select user_id "Receiving User",substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5) "Receive Date",tag_id
from V_inventory_transaction
where code = 'Receipt'
and client_id = 'NLZEON'
union all
select user_id "Receiving User",substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5) "Receive Date",tag_id
from V_INVENTORY_TRANSACTION_ARC
where code = 'Receipt'
and client_id = 'NLZEON'

) it2
on it1.tag_id = it2.tag_id
order by it1.dstamp
