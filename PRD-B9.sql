select
its.CODE,
ITS.FROM_LOC_ID,
ITS.CLIENT_ID,
its.SKU_ID,
ITS.TAG_ID,
ITS.DSTAMP,
ITS.DATESTAMP,
its.UPDATE_QTY,
its.PALLET_CONFIG,
(sku.each_weight * its.update_qty)+pc.weight CACL_WEIGHT
from
(
    select
    IT.CODE, 
    IT.FROM_LOC_ID, 
    IT.CLIENT_ID, 
    IT.SKU_ID, 
    IT.TAG_ID, 
    IT.DSTAMP,
    TO_NUMBER(SUBSTR(IT.DSTAMP - TO_TIMESTAMP('01/01/1900','DD/MM/YYYY'),6,5)+2) DATESTAMP,
    IT.UPDATE_QTY,
    IT.PALLET_CONFIG
    from V_INVENTORY_TRANSACTION IT where DSTAMP between TO_TIMESTAMP('02/07/2020','DD/MM/YYYY') and TO_TIMESTAMP('01/01/2021','DD/MM/YYYY')
    and CLIENT_ID = 'NLZEON' and CODE = 'Receipt'
    and regexp_like(from_loc_id,'^INB')
    union all
    select
    IT.CODE, 
    IT.FROM_LOC_ID, 
    IT.CLIENT_ID, 
    IT.SKU_ID, 
    IT.TAG_ID, 
    IT.DSTAMP,
    TO_NUMBER(SUBSTR(IT.DSTAMP - TO_TIMESTAMP('01/01/1900','DD/MM/YYYY'),6,5)+2) DATESTAMP,
    IT.UPDATE_QTY,
    IT.PALLET_CONFIG
    from V_INVENTORY_TRANSACTION_ARC IT where DSTAMP between TO_TIMESTAMP('02/07/2020','DD/MM/YYYY') and TO_TIMESTAMP('01/01/2021','DD/MM/YYYY')
    and CLIENT_ID = 'NLZEON' and CODE = 'Receipt'
    and regexp_like(FROM_LOC_ID,'^INB')
    
)ITS
left join V_SKU SKU on ITS.SKU_ID = SKU.SKU_ID and ITS.CLIENT_ID = SKU.CLIENT_ID
left join V_PALLET_CONFIG pc on its.pallet_config = pc.config_id and its.client_id = pc.client_id