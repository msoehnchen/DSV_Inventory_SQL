select
    inv.CLIENT_ID,
    inv.SKU_ID,
    inv.DESCRIPTION,
    inv.CONFIG_ID,
    inv.PALLET_CONFIG,
    sku.EACH_WIDTH, SKU.EACH_DEPTH, SKU.EACH_HEIGHT,
    sku.putaway_group,
    inv.QTY_OF_TAGS
FROM
(
    select
        CLIENT_ID, SKU_ID, DESCRIPTION, CONFIG_ID, PALLET_CONFIG,count(TAG_ID) QTY_OF_TAGS
    from V_INVENTORY
    where location_id like 'INB%'
    and not location_id like 'INB-BU%'
    group by CLIENT_ID, SKU_ID, DESCRIPTION, CONFIG_ID, PALLET_CONFIG
    order by CLIENT_ID, PALLET_CONFIG
) inv
left join
(
select
    CLIENT_ID, SKU_ID, PUTAWAY_GROUP, V_SKU.EACH_WIDTH, V_SKU.EACH_DEPTH, V_SKU.EACH_HEIGHT
from V_SKU
) sku
on inv.CLIENT_ID = sku.CLIENT_ID and inv.SKU_ID = sku.SKU_ID