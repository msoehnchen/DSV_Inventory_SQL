/*
    Shows all historical locations of a SKU
        variable :INPUT_SKU is filled
        during runtime. Locations DAMAGE and PROBLEM
        are filtered out.
        
        11/2019 marcel.sohnchen@nl.dsv.com        
*/

select
    it.SKU_ID,
    it.FROM_LOC_ID "historical location"
from V_INVENTORY_TRANSACTION it
where it.SKU_Id = :INPUT_SKU
and (it.from_loc_id like '1%' OR it.from_loc_id like 'BU%' OR it.from_loc_id in ('DAMAGE','PROBLEM'))
UNION
select
    it2.SKU_ID,
    it2.TO_LOC_ID
from V_INVENTORY_TRANSACTION it2
where it2.SKU_Id = :INPUT_SKU
and (it2.TO_LOC_ID like '1%'  OR it2.to_loc_id like 'BU%' OR it2.to_loc_id in ('DAMAGE','PROBLEM'))
order by 2
