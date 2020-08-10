select 
    i.CLIENT_ID,
    i.SKU_ID,
    i.CONFIG_ID,
    i.PALLET_CONFIG,
    i.LOCATION_ID,
    i.ZONE_1,
    i.DESCRIPTION,
    --p.CLIENT_ID,
    --p.CONFIG_ID,
    p.WIDTH PALLET_WIDTH,
    p.DEPTH PALLET_DEPTH,
    p.HEIGHT PALLET_HEIGHT,
    p.WEIGHT PALLET_WEIGHT
from 
V_Inventory i,
V_Pallet_Config p
where i.client_id = p.client_id and i.pallet_config = p.config_id

