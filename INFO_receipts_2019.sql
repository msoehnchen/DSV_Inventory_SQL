/* INFO: received pallets inkl. PALLETTYPE, CATEGORY and WEIGHT */

select 
    it.CODE,
    it.dstamp,
    to_number(substr(it.DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) DATEVALUE,
    it.FROM_LOC_ID,
    it.TAG_ID,
    it.CLIENT_ID,
    it.SKU_ID,
    it.CONFIG_ID,
    
    it.UPDATE_QTY,
    it.PALLET_CONFIG,
    


    /* Dimensions per TAG en/of indeling in Categories */
    
    pal.WIDTH PAL_WIDTH,
    pal.DEPTH PAL_DEPTH,
    pal.HEIGHT PAL_HEIGHT,
    
    case
        when it.pallet_config like 'CRTN%' then 'CRTN'
        when (pal.width > 1.31 or pal.depth > 1.31) then 'XWF'
        when (pal.width > 0.8 and pal.depth < 1.21) then 'BLOK'
        when (pal.width > 0.81 and pal.depth > 1.21) then 'D-BLOK'
        when (pal.width < 0.81 and pal.depth < 1.21) then 'EURO'
        when (pal.width < 0.8 and pal.depth > 1.21) then 'D-EURO'
        else 'OTHER'
    end
    ||'-'||
    case
        when pal.HEIGHT < 0.51 then '050'
        when pal.HEIGHT < 1.01 then '100'
        when pal.HEIGHT < 1.51 then '150'
        when pal.HEIGHT < 1.81 then '180'
        when pal.HEIGHT < 2.51 then '250'
        else '300'
    end
    ||'-'||
        /* Gewicht per TAG berekenen en/of indeling in categories */
    

    case
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 35 then '35kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 100 then '100kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 300 then '300kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 600 then '600kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 900 then '900kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 1200 then '1200kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 1400 then '1400kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 1600 then '1600kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 1800 then '1800kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 2000 then '2000kg'
        else '2000+kg'
    end PALLET_CATEGORY,
     --sku.EACH_WEIGHT,
    pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) PAL_WEIGHT_REAL,
        case
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 35 then '35kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 100 then '100kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 300 then '300kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 600 then '600kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 900 then '900kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 1200 then '1200kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 1400 then '1400kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 1600 then '1600kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 1800 then '1800kg'
        when pal.WEIGHT + (it.UPDATE_QTY * sku.EACH_WEIGHT) <= 2000 then '2000kg'
        else '2000+kg'
    end WEIGHT_CATEGORY,
        case
        when it.pallet_config like 'CRTN%' then 'CRTN'
        when (pal.width > 1.31 or pal.depth > 1.31) then 'XWF'
        when (pal.width > 0.8 and pal.depth < 1.21) then 'BLOK'
        when (pal.width > 0.81 and pal.depth > 1.21) then 'D-BLOK'
        when (pal.width < 0.81 and pal.depth < 1.21) then 'EURO'
        when (pal.width < 0.8 and pal.depth > 1.21) then 'D-EURO'
        else 'OTHER'
    end
    ||'-'||
    case
        when pal.HEIGHT < 0.51 then '050'
        when pal.HEIGHT < 1.01 then '100'
        when pal.HEIGHT < 1.51 then '150'
        when pal.HEIGHT < 1.81 then '180'
        when pal.HEIGHT < 2.51 then '250'
        else '300'
    end DIMENSION_CATEGORY

from
    V_INVENTORY_TRANSACTION it, -- LAST 30 DAYS
--    V_INVENTORY_TRANSACTION_ARC it, -- Older than 90 DAYS
    V_SKU sku,
    V_PALLET_CONFIG pal
where it.code = 'Receipt'
and it.FROM_LOC_ID like 'INB%' --alleen receipts bij Inbound
and it.FROM_LOC_ID not like 'INB-DCC%'
and (it.sku_id = sku.sku_id and it.client_id = sku.client_id)
and (it.PALLET_CONFIG = pal.CONFIG_ID and it.client_id = pal.client_id)

/* Current Month for Transactions */
--and it.DSTAMP between TO_TIMESTAMP('01-'||TO_CHAR(sysdate, 'MM-YYYY'), 'DD-MM-YYYY') and LAST_DAY(sysdate)

/* Variable Date by MONTH and YEAR, for that particular month - used for Transaction-Archive */
--and it.DSTAMP between TO_TIMESTAMP('01-'||:MONTH||'-'||:YEAR, 'DD-MM-YYYY') and LAST_DAY(TO_TIMESTAMP('01-'||:MONTH||'-'||:YEAR, 'DD-MM-YYYY'))

/* FIXED Daterange - used for Transaction-Archive */
--and it.DSTAMP between TO_TIMESTAMP('01-06-2019', 'DD-MM-YYYY') and TO_TIMESTAMP('31-12-2019', 'DD-MM-YYYY')

/* Dates after specified date- used for Transaction-Archive */
--and it.DSTAMP > TO_TIMESTAMP('31-12-2019', 'DD-MM-YYYY')
