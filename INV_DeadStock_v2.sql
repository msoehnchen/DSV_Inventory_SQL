select
    lastpick.LOCATION_ID,
    lastpick.TAG_ID,
    lastpick.SKU_ID,
    lastpick.DESCRIPTION,
    lastpick.CONDITION_ID,
    lastpick."LAST PICK DSTAMP",
    LASTPICK."LAST PICK EXCEL",
    LASTPICK.RECEIPT_DSTAMP "REC DSTAMP",
    lastpick.RECEIPT_DATE_EXCEL "REC EXCEL"
from (
    select
        inv.LOCATION_ID,
        inv.TAG_ID,
        inv.SKU_ID,
        inv.DESCRIPTION,
        INV.CONDITION_ID,
        INV.RECEIPT_DSTAMP,
        inv.RECEIPT_DATE_EXCEL,
        pick."LAST PICK DSTAMP",
        pick."LAST PICK EXCEL"
    from
    (
    select
        --LOCATION_ID,
        TAG_ID,
        SKU_ID,
        description,
        CONDITION_ID,
        RECEIPT_DSTAMP,
        to_number(substr(RECEIPT_DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) RECEIPT_DATE_EXCEL
    from V_INVENTORY
    where client_id = 'NLGLORY'
        and LOCATION_ID like '1%'
    ) inv
    left join
    (
        select max(CODE), max(CLIENT_ID),/*FROM_LOC_ID,*/ TAG_ID, SKU_ID, max(DSTAMP) "LAST PICK DSTAMP",to_number(substr(max(DSTAMP) - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) "LAST PICK EXCEL" from V_INVENTORY_TRANSACTION_ARC
        where CODE = 'Pick'
            and FROM_LOC_ID like '1%'
            and CLIENT_ID = 'NLGLORY'
        group by /*FROM_LOC_ID,*/ TAG_ID, SKU_ID 
    UNION all
        select max(CODE), max(CLIENT_ID),/*FROM_LOC_ID,*/ TAG_ID, SKU_ID, max(DSTAMP) "LAST PICK DSTAMP",to_number(substr(max(DSTAMP) - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) "LAST PICK EXCEL" from V_INVENTORY_TRANSACTION
        where CODE = 'Pick'
            and FROM_LOC_ID like '1%'
            and CLIENT_ID = 'NLGLORY'
        group by /*FROM_LOC_ID,*/ TAG_ID, SKU_ID 
    ) pick
    on inv.TAG_ID = pick.TAG_ID and inv.SKU_ID = pick.SKU_ID
    order by pick."LAST PICK DSTAMP" desc
) lastpick

;