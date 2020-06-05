select
    invvmi."QTY VMI" + invxer."QTY XEROX" "TOTAL COMBI QTY",
    
    vmi.FROM_CLIENT_ID "CLIENT VMI",
    vmi.FROM_SKU_ID "SKU VMI",
    invvmi."QTY VMI",
    vmi.TO_CLIENT_ID "CLIENT XEROX",
    vmi.TO_SKU_ID "SKU XEROX",
    invxer."QTY XEROX",

--    sku.CLIENT_ID "FROM CLIENT",
--    sku.SKU_ID "FROM SKU",
    sku.DESCRIPTION "FROM DESC",
    sku.EACH_WIDTH "FROM WIDTH",
    sku.EACH_DEPTH "FROM DEPTH",
    sku.EACH_HEIGHT "FROM HEIGHT",
    sku.EACH_WEIGHT "FROM WEIGHT",
    sku.EACH_VOLUME "FROM VOLUME",
    sku.USER_DEF_TYPE_7 "FROM UDF7",
       
--    skuto.CLIENT_ID "TO CLIENT",
--    skuto.SKU_ID "TO SKU",
    skuto.DESCRIPTION "TO DESC",
    skuto.EACH_WIDTH "TO WIDTH",
    skuto.EACH_DEPTH "TO DEPTH",
    skuto.EACH_HEIGHT "TO HEIGHT",
    skuto.EACH_WEIGHT "TO WEIGHT",
    skuto.EACH_VOLUME "TO VOLUME",
    skuto.USER_DEF_TYPE_7 "TO UDF7",
       
    skuto.EACH_WIDTH - SKU.EACH_WIDTH "WIDTH DIFF",
    skuto.EACH_DEPTH - SKU.EACH_DEPTH "DEPTH DIFF",
    skuto.EACH_HEIGHT - sku.EACH_HEIGHT "HEIGHT DIFF",
    skuto.EACH_WEIGHT - sku.EACH_WEIGHT "WEIGHT DIFF",
    skuto.EACH_VOLUME - sku.EACH_VOLUME "VOLUME DIFF",
    case
        when skuto.user_def_type_7 = sku.user_def_type_7 then 0
        else 1
    end "UDF7 DIFF",
    
    (skuto.EACH_WIDTH - SKU.EACH_WIDTH) + (skuto.EACH_DEPTH - SKU.EACH_DEPTH) + (skuto.EACH_HEIGHT - sku.EACH_HEIGHT) + (skuto.EACH_WEIGHT - sku.EACH_WEIGHT) + (skuto.EACH_VOLUME - sku.EACH_VOLUME) "IS DIFF?"
    

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