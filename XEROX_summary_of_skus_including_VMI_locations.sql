select 
    sku.SKU_ID,
    sku.CLIENT_ID,
    
    nvl(invvmi.LOC_TOTAL,0) + nvl(invxer.LOC_TOTAL,0) COMB_LOCATIONS_TOTAL, 
    nvl(pface.LOCATION_ID,'NO PICKFACE') PICKFACE_ID,
    pface.TRIGGER_QTY,
    
    
    vmidata.FROM_CLIENT_ID,
    vmidata.FROM_SKU_ID,
    sku.DESCRIPTION,
    sku.PRODUCT_GROUP,
    sku.EACH_WIDTH,
    sku.EACH_DEPTH,
    sku.EACH_HEIGHT,
    sku.EACH_WEIGHT,
    sku.EACH_VOLUME,
    sku.USER_DEF_TYPE_7,

    
    nvl(invvmi.PLTS_TOTAL,0) + nvl(invxer.PLTS_TOTAL,0) COMB_PALLETS_TOTAL, 
    nvl(invvmi.QTY_TOTAL,0) + nvl(invxer.QTY_TOTAL,0) COMB_QTY_TOTAL, 

    invvmi.PACKCONFIG VMI_PACKCONFIG, 
    invvmi.LOC_TOTAL VMI_LOC_TOTAL, 
    invvmi.PLTS_TOTAL VMI_PLTS_TOTAL, 
    invvmi.QTY_TOTAL VMI_QTY_TOTAL, 
    invvmi.QTY_AVG_PER_LOC VMI_QTY_AVG_PER_LOC,

    invxer.PACKCONFIG XER_PACKCONFIG, 
    invxer.LOC_TOTAL XER_LOC_TOTAL, 
    invxer.PLTS_TOTAL XER_PLTS_TOTAL, 
    invxer.QTY_TOTAL XER_QTY_TOTAL, 
    invxer.QTY_AVG_PER_LOC XER_QTY_AVG_PER_LOC

from
(
    select
        s.CLIENT_ID,
        s.SKU_ID,
        s.DESCRIPTION,
        s.PRODUCT_GROUP,
        s.EACH_WIDTH,
        s.EACH_DEPTH,
        s.EACH_HEIGHT,
        s.EACH_WEIGHT,
        s.EACH_VOLUME,
        s.USER_DEF_TYPE_7
    from V_SKU s
    where s.client_id = 'NLXEROX'
) sku
left join
(
    select
    m.TO_CLIENT_ID,
    m.TO_SKU_ID,
    m.FROM_CLIENT_ID,
    m.FROM_SKU_ID

    from V_VMI_SKU m
) vmidata
on (sku.client_id = vmidata.to_client_id and sku.sku_id = vmidata.to_sku_id)
left join
(
    select
        p.LOCATION_ID,
        p.TRIGGER_QTY,
        p.client_id,
        p.sku_id
    from V_PICK_FACE p
) pface
on (sku.client_id = pface.client_id and sku.sku_id = pface.sku_id)
left join
(
    select
        s.CLIENT_ID,
        s.SKU_ID,
        m.FROM_CLIENT_ID,
        m.FROM_SKU_ID,
        case
            when count(distinct i.CONFIG_ID) > 1 then 'MULTIPLE'
            else max(i.CONFIG_ID)
        end PACKCONFIG,
        count(DISTINCT i.LOCATION_ID) LOC_TOTAL,
        count(DISTINCT i.TAG_ID) PLTS_TOTAL,
        sum(i.QTY_ON_HAND) QTY_TOTAL,
        round(avg(i.QTY_ON_HAND),0) QTY_AVG_PER_LOC
    from V_SKU s, V_VMI_SKU m, V_INVENTORY i
    where s.client_id = 'NLXEROX'
        and i.location_id like ('1%')
        and (s.client_id = m.TO_CLIENT_ID and s.sku_id = m.TO_SKU_ID)
        and (m.FROM_client_id = i.client_id and m.FROM_sku_id = i.SKU_ID)
    group by 
        s.CLIENT_ID,
        s.SKU_ID,
        m.FROM_CLIENT_ID,
        m.FROM_SKU_ID,
        i.CONFIG_ID
) invvmi
on (sku.client_id = invvmi.from_client_id and sku.sku_id = invvmi.from_sku_id)
left join
(
    select
        I.CLIENT_ID,
        i.SKU_ID,
        case
            when count(distinct i.CONFIG_ID) > 1 then 'MULTIPLE'
            else max(i.CONFIG_ID)
        end PACKCONFIG,
        count(DISTINCT i.LOCATION_ID) LOC_TOTAL,
        count(DISTINCT i.TAG_ID) PLTS_TOTAL,
        sum(i.QTY_ON_HAND) QTY_TOTAL,
        round(avg(i.QTY_ON_HAND),0) QTY_AVG_PER_LOC
    from V_INVENTORY i
    where i.client_id = 'NLXEROX'
    and i.location_id like ('1%')
    group by 
        i.CLIENT_ID,
        i.SKU_ID,
        i.CONFIG_ID
) invxer
on sku.client_id = invxer.client_id and sku.sku_id = invxer.sku_id
