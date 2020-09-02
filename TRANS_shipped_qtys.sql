select
--vl.CODE,
--vl.FROM_LOC_ID,
--vl.TO_LOC_ID,
vl.CLIENT_ID,
vl.SKU_ID,
vl.CONFIG_ID,
--vl.FULL_PALLET_QTY,
vl.UPDATE_QTY,
case
    when vl.Update_qty >= vl.Full_pallet_qty then 1
    else 0    
end SHIP_FULL_PALLET,

--vl.TAG_ID,
vl.PALLET_ID,
vl.DSTAMP,
to_number(substr(vl.DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2) EXCELDATE,
vl.REFERENCE_ID
from
(
    select  
    it.CODE,
    it.FROM_LOC_ID,
    it.TO_LOC_ID,
    it.CLIENT_ID,
    it.SKU_ID,
    it.CONFIG_ID,
    
    case
        when it.client_id = 'NLGLORY' then SUBSTR(it.config_id,(INSTR(it.config_id,'P',1,1)+1),(INSTR(it.config_id,'E',1,1)-(INSTR(it.config_id,'P',1,1)+1)))
        else SUBSTR(it.CONFIG_ID,1,INSTR(it.Config_id,'E1P', 1, 1)-1) 
    end FULL_PALLET_QTY,
    
    it.UPDATE_QTY,
    it.TAG_ID,
    it.PALLET_ID,
    it.DSTAMP,
    it.REFERENCE_ID
    
    from V_INVENTORY_TRANSACTION it
    where
        (it.code = 'Vehicle Load')
        and it.sku_id <> 'PALLET'
) vl