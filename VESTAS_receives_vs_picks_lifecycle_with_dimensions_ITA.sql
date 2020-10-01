select
    itrec.TAG_ID "TAG",
    itrec.REFERENCE_ID "INBOUND REF",
    itrec.SKU_ID "SKU",
    itrec.DESCRIPTION,
    case
        when itrec.PUTAWAY_GROUP like ('BU%') then 'VESTAS03'
        else itrec.PUTAWAY_GROUP
    end "PUTAWAY GROUP",
    
    itrec.EACH_WIDTH "EACH WIDTH",
    itrec.EACH_DEPTH "EACH DEPTH",
    itrec.EACH_HEIGHT "EACH HEIGHT",
    itrec.EACH_WEIGHT "EACH WEIGHT",
    itrec.WIDTH "PALLET WIDTH",
    itrec.DEPTH "PALLET DEPTH",
    itrec.HEIGHT "PALLET HEIGHT",
    itrec.WEIGHT "PALLET WEIGHT",
    itrec.CONFIG_ID "PACK CONFIG",
    itrec.PALLET_CONFIG "PALLET TYPE",
    itrec.TOTAL_WEIGHT "WEIGHT OF TOTAL PALLET",
    itrec.QTY_REC "QTY RECEIVED",
    itpick.REFERENCE_ID "OUTBOUND REF",
    trunc(itrec.DSTAMP_REC, 'DDD') "DATE RECEIVED",
    itpick.QTY_PICK "QTY PICKED",
    trunc(itpick.DSTAMP_PICK,'DDD') "DATE PICKED",
    
    case
        when itrec.QTY_REC = itpick.QTY_PICK then 'FULL'
        when itpick.QTY_PICK is null then 'NOT PICKED'
        else 'PARTIAL'
    end "TYPE OF PICK",
    
    case
        when trunc(itpick.DSTAMP_PICK,'DDD') - trunc(itrec.DSTAMP_REC, 'DDD') is null then trunc(SYSDATE,'DDD') - trunc(itrec.DSTAMP_REC, 'DDD')
        else trunc(itpick.DSTAMP_PICK,'DDD') - trunc(itrec.DSTAMP_REC, 'DDD')
    end "DAYS FROM REC TO PICK"

   
    
from
(
    select
        it.CODE,
        it.CLIENT_ID,
        it.REFERENCE_ID,
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
        
    from V_inventory_transaction_arc it, V_SKU sku, V_PALLET_CONFIG pal
    where (it.DSTAMP between TO_TIMESTAMP('01/06/2019', 'DD/MM/YYYY') and TO_TIMESTAMP('31/07/2020', 'DD/MM/YYYY')) 
    and (it.CODE = 'Receipt' and it.client_id = 'NLVESTAS')
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
        itp.REFERENCE_ID,
        itp.TAG_ID,
        itp.DSTAMP DSTAMP_PICK,
        itp.UPDATE_QTY QTY_PICK
    from V_inventory_transaction_arc itp
    where (itp.CODE = 'Shipment' and itp.client_id = 'NLVESTAS')
) itpick
on itrec.TAG_ID = itpick.TAG_ID

