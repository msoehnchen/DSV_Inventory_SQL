/** ---------------------------------------------------------------------
    --  Overview of Block-locations in B-hall                          --
		--    shows quantities and (multiple) partnummers on Blockstacks.  --
		--    Also categorizes them in different sizes.                    --
    --                                                                 --
    -- 03/01/2020 by marcel.soehnchen@nl.dsv.com                       --
    ---------------------------------------------------------------------
**/

select
    loc."Location",
    case
        when loc."Location" in ('1B001','1B003','1B007','1B009','1B100','1B103','1B104','1B101','1B111') then 'L'
        when loc."Location" in ('1B002','1B008','1B105','1B106','1B107','1B108') then 'M'
        when loc."Location" in ('1B004','1B005','1B011','1B102') then 'XL'
        when loc."Location" in ('1B006','1B010','1B109','1B110') then 'S'
        else 'other'
    end "Size",
    case
        when inv."QTY" is null and inv."QTY allocated" is null then 'yes'
        else ' '
    end "Empty?",

    case
        when loc."Status" = 'UnLocked' then '   x'
        else ' '
    end "Unlocked",
    case
        when loc."Status" = 'InLocked' then '   x'
        else ' '
    end "Inlocked",
        case
        when loc."Status" = 'OutLocked' then '   x'
        else ' '
    end "Outlocked",
    case
        when loc."Status" = 'Locked' then '   x'
        else ' '
    end "Locked",

    CASE
     when inv."SKU 1" is null then null
     when inv."SKU 1" = inv."SKU 2" then inv."SKU 1"
     else inv."SKU 2" || '(' || inv."SKU 1" || ')'
    end "SKU(s)",
    
    inv."Num of pallets" "PALLETS",
    round(inv."QTY allocated" / round(inv."QTY"/inv."Num of pallets",0),0) " PALLETS allocated",
    inv."QTY" "PIECES",
    inv."QTY allocated" "PIECES allocated"

from
(
    select
        LOCATION_ID "Location",
        --ZONE_1,
        LOCK_STATUS "Status"
        --VOLUME,
        --CURRENT_VOLUME,
        --ALLOC_VOLUME
    from V_location loc
    
    where loc.LOCATION_ID like '1B%'
    and loc.LOCATION_ID not like '1BLIJN%'
    and loc.zone_1 <> 'UNUSED'
) loc
left join
(
    select
        LOCATION_ID,
        count(TAG_ID) "Num of pallets",
        --max(CLIENT_ID), min(CLIENT_ID),
        max(SKU_ID) "SKU 1",
        min(SKU_ID) "SKU 2",
        --max(CONFIG_ID),
        --max(PALLET_CONFIG),
        sum(QTY_ON_HAND) "QTY",
        sum(QTY_ALLOCATED) "QTY allocated"
    from V_inventory inv
    
    where inv.LOCATION_ID like '1B%'
    and inv.LOCATION_ID not like '1BLIJN%'
    
    group by location_id
) inv
on loc."Location" = inv.location_id
--order by "Size"
order by loc."Location"
