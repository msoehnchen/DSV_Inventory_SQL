select
    ';'||i.LOCATION_ID LOCATION,
    ';'||i.TAG_ID TAG,
    i.SKU_ID SKU,
    l.HEIGHT Location_height
from V_INVENTORY i, V_LOCATION l
where i.sku_id = :SKU
and i.location_id = l.LOCATION_id
and length(i.location_id) = 8