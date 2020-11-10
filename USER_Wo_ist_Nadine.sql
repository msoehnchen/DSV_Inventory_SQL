select 
concat(concat('Nadine war zuletzt bei ',FROM_LOC_ID),' beschaeftigt.') Antwort,
DSTAMP Zeit
from V_INVENTORY_TRANSACTION
where user_id = '75NAHO'
and TRUNC(DSTAMP) > SYSDATE - 1
and FROM_LOC_ID is not null
and Rownum <= 1
order by dstamp desc
