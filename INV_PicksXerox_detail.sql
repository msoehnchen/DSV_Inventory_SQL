select 
    to_number(substr(it.DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) DATEVALUE,
    it.FROM_LOC_ID,
    substr(it.from_loc_id,1,4) LOCATION_AISLE,
    substr(it.from_loc_id,8,LENGTH(it.from_loc_id)-7) LOCATION_LEVEL,
    it.TO_LOC_ID,
    it.SKU_ID,
    it.TAG_ID,
--    it.CONTAINER_ID,
--    it.REFERENCE_ID,
    it.PALLET_CONFIG,
    
    it.CONFIG_ID,    
    it.ORIGINAL_QTY,
    case
        when it.original_QTY >= to_number(SUBSTR(IT.CONFIG_id,1,LENGTH(it.config_id)-3)) then 'FULL'
        else 'PARTIAL'
    end PICKAMOUNT,
    
    case
        when loc.PICK_FACE = 'F' then 'FIXED'
        else 'no pickface'
    end PICK_FACE,
    loc.LOC_TYPE,
    sku.EACH_WIDTH,
    sku.EACH_DEPTH,
    sku.EACH_HEIGHT,
    sku.EACH_WEIGHT,
    sku.USER_DEF_TYPE_7,
    
    case
        when SKU.EACH_WEIGHT > 25 then 'YES'
        else 'NO'
    end ITEM_OVER_25KG,
    
    case
        when SKU.EACH_DEPTH > 0.6 or SKU.EACH_HEIGHT > 0.6 or SKU.EACH_WIDTH > 0.6 then 'YES'
        else 'NO'
    end ITEM_OVER_60CM
    
    
from V_inventory_transaction it
join V_location loc on it.from_loc_id = loc.location_id
join V_SKU sku on (it.SKU_ID = sku.SKU_id and it.client_id = sku.client_id)
where it.CLIENT_ID = 'NLXEROX'
--and it.FROM_LOC_ID not in ('1RVIRT1A')
--and it.FROM_LOC_ID not like ('1Q5%') 
--and it.FROM_LOC_ID not like ('%AA') 
--and it.FROM_LOC_ID not like ('%BB')
and it.config_id not in ('1E1P','2E1P','3E1P','4E1P','5E1P')
and it.CODE = 'Pick'
and trunc(it.DSTAMP) > sysdate - 3   -- last xx days
and REGEXP_LIKE(it.FROM_LOC_ID, '^1(A|B|C|D|E|F)')   -- regular locations
and not LENGTH(it.from_loc_ID) = 5   -- filter out Blockstacks, which have 5 chars
