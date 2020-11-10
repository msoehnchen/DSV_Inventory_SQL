/**
Query to check if ther are enough empty locations for current pallets on Inbound-Lane.
Tolerances for location sizes can be adjusted in row: 119,120 & 121
Special putawaygroups for groundlocations can be added in row: 123
**/

select -- FROM q2: here we sum the locations, and check if there are enough locations total
    q2.CLIENT_ID CLIENT,
    q2.SKU_ID SKU,
    q2.DESCRIPTION DESCRIPTION,
    q2.CONFIG_ID PACKCONF,
    q2.PALLET_CONFIG PALTYPE,
    q2.ceiled_width C_WIDTH,
    q2.ceiled_depth C_DEPTH,
    q2.ceiled_height C_HEIGHT,
    q2.putaway_group PG,
    q2.QTY_OF_TAGS TAGS,
    sum(q2.FREE_GROUNDLOCATIONS) GROUNDLOCS,
    sum(q2.FREE_HIGHLOCATIONS) HIGHLOCS,
    case
        when sum(q2.FREE_GROUNDLOCATIONS) + sum(q2.FREE_HIGHLOCATIONS) >= q2.QTY_OF_TAGS then 'OK'
        else 'NOT OK !!'
    end ENOUGH_LOCS
from
(
    select -- FROM Q: here we make extra columns for groundlocs and highlocs
        q.CLIENT_ID,
        q.SKU_ID,
        q.DESCRIPTION,
        q.CONFIG_ID,
        q.PALLET_CONFIG,
        q.ceiled_width,
        q.ceiled_depth,
        q.ceiled_height,
        q.putaway_group,
        q.QTY_OF_TAGS,
        case
            when q.levelofloc = 'GROUNDLEVEL' then q.total_locs
            else 0
        end FREE_GROUNDLOCATIONS,
        case
            when q.levelofloc = 'HIGHLEVEL' then q.total_locs
            else 0 
        end FREE_HIGHLOCATIONS
        --q.total_locs,
        --q.levelofloc
    
    from
    (
        select
            inv.CLIENT_ID,
            inv.SKU_ID,
            inv.DESCRIPTION,
            inv.CONFIG_ID,
            inv.PALLET_CONFIG,
            --pal.width,
            ceil(pal.width*10)/10 ceiled_width,
            --pal.depth,
            ceil(pal.depth*10)/10 ceiled_depth,
            --pal.height,
            ceil(pal.height*10)/10 ceiled_height,
            sku.putaway_group,
            inv.QTY_OF_TAGS,
            sum(loc.Num_of_locs) total_locs,
            loc.levelofloc
            --loc.subzone_1,
            --loc.zone_1
        FROM
        (
            select -- getting all items from INBOUND lanes
                CLIENT_ID, SKU_ID, DESCRIPTION, CONFIG_ID, PALLET_CONFIG,count(TAG_ID) QTY_OF_TAGS
            from V_INVENTORY
            where location_id like 'INB%'
            and not location_id like 'INB-BU%'
            group by CLIENT_ID, SKU_ID, DESCRIPTION, CONFIG_ID, PALLET_CONFIG
            order by CLIENT_ID, PALLET_CONFIG
        ) inv
        left join --merge with some sku-data
        (
        select
            CLIENT_ID, SKU_ID, PUTAWAY_GROUP
        from V_SKU
        ) sku
        on inv.CLIENT_ID = sku.CLIENT_ID and inv.SKU_ID = sku.SKU_ID
        left join --merge with some pallet-config-data
        (
        select
           CLIENT_ID, CONFIG_ID, HEIGHT, DEPTH, WIDTH, WEIGHT
        from V_PALLET_CONFIG
        ) pal
        on inv.client_id = pal.client_id and inv.pallet_config = pal.config_id
        left join -- merge with empty-location data
        (
        select -- getting empty locations and categorize in GROUND and HIGH level
            count(LOCATION_ID) Num_of_locs,
            case
                when substr(LOCATION_id,-1,1) = 'A' then 'GROUNDLEVEL'
                else 'HIGHLEVEL'
                end LEVELOFLOC,
            ZONE_1,
            SUBZONE_1,
            SUBZONE_2,
            --WORK_ZONE,
            --LOCK_STATUS,
            --CURRENT_VOLUME,
            --ALLOC_VOLUME,
            ceil(HEIGHT*10)/10 ceiled_height,
            ceil(DEPTH*10)/10 ceiled_depth,
            ceil(WIDTH*10)/10 ceiled_width
            --CURRENT_WEIGHT,
            --ALLOC_WEIGHT
        from V_location 
        where LOCK_STATUS = 'UnLocked' and length(location_id) = 8 and current_weight = 0 and alloc_weight = 0 and current_volume = 0 and alloc_volume = 0 and regexp_like(work_zone,'^30')
        group by Zone_1,substr(LOCATION_id,-1,1),Subzone_1,Subzone_2,ceil(HEIGHT*10)/10,ceil(DEPTH*10)/10,ceil(WIDTH*10)/10
        
        ) loc
        -- combining conditions: decoding storer for VMI, also set tolerances for location dimensions, so we should not get too many locations that are way to big
        on decode(inv.client_id,'NLFXG','NLXEROX','NLFFI','NLXEROX','NLXEROX','NLXEROX','NLHP','NLXEROX','NLNEDAP','NLNEDAP','NLVESTAS','NLVESTAS','NLGLORY','NLGLORY','NLZEON','NLZEON') = loc.subzone_2
            /** SETUP OF TOLERANCES AND SPECIAL PUTAWAY GROUPS **/
            and (ceil(pal.width*10)/10 between LOC.CEILED_WIDTH-0.2 and LOC.CEILED_WIDTH) --- standard: 0.2
            and (ceil(pal.depth*10)/10 between LOC.CEILED_depth-0.7 and LOC.CEILED_depth) --- standard: 0.7
            and (ceil(pal.height*10)/10 between LOC.CEILED_height-0.5 and LOC.CEILED_height) --- standard: 0.5
            and regexp_like(LOC.LEVELOFLOC,(CASE when sku.putaway_group in ('GROUND','VESTAS02G') then 'GROUNDLEVEL'
                                                else 'GROUNDLEVEL|HIGHLEVEL' end))
            
        group by
            inv.CLIENT_ID,
            inv.SKU_ID,
            inv.DESCRIPTION,
            inv.CONFIG_ID,
            inv.PALLET_CONFIG,
            --pal.width,
            ceil(pal.width*10)/10,
            --pal.depth,
            ceil(pal.depth*10)/10,
            --pal.height,
            ceil(pal.height*10)/10,
            sku.putaway_group,
            inv.QTY_OF_TAGS,
            loc.levelofloc
            --loc.Num_of_locs
            --loc.subzone_1,
            --loc.zone_1
           
        --order by inv.client_id, inv.sku_id
    ) q
)q2
group by
    q2.CLIENT_ID,
    q2.SKU_ID,
    q2.DESCRIPTION,
    q2.CONFIG_ID,
    q2.PALLET_CONFIG,
    q2.ceiled_width,
    q2.ceiled_depth,
    q2.ceiled_height,
    q2.putaway_group,
    q2.QTY_OF_TAGS
    
order by q2.client_id, q2.qty_of_tags
