select 
i.location_id,
i.TAG_ID,
i.SKU_ID,
i.BATCH_ID,
i.QTY_ON_HAND,
i.pallet_config,
(s.each_weight * qty_on_hand) + pc.weight CALC_WEIGHT
from V_INVENTORY i left join V_SKU s on i.SKU_ID = s.SKU_ID and s.CLIENT_ID = 'NLZEON'
left join V_PALLET_CONFIG PC on i.PALLET_CONFIG = PC.CONFIG_ID and PC.CLIENT_ID = 'NLZEON'
where i.CLIENT_ID = 'NLZEON'
and regexp_like(i.LOCATION_ID,'^1\w\d\d\d\d\d\w')
