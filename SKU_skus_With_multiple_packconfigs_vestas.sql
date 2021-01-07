SELECT
    j3.client,
    j3.sku,
    j3.packconfig,
    COUNT(DISTINCT pre_advice) count_open_pa,
    MAX(packconf_from_preadvice) pconf_from_pa
FROM
    (
        SELECT
            j2.client,
            j2.sku,
            j2.packconfig,
            CASE
                    WHEN pah.status <> 'Complete' THEN pah.pre_advice_id
                    ELSE NULL
                END
            pre_advice,
            CASE
                    WHEN pah.status <> 'Complete' THEN j2.packconfig_from_preadvice
                    ELSE NULL
                END
            packconf_from_preadvice
        FROM
            (
                SELECT
                    s1.client_id client,
                    s1.sku_id sku,
                    sc2.config_id packconfig,
                    pal.pre_advice_id preadvice,
                    pal.config_id packconfig_from_preadvice
                FROM
                    (
                        SELECT
                            s.client_id,
                            s.sku_id,
                            COUNT(sc.config_id) num_configs
                        FROM
                            v_sku s
                            LEFT JOIN v_sku_sku_config sc ON s.client_id = sc.client_id
                                                             AND s.sku_id = sc.sku_id
                        WHERE
                            s.client_id IN (
                                'NLXEROX',
                                'NLFXG',
                                'NLHP',
                                'NLFFI'
                            )
                        GROUP BY
                            s.client_id,
                            s.sku_id
                    ) s1
                    LEFT JOIN v_sku_sku_config sc2 ON s1.client_id = sc2.client_id
                                                      AND s1.sku_id = sc2.sku_id
                    LEFT JOIN v_pre_advice_line pal ON s1.client_id = pal.client_id
                                                       AND s1.sku_id = pal.sku_id
                WHERE
                    s1.num_configs > 1
            ) j2
            LEFT JOIN v_pre_advice_header pah ON j2.preadvice = pah.pre_advice_id
        ORDER BY
            j2.client,
            j2.sku,
            j2.packconfig
    ) j3
GROUP BY
    j3.client,
    j3.sku,
    j3.packconfig
ORDER BY
    j3.client,
    j3.sku,
    j3.packconfig