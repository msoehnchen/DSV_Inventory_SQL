select * from
(
    select
    i.CODE,
    i.FROM_LOC_ID,
    i.TO_LOC_ID,
    i.FINAL_LOC_ID,
    i.CLIENT_ID,
    i.SKU_ID,
    i.CONFIG_ID,
    i.PALLET_CONFIG,
    i.TAG_ID,
    i.CONDITION_ID,
    TO_CHAR(i.DSTAMP, 'DD-MON-YYYY HH24:MI:SS') DATESTAMP,
    to_number(substr(i.DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) XLS_DATE,
    i.USER_ID,
    i.UPDATE_QTY,
    i.ORIGINAL_QTY, 
    i.NOTES
    from v_inventory_transaction i
    where
        (
            (i.code = 'Adjustment')
            OR (i.code like ('%Update'))
            OR (i.code = 'Stock Check' and i.from_loc_id like ('INB%'))
        )
        and i.dstamp > Sysdate - 30 -- last 30 days
        and i.user_id <> 'Mvtcdae'
) upd
left JOIN
(
    select
--    i.CODE,
--    i.CLIENT_ID,
--    i.SKU_ID,
    i.CONFIG_ID,
    i.PALLET_CONFIG,
    i.TAG_ID,
    TO_CHAR(i.DSTAMP, 'DD-MON-YYYY HH24:MI:SS') RECEIVED_ON,
    to_number(substr(i.DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) RECEIVED_ON_XLS,
    i.USER_ID RECEIVED_BY

    from v_inventory_transaction i
    where i.code = 'Receipt'
 
) rec
on upd.TAG_ID = rec.TAG_ID