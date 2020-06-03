select
    count(i1.TAG_ID) "Sum of TAGS",
    --i1.CLIENT_ID,
    --i1.SKU_ID,
    count(DISTINCT i1.LOCATION_ID) "Sum of LOCATIONS"
from (
    select 
        TAG_ID, CLIENT_ID, SKU_ID, PALLET_CONFIG, LOCATION_ID, QTY_ON_HAND, QTY_ALLOCATED, CONDITION_ID, DESCRIPTION
    
    from V_INVENTORY i
    where i.CLIENT_ID in ('NLFXG', 'NLHP', 'NLFFI', 'NLXEROX', 'NLVIS')
    and (
            i.LOCATION_ID like '1%'
            or
            i.LOCATION_ID like 'INB%'
            or
            i.LOCATION_ID in ('DAMAGE','PROBLEM','NOTOLOC','ENGRING')
            
        )   
    
    order by i.LOCATION_ID desc
    ) i1
    
--group by i1.CLIENT_ID