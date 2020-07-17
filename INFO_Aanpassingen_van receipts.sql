select
    upd.CODE,
    upd.DATE_OF_UPDATE,
    upd.TAG_ID,
    upd.FROM_LOC_ID,
    upd.CLIENT_ID,
    upd.SKU_ID,
    upd.UPDATE_QTY,
    upd.CONFIG_ID,
    upd.Pallet_CONFIG,
    upd.BATCH_ID,
    upd.UPDATED_BY,
    upd.NOTES,
    upd.EXTRA_NOTES,
    rec.RECEIVED_BY,
    rec.RECEIVED_DATE,
    rec.RECEIVED_CONFIG_ID,
    rec.RECEIVED_PALLET_CONFIG,
    rec.RECEIVED_BATCH_ID,
    rec.RECEIVED_NOTES,
    rec.RECEIVED_EXTRA_NOTES
from
(
    select 
    CODE,
    to_number(substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) DATE_OF_UPDATE,
    TAG_ID,
    FROM_LOC_ID,
    CLIENT_ID,
    SKU_ID,
    UPDATE_QTY,
    CONFIG_ID,
    Pallet_CONFIG,
    BATCH_ID,
    USER_ID UPDATED_BY,
    NOTES,
    EXTRA_NOTES
    from V_INVENTORY_TRANSACTION
    where code in ('Pallet Update','Batch Update', 'Config Update' )
) upd
left join
(
    select 
    CODE,
    to_number(substr(DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) RECEIVED_DATE,
    TAG_ID RECEIVED_TAG_ID,
    FROM_LOC_ID RECEIVED_FROM_LOC,
    CLIENT_ID RECEIVED_CLINET_ID,
    SKU_ID RECEIVED_SKU_ID,
    UPDATE_QTY RECEIVED_UPDATE_QTY,
    CONFIG_ID RECEIVED_CONFIG_ID,
    Pallet_CONFIG RECEIVED_PALLET_CONFIG,
    BATCH_ID RECEIVED_BATCH_ID,
    USER_ID RECEIVED_BY,
    NOTES RECEIVED_NOTES,
    EXTRA_NOTES RECEIVED_EXTRA_NOTES
    from V_INVENTORY_TRANSACTION where code = 'Receipt'
) rec
on upd.TAG_ID = rec.RECEIVED_TAG_ID and upd.SKU_ID = rec.RECEIVED_SKU_ID