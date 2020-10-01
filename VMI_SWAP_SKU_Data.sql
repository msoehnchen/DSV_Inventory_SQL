select
    q.CLIENT_VMI,
    q.CLIENT_XEROX,
    q.SKU_VMI,
    q.SKU_XEROX,
    q.QTY_VMI,
    q.QTY_XEROX,
    q.QTY_VMI + q.QTY_XEROX QTY_TOTAL,
    q.FROM_DESC,
    q.TO_DESC,
    q.FROM_WIDTH,
    q.TO_WIDTH,
    q.FROM_DEPTH,
    q.TO_DEPTH,
    q.FROM_HEIGHT,
    q.TO_HEIGHT,
    q.FROM_VOLUME,
    q.TO_VOLUME,
    q.FROM_WEIGHT,
    q.TO_WEIGHT,
    q.FROM_UDF7,
    q.TO_UDF7,
    q.WIDTH_DIFF,
    q.DEPTH_DIFF,
    q.HEIGHT_DIFF,
    q.WEIGHT_DIFF,
    q.VOLUME_DIFF,
    q.UDF7_DIFF,
    q.IS_DIFF
from
(
    select
        --invvmi."QTY VMI" + invxer."QTY XEROX" "TOTAL COMBI QTY",
        
        vmi.FROM_CLIENT_ID "CLIENT_VMI",
        vmi.FROM_SKU_ID "SKU_VMI",
        case
            when invvmi."QTY VMI" is null then 0
            else invvmi."QTY VMI"
        end "QTY_VMI",
        vmi.TO_CLIENT_ID "CLIENT_XEROX",
        vmi.TO_SKU_ID "SKU_XEROX",
        case
            when invxer."QTY XEROX" is null then 0
            else invxer."QTY XEROX"
        end "QTY_XEROX",
    
    --    sku.CLIENT_ID "FROM CLIENT",
    --    sku.SKU_ID "FROM SKU",
        sku.DESCRIPTION "FROM_DESC",
        sku.EACH_WIDTH "FROM_WIDTH",
        sku.EACH_DEPTH "FROM_DEPTH",
        sku.EACH_HEIGHT "FROM_HEIGHT",
        sku.EACH_WEIGHT "FROM_WEIGHT",
        sku.EACH_VOLUME "FROM_VOLUME",
        sku.USER_DEF_TYPE_7 "FROM_UDF7",
           
    --    skuto.CLIENT_ID "TO CLIENT",
    --    skuto.SKU_ID "TO SKU",
        skuto.DESCRIPTION "TO_DESC",
        skuto.EACH_WIDTH "TO_WIDTH",
        skuto.EACH_DEPTH "TO_DEPTH",
        skuto.EACH_HEIGHT "TO_HEIGHT",
        skuto.EACH_WEIGHT "TO_WEIGHT",
        skuto.EACH_VOLUME "TO_VOLUME",
        skuto.USER_DEF_TYPE_7 "TO_UDF7",
           
        skuto.EACH_WIDTH - SKU.EACH_WIDTH "WIDTH_DIFF",
        skuto.EACH_DEPTH - SKU.EACH_DEPTH "DEPTH_DIFF",
        skuto.EACH_HEIGHT - sku.EACH_HEIGHT "HEIGHT_DIFF",
        skuto.EACH_WEIGHT - sku.EACH_WEIGHT "WEIGHT_DIFF",
        skuto.EACH_VOLUME - sku.EACH_VOLUME "VOLUME_DIFF",
        case
            when skuto.user_def_type_7 = sku.user_def_type_7 then 0
            else 1
        end "UDF7_DIFF",
        
        (skuto.EACH_WIDTH - SKU.EACH_WIDTH) + (skuto.EACH_DEPTH - SKU.EACH_DEPTH) + (skuto.EACH_HEIGHT - sku.EACH_HEIGHT) + (skuto.EACH_WEIGHT - sku.EACH_WEIGHT) + (skuto.EACH_VOLUME - sku.EACH_VOLUME) "IS_DIFF"
        
    
    from
        (
        SELECT
           vmi.FROM_CLIENT_ID,
           vmi.FROM_SKU_ID,
           vmi.TO_CLIENT_ID,
           vmi.TO_SKU_ID
        FROM
            dsvview.v_vmi_sku vmi
        ) vmi
    left join
        (
        select
           sku.CLIENT_ID,
           sku.SKU_ID,
           sku.DESCRIPTION,
           sku.EACH_WIDTH,
           sku.EACH_DEPTH,
           sku.EACH_HEIGHT,
           sku.EACH_WEIGHT,
           sku.EACH_VOLUME,
           sku.USER_DEF_TYPE_7
        from dsvview.V_SKU sku
        where sku.client_id in ('NLXEROX','NLFXG','NLHP','NLFFI','NLVIS')
        ) sku
    on vmi.FROM_CLIENT_ID = sku.CLIENT_ID and vmi.FROM_SKU_ID = sku.SKU_ID
    left join
        (
        select
           skuto.CLIENT_ID,
           skuto.SKU_ID,
           skuto.DESCRIPTION,
           skuto.EACH_WIDTH,
           skuto.EACH_DEPTH,
           skuto.EACH_HEIGHT,
           skuto.EACH_WEIGHT,
           skuto.EACH_VOLUME,
           skuto.USER_DEF_TYPE_7
        from dsvview.V_SKU skuto
        where skuto.client_id in ('NLXEROX','NLFXG','NLHP','NLFFI','NLVIS')
        ) skuto
    on vmi.TO_CLIENT_ID = skuto.CLIENT_ID and vmi.TO_SKU_ID = skuto.SKU_ID
    left join
        (
        select
            invvmi.CLIENT_ID,
            invvmi.SKU_ID,
            sum(invvmi.QTY_ON_HAND) "QTY VMI"
        from V_INVENTORY invvmi
        where invvmi.client_id in ('NLFXG','NLHP','NLFFI','NLVIS')
        group by invvmi.CLIENT_ID,invvmi.SKU_ID
        ) invvmi
    on vmi.FROM_CLIENT_ID = invvmi.CLIENT_ID and vmi.FROM_SKU_ID = invvmi.SKU_ID
    left join
        (
        select
            invxer.CLIENT_ID,
            invxer.SKU_ID,
            sum(invxer.QTY_ON_HAND) "QTY XEROX"
        from V_INVENTORY invxer
        where invxer.client_id in ('NLXEROX')
        group by invxer.CLIENT_ID,invxer.SKU_ID
        ) invxer
    on vmi.TO_CLIENT_ID = invxer.CLIENT_ID and vmi.TO_SKU_ID = invxer.SKU_ID
) q

where IS_DIFF <> 0 and (q.QTY_VMI + q.QTY_XEROX) <> 0 --FILTERING JUST THE DIFFERENCES AND SKUS THAT ARE ACTUALLY IN STOCK

order by IS_DIFF desc