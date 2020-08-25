SELECT
    pah.yard_container_id Yard_or_Lane,
    pah.pre_advice_id,
    pah.owner_id,
    pah.status,
    TO_CHAR(pah.due_dstamp,'DD/MM/YYYY HH:MM:SS') due_date,
    pal.sku_id inbound_sku,
    vmi.to_sku_id swapped_sku,
    pal.qty_due,
    CEIL(pal.qty_due / ( substr(pal.config_id,1, (length(pal.config_id) - 3) ) )) qty_of_tags,
    pal.pallet_config,
    s.description,
    s.user_def_type_7,
    s.new_product,
    s.putaway_group,
    pal.config_id
FROM
    v_pre_advice_header pah
    JOIN v_pre_advice_line pal ON pah.pre_advice_id = pal.pre_advice_id
    JOIN v_sku s ON pal.sku_id = s.sku_id
                    AND pal.client_id = s.client_id
    JOIN v_vmi_sku vmi ON pal.client_id = vmi.from_client_id
                          AND pal.sku_id = vmi.from_sku_id
WHERE
    pah.client_id NOT IN (
        'NLNEWBAL',
        'NLNEDAP',
        'NLGLORY',
        'NLVESTAS',
        'NLBJC',
        'NLZEON'
    )
    AND   pah.status NOT IN (
        'Complete'
    )
    AND   trunc(pah.due_dstamp) > SYSDATE - 4
    AND   trunc(pah.due_dstamp) < SYSDATE + 4
UNION ALL
SELECT
    inv.location_id yard_container_id,
    NULL pre_advice_id,
    inv.client_id owner_id, --PAH.OWNER_ID,
    NULL status,
    NULL due_date,
    inv.sku_id inbound_sku,
    inv.sku_id swapped_sku,
    NULL qty_due,
    inv.qty_of_tags qty_of_tags,
    inv.pallet_config,
    inv.description,
    NULL user_def_type_7,
    NULL new_product,
    sku.putaway_group,
    inv.config_id
FROM
    (
        SELECT
            client_id,
            sku_id,
            description,
            config_id,
            pallet_config,
            COUNT(tag_id) qty_of_tags,
            location_id
        FROM
            v_inventory
        WHERE
            location_id LIKE 'INB%'
            AND   NOT location_id LIKE 'INB-BU%'
            AND   client_id NOT IN (
                'NLNEWBAL',
                'NLNEDAP',
                'NLGLORY',
                'NLVESTAS',
                'NLBJC',
                'NLZEON'
            )
        GROUP BY
            client_id,
            sku_id,
            description,
            config_id,
            pallet_config,
            location_id
        ORDER BY
            client_id,
            pallet_config
    ) inv
    LEFT JOIN (
        SELECT
            client_id,
            sku_id,
            putaway_group,
            v_sku.each_width,
            v_sku.each_depth,
            v_sku.each_height
        FROM
            v_sku
    ) sku ON inv.client_id = sku.client_id
             AND inv.sku_id = sku.sku_id
ORDER BY
    owner_id,
    due_date,
    Yard_or_Lane;