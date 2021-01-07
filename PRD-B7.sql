select
INV.*,
I2.TAG_ID,
i2.SKU_ID,
i2.qty_on_hand

from
(
    select
    count(distinct i.SKU_ID) COUNT_SKUS,
    i.LOCATION_ID
    from V_INVENTORY i
    where i.client_id = 'NLNEDAP'
    group by i.LOCATION_ID
) INV
left join V_INVENTORY i2 on inv.location_id = i2.location_id
where INV.COUNT_SKUS > 1
and INV.LOCATION_ID <> '1RVIRT1A'
