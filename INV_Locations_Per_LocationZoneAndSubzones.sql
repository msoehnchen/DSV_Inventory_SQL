select lz.ZONE_1, lz.SUBZONE_1, lz.SUBZONE_2, loc.LOCCOUNT TOTAL_LOCS, loc.ISFULL,loc.ISEMPTY, loc.UNLOCKED,loc.INLOCKED,loc.OUTLOCKED,loc.LOCKED from
( select lz.ZONE_1, lz.SUBZONE_1, lz.SUBZONE_2 from V_LOCATION_ZONE lz ) lz
left join
(
    select
        count(LOCATION_ID) LOCCOUNT,
        ZONE_1,
        SUBZONE_1,
        SUBZONE_2,
        sum(UNLOCKED) UNLOCKED,
        sum(LOCKED) LOCKED,
        sum(INLOCKED) INLOCKED,
        sum(OUTLOCKED) OUTLOCKED,
        
        sum(ISFULL) ISFULL,
        sum(ISEMPTY) ISEMPTY
        
    from
    (
        select
            LOCATION_ID,
            ZONE_1,
            SUBZONE_1,
            SUBZONE_2,
            case
                when LOCK_STATUS = 'UnLocked' then 1
                else 0
            end UNLOCKED,
            case
                when LOCK_STATUS = 'InLocked' then 1
                else 0
            end INLOCKED,
            case
                when LOCK_STATUS = 'Locked' then 1
                else 0
            end LOCKED,
            case
                when LOCK_STATUS = 'OutLocked' then 1
                else 0
            end OUTLOCKED,
            case
                when CURRENT_VOLUME > 0 then 1
                else 0
            end ISFULL,
            case
                when CURRENT_VOLUME = 0 then 1
                else 0
            end ISEMPTY

        from V_LOCATION
    )
    group by ZONE_1, SUBZONE_1, SUBZONE_2
) loc
on lz.ZONE_1 = loc.ZONE_1 and lz.SUBZONE_1 = loc.SUBZONE_1 and lz.SUBZONE_2 = loc.SUBZONE_2
order by ZONE_1, SUBZONE_1, SUBZONE_2