select
    BSTACKS."Location", 
    BSTACKS."Size", 
    BSTACKS."Empty", 
    BSTACKS."Unlocked", 
    BSTACKS."Inlocked", 
    BSTACKS."Outlocked", 
    BSTACKS."Locked", 
    BSTACKS.SKU_1, 
    BSTACKS.SKU_2, 
    BSTACKS.description, 
    BSTACKS.PALLETS, 
    BSTACKS."PALLETS allocated", 
    BSTACKS.PIECES, 
    BSTACKS."PIECES allocated",
    INCOMING.SUM_OF_TAGS "PLT INCOMING SKU1",
    INCOMING2.SUM_OF_TAGS "PLT INCOMING SKU2"
from
(
    select
        concat('''', LOC."Location") "Location",
        case
            when LOC."Location" in ('1B001','1B003','1B007','1B009','1B100','1B103','1B104','1B101','1B111') then 'L'
            when LOC."Location" in ('1B002','1B008','1B105','1B106','1B107','1B108') then 'M'
            when LOC."Location" in ('1B004','1B005','1B011','1B102') then 'XL'
            when LOC."Location" in ('1B006','1B010','1B109','1B110') then 'S'
            else 'other'
        end "Size",
        case
            when INV."QTY" is null and INV."QTY allocated" is null then '   yes'
            else ' '
        end "Empty",
    
        case
            when LOC."Status" = 'UnLocked' then '   x'
            else ' '
        end "Unlocked",
        case
            when LOC."Status" = 'InLocked' then '   x'
            else ' '
        end "Inlocked",
            case
            when LOC."Status" = 'OutLocked' then '   x'
            else ' '
        end "Outlocked",
        case
            when LOC."Status" = 'Locked' then '   x'
            else ' '
        end "Locked",
    
    --    CASE
    --     when inv."SKU 1" is null then ' '
    --     when inv."SKU 1" = inv."SKU 2" then inv."SKU 1"
    --     else inv."SKU 2" || '(' || inv."SKU 1" || ')'
    --    end "SKU(s)",
        INV."SKU 1" SKU_1,
        case
        when INV."SKU 2" = INV."SKU 1" then null
        else INV."SKU 2"
        end SKU_2,
        
        case
            when INV."DESCRIPTION" is null then ' '
            else INV."DESCRIPTION"
        end "DESCRIPTION",
        
        case
            when INV."Num of pallets" is null then ' '
            else TO_CHAR(INV."Num of pallets")
        end "PALLETS",
        
        case
            when ROUND(INV."QTY allocated" / ROUND(INV."QTY"/INV."Num of pallets",0),0) is null then ' '
            else TO_CHAR(ROUND(INV."QTY allocated" / ROUND(INV."QTY"/INV."Num of pallets",0),0))
        end "PALLETS allocated",
        
        case
            when INV."QTY" is null then ' '
            else TO_CHAR(INV."QTY")
        end "PIECES",
        
        case
            when INV."QTY allocated" is null then ' '
            else TO_CHAR(INV."QTY allocated")
        end "PIECES allocated"
    
    from
    (
        select
            LOCATION_ID "Location",
            --ZONE_1,
            LOCK_STATUS "Status"
            --VOLUME,
            --CURRENT_VOLUME,
            --ALLOC_VOLUME
        from V_LOCATION LOC
        
        where (regexp_like(LOC.LOCATION_ID,'^1(A|B|C|D|E|F|Q|S)') and length(LOC.LOCATION_ID) between 5 and 7)
        or (regexp_like(LOC.LOCATION_ID,'^BU') and length(LOC.LOCATION_ID) between 5 and 6)
    ) LOC
    left join
    (
        select
            LOCATION_ID,
            count(TAG_ID) "Num of pallets",
            --max(CLIENT_ID), min(CLIENT_ID),
            max(SKU_ID) "SKU 1",
            min(SKU_ID) "SKU 2",
            max(description) "DESCRIPTION",
            --max(CONFIG_ID),
            --max(PALLET_CONFIG),
            sum(QTY_ON_HAND) "QTY",
            sum(QTY_ALLOCATED) "QTY allocated"
        from V_INVENTORY INV
        
        where (regexp_like(INV.LOCATION_ID,'^1(A|B|C|D|E|F|Q|S)') and length(INV.LOCATION_ID) between 5 and 7)
        or (regexp_like(INV.LOCATION_ID,'^BU') and length(INV.LOCATION_ID) between 5 and 6)
    
        
        group by LOCATION_ID
    ) INV
    on LOC."Location" = INV.LOCATION_ID
) BSTACKS
left join
(
    select
    SWAPPED_SKU,
    sum(QTY_OF_TAGS) SUM_OF_TAGS
from
(
    select
        PAH.YARD_CONTAINER_ID YARD_OR_LANE,
        PAH.PRE_ADVICE_ID,
        PAH.OWNER_ID,
        PAH.STATUS,
        TO_CHAR(PAH.DUE_DSTAMP,'DD/MM/YYYY HH:MM:SS') DUE_DATE,
        PAL.SKU_ID INBOUND_SKU,
        VMI.TO_SKU_ID SWAPPED_SKU,
        PAL.QTY_DUE,
        CEIL(PAL.QTY_DUE / ( SUBSTR(PAL.CONFIG_ID,1, (length(PAL.CONFIG_ID) - 3) ) )) QTY_OF_TAGS,
        PAL.PALLET_CONFIG,
        s.description,
        s.USER_DEF_TYPE_7,
        s.NEW_PRODUCT,
        s.PUTAWAY_GROUP,
        PAL.CONFIG_ID
    from
        V_PRE_ADVICE_HEADER PAH
        join V_PRE_ADVICE_LINE PAL on PAH.PRE_ADVICE_ID = PAL.PRE_ADVICE_ID
        join V_SKU s on PAL.SKU_ID = s.SKU_ID
                        and PAL.CLIENT_ID = s.CLIENT_ID
        join V_VMI_SKU VMI on PAL.CLIENT_ID = VMI.FROM_CLIENT_ID
                              and PAL.SKU_ID = VMI.FROM_SKU_ID
    where
        PAH.CLIENT_ID not in (
            'NLNEWBAL',
            --'NLNEDAP',
            'NLGLORY',
            --'NLVESTAS',
            'NLBJC',
            'NLZEON'
        )
        and   PAH.STATUS not in (
            'Complete'
        )
        and   trunc(PAH.DUE_DSTAMP) > SYSDATE - 4
        and   trunc(PAH.DUE_DSTAMP) < SYSDATE + 4
    union all
    select
        INV.LOCATION_ID YARD_CONTAINER_ID,
        null PRE_ADVICE_ID,
        INV.CLIENT_ID OWNER_ID, --PAH.OWNER_ID,
        null STATUS,
        null DUE_DATE,
        INV.SKU_ID INBOUND_SKU,
        INV.SKU_ID SWAPPED_SKU,
        null QTY_DUE,
        INV.QTY_OF_TAGS QTY_OF_TAGS,
        INV.PALLET_CONFIG,
        INV.description,
        null USER_DEF_TYPE_7,
        null NEW_PRODUCT,
        SKU.PUTAWAY_GROUP,
        INV.CONFIG_ID
    from
        (
            select
                CLIENT_ID,
                SKU_ID,
                description,
                CONFIG_ID,
                PALLET_CONFIG,
                count(TAG_ID) QTY_OF_TAGS,
                LOCATION_ID
            from
                V_INVENTORY
            where
                LOCATION_ID like 'INB%'
                and   not LOCATION_ID like 'INB-BU%'
                and   CLIENT_ID not in (
                    'NLNEWBAL',
                    --'NLNEDAP',
                    'NLGLORY',
                    --'NLVESTAS',
                    'NLBJC',
                    'NLZEON'
                )
            group by
                CLIENT_ID,
                SKU_ID,
                description,
                CONFIG_ID,
                PALLET_CONFIG,
                LOCATION_ID
            order by
                CLIENT_ID,
                PALLET_CONFIG
        ) INV
        left join (
            select
                CLIENT_ID,
                SKU_ID,
                PUTAWAY_GROUP,
                V_SKU.EACH_WIDTH,
                V_SKU.EACH_DEPTH,
                V_SKU.EACH_HEIGHT
            from
                V_SKU
        ) SKU on INV.CLIENT_ID = SKU.CLIENT_ID
                 and INV.SKU_ID = SKU.SKU_ID

) INC
group by SWAPPED_SKU
) INCOMING
on  (BSTACKS.SKU_1 = INCOMING.SWAPPED_SKU )
left join
(
    select
    SWAPPED_SKU,
    sum(QTY_OF_TAGS) SUM_OF_TAGS
from
(
    select
        PAH.YARD_CONTAINER_ID YARD_OR_LANE,
        PAH.PRE_ADVICE_ID,
        PAH.OWNER_ID,
        PAH.STATUS,
        TO_CHAR(PAH.DUE_DSTAMP,'DD/MM/YYYY HH:MM:SS') DUE_DATE,
        PAL.SKU_ID INBOUND_SKU,
        VMI.TO_SKU_ID SWAPPED_SKU,
        PAL.QTY_DUE,
        CEIL(PAL.QTY_DUE / ( SUBSTR(PAL.CONFIG_ID,1, (length(PAL.CONFIG_ID) - 3) ) )) QTY_OF_TAGS,
        PAL.PALLET_CONFIG,
        s.description,
        s.USER_DEF_TYPE_7,
        s.NEW_PRODUCT,
        s.PUTAWAY_GROUP,
        PAL.CONFIG_ID
    from
        V_PRE_ADVICE_HEADER PAH
        join V_PRE_ADVICE_LINE PAL on PAH.PRE_ADVICE_ID = PAL.PRE_ADVICE_ID
        join V_SKU s on PAL.SKU_ID = s.SKU_ID
                        and PAL.CLIENT_ID = s.CLIENT_ID
        join V_VMI_SKU VMI on PAL.CLIENT_ID = VMI.FROM_CLIENT_ID
                              and PAL.SKU_ID = VMI.FROM_SKU_ID
    where
        PAH.CLIENT_ID not in (
            'NLNEWBAL',
            --'NLNEDAP',
            'NLGLORY',
            --'NLVESTAS',
            'NLBJC',
            'NLZEON'
        )
        and   PAH.STATUS not in (
            'Complete'
        )
        and   trunc(PAH.DUE_DSTAMP) > SYSDATE - 4
        and   trunc(PAH.DUE_DSTAMP) < SYSDATE + 4
    union all
    select
        INV.LOCATION_ID YARD_CONTAINER_ID,
        null PRE_ADVICE_ID,
        INV.CLIENT_ID OWNER_ID, --PAH.OWNER_ID,
        null STATUS,
        null DUE_DATE,
        INV.SKU_ID INBOUND_SKU,
        INV.SKU_ID SWAPPED_SKU,
        null QTY_DUE,
        INV.QTY_OF_TAGS QTY_OF_TAGS,
        INV.PALLET_CONFIG,
        INV.description,
        null USER_DEF_TYPE_7,
        null NEW_PRODUCT,
        SKU.PUTAWAY_GROUP,
        INV.CONFIG_ID
    from
        (
            select
                CLIENT_ID,
                SKU_ID,
                description,
                CONFIG_ID,
                PALLET_CONFIG,
                count(TAG_ID) QTY_OF_TAGS,
                LOCATION_ID
            from
                V_INVENTORY
            where
                LOCATION_ID like 'INB%'
                and   not LOCATION_ID like 'INB-BU%'
                and   CLIENT_ID not in (
                    'NLNEWBAL',
                    --'NLNEDAP',
                    'NLGLORY',
                    --'NLVESTAS',
                    'NLBJC',
                    'NLZEON'
                )
            group by
                CLIENT_ID,
                SKU_ID,
                description,
                CONFIG_ID,
                PALLET_CONFIG,
                LOCATION_ID
            order by
                CLIENT_ID,
                PALLET_CONFIG
        ) INV
        left join (
            select
                CLIENT_ID,
                SKU_ID,
                PUTAWAY_GROUP,
                V_SKU.EACH_WIDTH,
                V_SKU.EACH_DEPTH,
                V_SKU.EACH_HEIGHT
            from
                V_SKU
        ) SKU on INV.CLIENT_ID = SKU.CLIENT_ID
                 and INV.SKU_ID = SKU.SKU_ID

) INC
group by SWAPPED_SKU
) INCOMING2
on  (BSTACKS.SKU_2 = INCOMING2.SWAPPED_SKU)
--order by "Size"
order by BSTACKS."Location"
