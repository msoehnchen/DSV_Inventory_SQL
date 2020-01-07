/*   Report Damage
        all movemnts (today and yesterday) to and from Damage, incl. Stock actually on DAMAGE
        
        22/11/2019 by marcel.sohnchen@nl.dsv.com
*/

SELECT 
    
    
    -- Old version, not recognized by excel as datevaleu :(
    --case
    --    when t1.dstamp  is null then to_char(t2."MOVEDATE", 'DD/MM/YYYY')
    --    else to_char(t1.DSTAMP, 'DD/MM/YYYY')
    --end "Date",

    -- new version - converted to Excels DateValue
    case
        when t1.dstamp  is null then substr(t2."MOVEDATE" - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5) + 2
        else substr(t1.dstamp - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5) + 2
    end "Date",

    case
        when t1.TRANSTYPE  is null then t2.OWN_TYPE
        when t1.TRANSTYPE  is not null then t1.TRANSTYPE
        else 'UNKNOWN RECORD'
    end "TYPE",


    case
        when t1.TAG_ID  is null then t2.tag_id
        else t1.tag_id
    end "TAG",

    case
        when t1.condition_id  is null then t2.condition_id
        else t1.condition_id
    end "Condition",
    
    case
        when t1.CLIENT_ID is null then t2.client_id
        else t1.CLIENT_ID
    end "Client",

    case
        when t1.SKU_ID is null then t2.SKU_ID
        else t1.SKU_ID
    end "SKU",

    case
        when t1.original_qty is null then t2.QTY_ON_HAND
        else t1.original_qty
    end "QTY",

    t1.code,
    t1.from_loc_id  "Initial Location",
    t1.to_loc_id  "Second Location",
    case
        when t1.location_id  is null then t2.location_id
        else t1.location_id
    end "Current Location",

    --t1.LOCATION_ID "Current Location T1",
    --t2.LOCATION_ID "Current Location T2",
    case
        when t1.action is null and (t2.location_id not like 'INB%' and t2.LOCATION_ID != 'DAMAGE') then 'DAMAGE STOCK ON LOCATION - TO BE CHECKED !!'
        when t1.action is null and (t2.location_id not like 'INB%' and t2.LOCATION_ID = 'DAMAGE') then 'pallet in DAMAGE-Area - TO BE CHECKED !!'
        when t1.action is null and t2.location_id  like 'INB%' and t2.CONDITION_ID = 'DM1' then 'received as TRANSPORT Damage (DM1) - NOT YET PUTAWAYED'
        when t1.action is null and t2.location_id  like 'INB%' and t2.CONDITION_ID = 'DM2' then 'received as HANDLING Damage (DM2) - NOT YET PUTAWAYED'
        
        else t1.action
    end "Action"
    
   
   


FROM
(
    Select
        trans.dstamp,
        trans.TAG_ID,
        trans.condition_id,
        trans.Code,
        trans.from_loc_id,
        trans.to_loc_id,
        inv.location_id ,
        trans.action,
        trans.time "Time 1st move",
        inv.time "Time 2nd move",
        trans.user_id "User first move",
        trans.SKU_ID,
        trans.CLIENT_ID,
        trans.original_qty,
        trans."OWN_TYPE" "TRANSTYPE"

     
    from
    (select
        it.DSTAMP,
        it.SKU_ID,
        it.CLIENT_ID,
        it.TAG_ID,
        it.CONDITION_ID,
        it.CODE,
        it.FROM_LOC_ID,
        it.TO_LOC_ID,
        --it.FINAL_LOC_ID,
        it.ORIGINAL_QTY,
        --it.UPDATE_QTY,
        to_char(it.DSTAMP, 'HH24:MM:SS') "TIME",
        it.user_id,
        'TRANSACTION RECORD' "OWN_TYPE",
    
        CASE
            WHEN (it.CONDITION_ID IN ('DM1','DM2','RF1') and it.TO_LOC_ID != 'DAMAGE' and it.FROM_LOC_ID = 'DAMAGE' ) THEN 'MOVED BACK to stock'
            WHEN (it.CONDITION_ID IN ('DM1','DM2','HO1','HO4','HO5','HO2') and it.TO_LOC_ID != 'DAMAGE' and it.FROM_LOC_ID = 'GGSINSPECT' ) THEN 'inspection Glory - not updated'
            
            WHEN (it.CONDITION_ID IN ('OK1') and it.TO_LOC_ID = 'DAMAGE' ) THEN 'MOVED to damage - NOT received as Damage'
            WHEN (it.CONDITION_ID IN ('DM1') and it.TO_LOC_ID = 'DAMAGE' ) THEN concat('PUTAWAY to damage - ',concat('received as TRANSPORT damage (',to_char(it.CONDITION_ID)))            
            WHEN (it.CONDITION_ID IN ('DM2') and it.TO_LOC_ID = 'DAMAGE' ) THEN concat('PUTAWAY to damage - ',concat('received as HANDLING damage (',to_char(it.CONDITION_ID)))
            
            
            ELSE ''
        END "ACTION"
        
    
    from
        V_INVENTORY_TRANSACTION it
    
    where
            (
            it.DSTAMP <= CURRENT_DATE + 1
            and it.DSTAMP >= CURRENT_DATE - 1
            and it.CODE IN ('Cond Update', 'Putaway', 'Relocate')
            and it.condition_id IN ('DM1','DM2','RF1')
            --and (it.FINAL_LOC_ID = 'DAMAGE' or it.FINAL_LOC_ID = 'PROBLEM') -- comment this line to see all movements.
            and (it.FROM_LOC_ID != 'GGSINSPECT') -- dont show movement from GGSINSPECT
            and (it.FINAL_LOC_ID != 'GGSINSPECT') -- dont show movement to GGSINSPECT
            and (it.FROM_LOC_ID != 'NONCONFORM') -- dont show movement from NONCONFORM
            and (it.FINAL_LOC_ID != 'NONCONFORM') -- dont show movement to NONCONFORM
)
        OR
            (
            it.DSTAMP <= CURRENT_DATE + 1
            and it.DSTAMP >= CURRENT_DATE - 1
            and it.TO_LOC_ID = 'DAMAGE'
            and it.CODE not in ('Adjustment','UnPick') 
            )
            
    
    
    order by it.TAG_ID, it.DSTAMP
    ) trans
    LEFT JOIN
    (
    select
        iv.TAG_ID,
        iv.LOCATION_ID,
        iv.QTY_ON_HAND,
        to_char(iv.MOVE_DSTAMP, 'HH24:MM:SS') "TIME",
        'INVENTORY RECORD' "OWN_TYPE"
        
        
    from V_INVENTORY iv	
    ) inv
    
    on trans.TAG_ID = inv.TAG_ID and trans.original_qty = inv.QTY_ON_HAND
        
) t1
FUll outer join
(
    select 
        inv2.TAG_ID,
        inv2.CONDITION_ID,
        inv2.LOCATION_ID,
        inv2.CLIENT_ID,
        inv2.SKU_ID,
        inv2.QTY_ON_HAND,
        inv2.MOVE_DSTAMP "MOVEDATE",
        'INVENTORY RECORD' "OWN_TYPE"
        
    from v_inventory inv2
    where 
        (
            inv2.CONDITION_ID in ('DM1','DM2','RF1','HO5')
            --and inv2.LOCATION_ID != 'DAMAGE'
        )
) t2

on t1.tag_id = t2.tag_id

order by "TYPE" DESC, "Date" desc,"Client", "TAG", "CODE", "Current Location"  

;
