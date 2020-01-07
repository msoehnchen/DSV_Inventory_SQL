/**
    STOCK-CHECKS: Summary per client (varaiable period)
        begin end end dates filled during runtime.
**/


select
    t1.*
    
    /** commented out, because of pivoting issues in excel....
    round(
        case
        when t1."MISSING" > 0 then t1."MISSING" / t1."TOTAL ORIGINAL"
        else 0
        end
    ,3) "clc. %missing",

    round(
        case
        when t1."SURPLUS" > 0 and t1."TOTAL ORIGINAL" > 0 then t1."SURPLUS" / t1."TOTAL ORIGINAL"
        when t1."SURPLUS" > 0 and t1."TOTAL ORIGINAL" = 0 then 1
        else 0
        end
    ,3) "clc. %surplus"

    
    
    case
        when t1."TOTAL ORIGINAL" = 0 AND t1."clc. COUNTED" > 0 then 1
        when t1."TOTAL ORIGINAL" > 0 AND t1."clc. COUNTED" = 0 then 1
        when t1."TOTAL ORIGINAL" = 0 AND t1."clc. COUNTED" = 0 then 0
        else round(abs(1 - t1."clc. COUNTED" / t1."TOTAL ORIGINAL"),3)
    end "clc. %deviation"
    **/
from
(select
    to_number(substr(sc."COUNT DATE" - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5))+2 "COUNT DATE DV",
    --sc."COUNT DATE",
    sc.from_loc_id "LOCATION",
    sc.SKU_ID,
    sc.TAG_ID,
    loc.work_zone,
    --sc."TIMES COUNTED",

    case
        when sc."CLIENT" IS NOT NULL then sc."CLIENT"
        when loc.subzone_2 is not null then loc.subzone_2
        else loc.zone_1
    end "CLIENT",
    
    case
        when sc."TOTAL ORIGINAL" is null then 0
        else sc."TOTAL ORIGINAL"
    end "TOTAL ORIGINAL",
   
    --sc."TOTAL UPDATE",
    
    case
        when "TOTAL ORIGINAL" + sc."TOTAL UPDATE" is null then 0
        else "TOTAL ORIGINAL" + sc."TOTAL UPDATE"
    end "clc. COUNTED",
    case
        when sc."TOTAL UPDATE" < 0 then abs(sc."TOTAL UPDATE")
        else 0
    end "clc. MISSING",
        case
        when sc."TOTAL UPDATE" > 0 then abs(sc."TOTAL UPDATE")
        else 0
    end "clc. SURPLUS"

from
    (select
        it.FROM_LOC_ID "FROM_LOC_ID",
        it.SKU_ID,
        it.TAG_ID,
        count(it.KEY) "TIMES COUNTED",
        max(it.CLIENT_ID) "CLIENT",
        sum(it.UPDATE_QTY) "TOTAL UPDATE",
        sum(it.ORIGINAL_QTY) "TOTAL ORIGINAL",
        max(it.dstamp) "COUNT DATE"
    
        
    
    from
    (
        select *
        from
        (
        select
            it.*,
            ROW_NUMBER() OVER (PARTITION BY it.FROM_LOC_ID , it.SKU_ID, it.tag_id ORDER BY it.dstamp desc ) rn -- filtering the newest updates (Web > RDT)
            
        from V_INVENTORY_TRANSACTION it
            
        where it.CODE = 'Stock Check'
            and it.DSTAMP < to_timestamp(:EndDate_as_DD_MM_YYYY, 'DD/MM/YYYY')
            and it.DSTAMP >= to_timestamp(:BeginDate_as_DD_MM_YYYY, 'DD/MM/YYYY')
            and it.LIST_ID > 0
            
        
        order by it.dstamp desc
        ) t
        where t.rn = 1 -- show only the first rows of the filtering WEB > RDT
    ) it
        
    group by it.FROM_LOC_ID,it.SKU_ID,it.TAG_ID) sc
left join
(
select
    location_id,
    subzone_2,
    work_zone,
    zone_1
    
from V_location
) loc
on sc.from_loc_id = loc.location_id) t1

--order by t1.location
--order by "clc. %deviation" desc
order by "COUNT DATE DV"
