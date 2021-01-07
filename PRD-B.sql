select
LOCATION_ID,
LOC_ID_EXCEL,
LOCK_STATUS,
FROM_CLIENT,
--AVG_QTY_PER_TAG,
FROM_SKU,
TO_CLIENT,
TO_SKU,
FROM_TAGS,
TO_TAGS,
CEIL(FROM_QTY / AVG_QTY_PER_TAG) FROM_PAL,
CEIL(TO_QTY / AVG_QTY_PER_TAG) TO_PAL,
CEIL(FROM_ALLOC / AVG_QTY_PER_TAG) FROM_PAL_ALLOC,
CEIL(TO_ALLOC / AVG_QTY_PER_TAG) TO_PAL_ALLOC,
CEIL(FROM_INC_SUM_QTY_DUE  / AVG_QTY_PER_TAG) FROM_PAL_INC,
ceil(TO_INC_SUM_QTY_DUE / AVG_QTY_PER_TAG) TO_PAL_INC,
FROM_INC_PGROUP,
TO_INC_PGROUP
from
(
    select
    
    LOCS.LOCATION_ID,
    LOCS.LOCK_STATUS,
    ''''||LOCS.LOCATION_ID LOC_ID_EXCEL,
    INV5.AVG_QTY_PER_TAG,
    INV5.FROM_CLIENT,
    INV5.FROM_SKU,
           
    INV5.TO_CLIENT,
    INV5.TO_SKU,
        
    INV5.FROM_TAGS,
    INV5.TO_TAGS,
    
    INV5.FROM_QTY,
    INV5.TO_QTY,
    
    INV5.FROM_ALLOC,
    INV5.TO_ALLOC,
    
    INV5.FROM_INC_SUM_QTY_DUE,
    INV5.TO_INC_SUM_QTY_DUE,
    
    INV5.FROM_INC_PGROUP,
    INV5.TO_INC_PGROUP
    
    --INV5.FROM_INC_UDF7
    --INV5.TO_INC_UDF7
    
    from
    (
        select
            location_id, lock_status
        from V_LOCATION where regexp_like(LOCATION_ID,'^1\w\d\d\d') and length(LOCATION_ID) between 5 and 7
    ) locs
    left join
    (
        select
            LOCATION_ID,
            AVG_QTY_PER_TAG,
            FROM_CLIENT,
            FROM_SKU,
            FROM_TAGS,
            FROM_QTY,
            FROM_ALLOC,
            FROM_INC_SUM_QTY_DUE,
            FROM_INC_PGROUP,
            FROM_INC_UDF7,
            FINAL_CLIENT TO_CLIENT,
            FINAL_SKU TO_SKU,
            FINAL_TAGS TO_TAGS,
            FINAL_QTY TO_QTY,
            FINAL_ALLOC TO_ALLOC,
            TO_INC_SUM_QTY_DUE,
            TO_INC_PGROUP,
            TO_INC_UDF7
        
            --FROM_INC_CLIENT,
            --FROM_INC_SKU,
            --TO_INC_CLIENT,
            --TO_INC_SKU,
        
        from
        (
            select
                LOCATION_ID,
                AVG_QTY_PER_TAG,
                --ACT_CLIENT,
                --ACT_SKU,
                --ACT_TAGS,
                --ACT_QTY,
                --ACT_ALLOC,
                FROM_CLIENT,
                FROM_SKU,
                FROM_TAGS,
                FROM_QTY,
                FROM_ALLOC,
                case
                    when TO_CLIENT is null then ACT_CLIENT
                    else TO_CLIENT
                end FINAL_CLIENT,
                --TO_CLIENT,
                case
                    when TO_SKU is null then ACT_SKU
                    else TO_SKU
                end FINAL_SKU,
                --TO_SKU,
                case
                    when TO_TAGS is null then ACT_TAGS
                    else TO_TAGS
                end FINAL_TAGS,    
                --TO_TAGS,
                case
                    when TO_QTY is null then ACT_QTY
                    else TO_QTY
                end FINAL_QTY,
                --TO_QTY,
                case
                    when TO_ALLOC is null then ACT_ALLOC
                    else TO_ALLOC
                end FINAL_ALLOC
                --TO_ALLOC
            from
            (
                select
                LOCATION_ID,
                max(CLIENT_ID) ACT_CLIENT,
                max(SKU_ID) ACT_SKU,
                sum(TAGS) ACT_TAGS,
                sum(QTY_TOTAL) ACT_QTY,
                sum(QTY_ALLOC) ACT_ALLOC,
                max(AVG_QTY_PER_TAG) AVG_QTY_PER_TAG,
                max(FROM_CLIENT_ID) FROM_CLIENT,
                max(FROM_SKU_ID) FROM_SKU,
                sum(FROM_TAGS) FROM_TAGS,
                sum(FROM_QTY) FROM_QTY,
                sum(FROM_ALLOC) FROM_ALLOC,
                max(TO_CLIENT_ID) TO_CLIENT,
                max(TO_SKU_ID) TO_SKU,
                sum(TO_TAGS) TO_TAGS,
                sum(TO_QTY) TO_QTY,
                sum(TO_ALLOC) TO_ALLOC 
                from
                (
                    select
                       LOCATION_ID, 
                       CLIENT_ID,
                       SKU_ID,
                       TAGS,
                       QTY_TOTAL,
                       QTY_ALLOC,
                       AVG_QTY_PER_TAG,
                       FROM_CLIENT_ID,
                       FROM_SKU_ID,
                       
                       case
                        when CLIENT_ID = FROM_CLIENT_ID then TAGS
                        else 0
                       end FROM_TAGS,
                
                       case
                        when CLIENT_ID = FROM_CLIENT_ID then QTY_TOTAL
                        else 0
                       end FROM_QTY,
                
                       case
                        when CLIENT_ID = FROM_CLIENT_ID then QTY_ALLOC
                        else 0
                       end FROM_ALLOC,
                
                       
                        TO_CLIENT_ID,
                       
                        TO_SKU_ID,
                
                        case
                            when CLIENT_ID = TO_CLIENT_ID then TAGS
                            when TO_CLIENT_ID is null then TAGS
                            else 0
                        end TO_TAGS,
                
                        case
                            when CLIENT_ID = TO_CLIENT_ID then QTY_TOTAL
                            when TO_CLIENT_ID is null then QTY_TOTAL
                            else 0
                        end TO_QTY,
                
                        case
                            when CLIENT_ID = TO_CLIENT_ID then QTY_ALLOC
                            when TO_CLIENT_ID is null then QTY_ALLOC
                            else 0
                        end TO_ALLOC
                
                    
                        
                    from
                        (
                        SELECT
                            inv.location_id,
                            inv.client_id,
                            INV.SKU_ID,
                            COUNT(inv.tag_id) tags,
                            SUM(inv.qty_on_hand) qty_total,
                            SUM(inv.qty_allocated) qty_alloc,
                            round(SUM(inv.qty_on_hand) / COUNT(inv.tag_id) ) avg_qty_per_tag
                        from
                            v_inventory inv
                        where
                            (REGEXP_LIKE( inv.location_id,'^1\w\d\d\d' ) and length(INV.LOCATION_ID) between 5 and 7)
                            
                        GROUP BY
                            inv.location_id,
                            inv.client_id,
                            INV.SKU_ID
                        ) INV1
                    left join
                        (
                        select
                            VMI.FROM_CLIENT_ID,
                            VMI.FROM_SKU_ID,
                            VMI.TO_CLIENT_ID,
                            VMI.TO_SKU_ID
                        from V_VMI_SKU VMI
                        ) VMI1
                    on (INV1.CLIENT_ID = VMI1.FROM_CLIENT_ID and INV1.SKU_ID = VMI1.FROM_SKU_ID) or (INV1.CLIENT_ID = VMI1.TO_CLIENT_ID and INV1.SKU_ID = VMI1.TO_SKU_ID)
                )INV2
                group by INV2.LOCATION_ID
            )INV3
        )INV4
        left join
        (
            select
            PAH.CLIENT_ID FROM_INC_CLIENT,
            --PAH.PRE_ADVICE_ID,
            --PAH.STATUS,
            --PAH.DUE_DSTAMP,
            PAL.SKU_ID FROM_INC_SKU,
            sum(PAL.QTY_DUE) FROM_INC_SUM_QTY_DUE,
            --SKU.description,
            max(SKU.PUTAWAY_GROUP) FROM_INC_PGROUP,
            max(SKU.USER_DEF_TYPE_7) FROM_INC_UDF7
        
            from V_PRE_ADVICE_HEADER PAH
            join V_PRE_ADVICE_LINE PAL on PAH.PRE_ADVICE_ID = PAL.PRE_ADVICE_ID
            join V_SKU SKU on (PAH.CLIENT_ID = SKU.CLIENT_ID and PAL.SKU_ID = SKU.SKU_ID)
            where (PAH.CLIENT_ID in ('NLXEROX','NLFXG','NLHP','NLVESTAS','NLNEDAP','NLFFI') and PAH.STATUS <> 'Complete' and PAH.DUE_DSTAMP between SYSDATE -4 and SYSDATE + 4)
            group by PAH.CLIENT_ID, PAL.SKU_ID
        ) INCFROM
        on INV4.FROM_CLIENT = INCFROM.FROM_INC_CLIENT and inv4.from_sku = INCFROM.FROM_INC_SKU
        left join
        (
            select
            PAH.CLIENT_ID TO_INC_CLIENT,
            --PAH.PRE_ADVICE_ID,
            --PAH.STATUS,
            --PAH.DUE_DSTAMP,
            PAL.SKU_ID TO_INC_SKU,
            sum(PAL.QTY_DUE) TO_INC_SUM_QTY_DUE,
            --SKU.description,
            max(SKU.PUTAWAY_GROUP) TO_INC_PGROUP,
            max(SKU.USER_DEF_TYPE_7) TO_INC_UDF7
        
            from V_PRE_ADVICE_HEADER PAH
            join V_PRE_ADVICE_LINE PAL on PAH.PRE_ADVICE_ID = PAL.PRE_ADVICE_ID
            join V_SKU SKU on (PAH.CLIENT_ID = SKU.CLIENT_ID and PAL.SKU_ID = SKU.SKU_ID)
            where (PAH.CLIENT_ID in ('NLXEROX','NLFXG','NLHP','NLVESTAS','NLNEDAP','NLFFI') and PAH.STATUS <> 'Complete' and PAH.DUE_DSTAMP between SYSDATE -4 and SYSDATE + 4)
            group by PAH.CLIENT_ID, PAL.SKU_ID
        ) INCTO
        on INV4.FINAL_CLIENT = INCTO.TO_INC_CLIENT and INV4.FINAL_SKU = INCTO.TO_INC_SKU
    )INV5
    on LOCS.LOCATION_ID = INV5.LOCATION_ID
) I6
--order by location_id