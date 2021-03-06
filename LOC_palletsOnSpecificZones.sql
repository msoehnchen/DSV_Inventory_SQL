select 
    loc.LOCATION_ID,
    loc.ZONE_1,
    loc.SUBZONE_1,
    loc.SUBZONE_2,
    loc.CURRENT_VOLUME,
    loc.HEIGHT,
    loc.DEPTH,
    loc.WIDTH,
    loc.WEIGHT,
    loc.CURRENT_WEIGHT,
    inv.QTY_ON_HAND * sku.EACH_WEIGHT CALC_EACHES_WEIGHT,
    inv.TAG_ID,
    inv.SKU_ID,
    inv.PALLET_CONFIG,
    inv.QTY_ON_HAND,
    inv.QTY_ALLOCATED
from
(
    select LOCATION_ID, ZONE_1, SUBZONE_1, SUBZONE_2, CURRENT_VOLUME, HEIGHT, DEPTH, WIDTH, WEIGHT,CURRENT_WEIGHT 
    from V_location
    where SUBZONE_2 LIKE :SUBZONE2
    and SUBZONE_1 LIKE :SUBZONE1
) loc
LEFT JOIN
(
    select TAG_ID, CLIENT_ID, SKU_ID, PALLET_CONFIG, LOCATION_ID, QTY_ON_HAND, QTY_ALLOCATED, CONDITION_ID from V_INVENTORY
) inv
on loc.LOCATION_ID = inv.LOCATION_ID
LEFT JOIN
(
    select EACH_WEIGHT,SKU_ID from V_SKU
) sku
on inv.SKU_ID = sku.SKU_ID

order by loc.location_id, loc.current_weight, calc_eaches_weight
--order by inv.PALLET_CONFIG