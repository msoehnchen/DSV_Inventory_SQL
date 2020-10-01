/*
    Shows all historical locations of a SKU in the last 60 days
    
    variable :INPUT_SKU is filled during runtime.
    Locations DAMAGE and PROBLEM are filtered out.
*/

select
    it.SKU_ID,
    it.FROM_LOC_ID "historical location"
from V_INVENTORY_TRANSACTION it
where it.SKU_Id = :INPUT_SKU
and (it.from_loc_id like '1%' OR it.from_loc_id like 'BU%' OR it.from_loc_id in ('DAMAGE','PROBLEM'))
and it.DSTAMP > sysdate - 60
group by it.SKU_ID, it.FROM_LOC_ID
order by it.loc_id