select
    itrec.TAG_ID,
    itrec.SKU_ID,
    itrec.DESCRIPTION,
    itrec.PUTAWAY_GROUP,
    itrec.EACH_WIDTH,
    itrec.EACH_DEPTH,
    itrec.EACH_HEIGHT,
    itrec.EACH_WEIGHT,
    itrec.WIDTH PAL_WIDTH,
    itrec.DEPTH PAL_DEPTH,
    itrec.HEIGHT PAL_HEIGHT,
    itrec.WEIGHT PAL_WEIGHT,
    itrec.CONFIG_ID,
    itrec.PALLET_CONFIG,
    itrec.TOTAL_WEIGHT,
    itrec.QTY_REC,
    trunc(itrec.DSTAMP_REC, 'DDD') DATE_REC,
    itpick.QTY_PICK,
    trunc(itpick.DSTAMP_PICK,'DDD') DATE_PICK,
    
    case
        when itrec.QTY_REC = itpick.QTY_PICK then 'FULL'
        when itpick.QTY_PICK is null then 'NOT PICKED'
        else 'PARTIAL'
    end FULL_PALLET_PICK,
    
    case
        when trunc(itpick.DSTAMP_PICK,'DDD') - trunc(itrec.DSTAMP_REC, 'DDD') is null then trunc(SYSDATE,'DDD') - trunc(itrec.DSTAMP_REC, 'DDD')
        else trunc(itpick.DSTAMP_PICK,'DDD') - trunc(itrec.DSTAMP_REC, 'DDD')
    end DAYS_IN_STOCK

   
    
from
(
    select
        it.CODE,
        it.CLIENT_ID,
        it.SKU_ID,
        sku.DESCRIPTION,
        sku.PUTAWAY_GROUP,
        it.CONFIG_ID,
        it.PALLET_CONFIG,
        it.TAG_ID,
        it.DSTAMP DSTAMP_REC,
        it.UPDATE_QTY QTY_REC,
        sku.EACH_WIDTH,
        sku.EACH_DEPTH,
        sku.EACH_HEIGHT,
        sku.EACH_WEIGHT,
        pal.WIDTH,
        pal.DEPTH,
        pal.HEIGHT,
        pal.WEIGHT,
        (it.UPDATE_QTY * sku.EACH_WEIGHT) + pal.WEIGHT TOTAL_WEIGHT
        
    from V_inventory_transaction it, V_SKU sku, V_PALLET_CONFIG pal
    where (it.CODE = 'Receipt' and it.client_id = 'NLVESTAS')
    and (it.client_id = sku.client_id and it.sku_id = sku.sku_id)
    and (it.client_id = pal.client_id and it.pallet_config = pal.config_id)
) itrec
left join
(
    select
        --it.CODE,
        --it.CLIENT_ID,
        --it.SKU_ID,
        --it.CONFIG_ID,
        itp.TAG_ID,
        itp.DSTAMP DSTAMP_PICK,
        itp.UPDATE_QTY QTY_PICK
    from V_inventory_transaction itp
    where (itp.CODE = 'Pick' and itp.client_id = 'NLVESTAS')
) itpick
on itrec.TAG_ID = itpick.TAG_ID
