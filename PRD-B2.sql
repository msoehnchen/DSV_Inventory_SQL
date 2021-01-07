select 
LOC.LOCATION_ID,
SUBSTR(LOC.LOCATION_ID,1,4) AISLE,
--to_number(SUBSTR(LOC.LOCATION_ID,5,2)) BAY,
SUBSTR(LOC.LOCATION_ID,5,2) BAY,

case
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1D') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 1 and 38 then 'before'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1D') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 39 and 80 then 'after'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1E') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 1 and 38 then 'before'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1E') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 39 and 40 then 'tunnel'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1E') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 41 and 80 then 'after'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1F(01|02|03|04|05|06|07)') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 1 and 38 then 'before'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1F(01|02|03|04|05|06|07)') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 39 and 40 then 'tunnel'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1F(01|02|03|04|05|06|07)') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 41 and 80 then 'after'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1F(08|09|10)') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 1 and 50 then 'before'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1F(08|09|10)') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 51 and 52 then 'tunnel'
    when regexp_like(SUBSTR(LOC.LOCATION_ID,1,4),'^1F(08|09|10)') and TO_NUMBER(SUBSTR(LOC.LOCATION_ID,5,2)) between 53 and 80 then 'after'
    else 'unknown'    
end TUNNEL,

--TO_NUMBER(SUBSTR(LOC.LOCATION_ID,7,1)) POSI,
SUBSTR(LOC.LOCATION_ID,7,1) POSI,

substr(loc.location_id,8,1) HLEVEL,
LOC.ZONE_1,
LOC.SUBZONE_1,
LOC.SUBZONE_2,
LOC.WORK_ZONE,
LOC.LOC_TYPE,
LOC.LOCK_STATUS,
INV.CLIENT_ID,
INV.TAG_ID,
INV.SKU_ID,
INV.PALLET_CONFIG


from V_LOCATION LOC
left join V_INVENTORY INV on LOC.LOCATION_ID = INV.LOCATION_ID
where regexp_like(LOC.LOCATION_ID,'(^1D(06|07|08|09|10|11|12|13|14))|(^1E)|(^1F)') and length(loc.location_id) = 8 
