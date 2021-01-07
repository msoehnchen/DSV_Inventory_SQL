/** Putaway Analyse to specific zones **/
select
    CODE,
    DATESTAMP,
    FROM_LOC_ID,
    SECTION,
    REASON_ID,
    CLIENT_ID,
    REFERENCE_ID,
    sum(CT_TAGS) CT2_TAGS
    
from
(
    select
    
    CODE, 
    DATESTAMP, 
    FROM_LOC_ID, 
    TO_AISLE ||'.'|| 
    --TO_BAY, 
    case
        when TO_NUMBER(TO_BAY) between 1 and 5 then '01-05'
        when TO_NUMBER(TO_BAY) between 6 and 10 then '06-10'
        when TO_NUMBER(TO_BAY) between 11 and 15 then '11-15'
        when TO_NUMBER(TO_BAY) between 16 and 20 then '16-20'
        when TO_NUMBER(TO_BAY) between 21 and 25 then '21-25'
        when TO_NUMBER(TO_BAY) between 26 and 30 then '26-30'
        when TO_NUMBER(TO_BAY) between 31 and 35 then '31-35'
        when TO_NUMBER(TO_BAY) between 36 and 40 then '36-40'
        when TO_NUMBER(TO_BAY) between 41 and 45 then '41-45'
        when TO_NUMBER(TO_BAY) between 46 and 50 then '46-50'
        when TO_NUMBER(TO_BAY) between 51 and 55 then '51-55'
        when TO_NUMBER(TO_BAY) between 56 and 60 then '56-60'
        when TO_NUMBER(TO_BAY) between 61 and 65 then '61-65'
        when TO_NUMBER(TO_BAY) between 66 and 70 then '66-70'
        when TO_NUMBER(TO_BAY) between 71 and 75 then '71-75'
        when TO_NUMBER(TO_BAY) between 76 and 80 then '76-80'
        else 'OTHER'
    end SECTION,
    REASON_ID, 
    CLIENT_ID, 
    REFERENCE_ID, 
    CT_TAGS
    
    from
    (
        
        select
            IT.CODE,
            to_char(IT.DSTAMP,'YYYY/MM/DD') DATESTAMP,
            IT.FROM_LOC_ID,
            --IT.TO_LOC_ID,
            SUBSTR(IT.TO_LOC_ID,1,4) TO_AISLE,
            SUBSTR(IT.TO_LOC_ID,5,2) TO_BAY,
            IT.REASON_ID,
            IT.CLIENT_ID,
            IT.REFERENCE_ID,
            --IT.SKU_ID,
            count(it.TAG_ID) CT_TAGS
            --IT.UPDATE_QTY,
            --IT.USER_ID,
            --IT.ELAPSED_TIME
        from V_INVENTORY_TRANSACTION IT
        where IT.CODE = 'Putaway'
            and IT.DSTAMP between SYSDATE - (case
                                                when :NUMBER_OF_DAYS is null then 1
                                                else to_number(:NUMBER_OF_DAYS)
                                            end) 
                            and SYSDATE + 1
            and regexp_like(IT.FROM_LOC_ID,'^INB-\w\d\d')
            and regexp_like(it.to_loc_id,'^1\w\d\d\d\d\d\w')
        group by
            IT.CODE,
            to_char(IT.DSTAMP,'YYYY/MM/DD'), -- DATESTAMP
            IT.FROM_LOC_ID,
            SUBSTR(IT.TO_LOC_ID,1,4),
            SUBSTR(IT.TO_LOC_ID,5,2), --TO_AISLEBAY
            IT.REASON_ID,
            IT.CLIENT_ID,
            IT.REFERENCE_ID
        order by IT.REFERENCE_ID
    ) PUT
) SECTIONS
group by
    CODE,
    DATESTAMP,
    FROM_LOC_ID,
    SECTION,
    REASON_ID,
    CLIENT_ID,
    REFERENCE_ID
