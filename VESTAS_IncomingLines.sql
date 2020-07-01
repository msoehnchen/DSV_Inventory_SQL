SELECT
    pah.client_id,
    pah.pre_advice_id,
    status,
    due_dstamp,
    excel_date,
    line_id,
    pal.sku_id,
    sku.putaway_group,
    pal.config_id,
    pal.qty_due,
    qty_perpallet,
    sumpallets,
    user_def_type_7,
    CASE
            WHEN user_def_type_7 IN (
                'CRATEK',
                'IBCK'
            ) THEN min_qtyperpallet * sku.each_weight + 70
            ELSE min_qtyperpallet * sku.each_weight + 25
        END
    palletweight,
    min_qtyperpallet,
    ceil(pal.qty_due / min_qtyperpallet) maxsumpallets
FROM
    (
        SELECT
            client_id,
            pre_advice_id,
            status,
            due_dstamp,
            to_number(substr(due_dstamp - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5) + 2) excel_date
        FROM
            v_pre_advice_header pa
        WHERE
            pa.client_id = 'NLVESTAS'
            AND   pa.status in ('Hold','In Progress','Released')
            AND   pa.due_dstamp >= to_timestamp(:begindate_as_dd_mm_yyyy,'DD/MM/YYYY')
           -- AND   pa.due_dstamp <= to_timestamp(:begindate_as_dd_mm_yyyy,'DD/MM/YYYY') + :NextXDays
                        
    ) pah
    LEFT JOIN (
        SELECT
            pre_advice_id,
            line_id,
            host_pre_advice_id,
            sku_id,
            config_id,
            qty_due,
            lpad(config_id,instr(config_id,'E1P') - 1) qty_perpallet,
            ceil(qty_due / lpad(config_id,instr(config_id,'E1P') - 1) ) sumpallets
        FROM
            v_pre_advice_line
        WHERE
            client_id = 'NLVESTAS'
    ) pal ON pal.pre_advice_id = pah.pre_advice_id
    LEFT JOIN (
        SELECT
            sku_id,
            each_weight,
            putaway_group,
            user_def_type_7
        FROM
            v_sku
        WHERE
            client_id = 'NLVESTAS'
    ) sku ON sku.sku_id = pal.sku_id
    LEFT JOIN (
        SELECT
            sku_id,
            MIN(lpad(config_id,instr(config_id,'E1P') - 1) ) min_qtyperpallet
        FROM
            v_sku_sku_config
        WHERE
            client_id = 'NLVESTAS'
        GROUP BY
            sku_id
    ) config ON pal.sku_id = config.sku_id
ORDER BY
    pah.due_dstamp