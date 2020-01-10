/**
      FULL Seriallist in Stock
      
      used for Wall-To-Wall Count 02/2020
			
			08/01/2020 by marcel.sohnchen@nl.dsv.com

				Field										Description
				------------------------------------------------------------------------------------------------------------------------------
				Location	    							Location in the warehouse
				TAG											TAG-ID in warehouse
				SKU											Partnumber
				TOTAL SKU QTY ON LOC				        Total physical quantity on that particular location
				SERIAL									    serials systematically on this location, serial can be on multiple locations (see "STATUS")
				CONDITION								    Condition of this Item
				UNIQUE SKU SERIAL ON LOCATION	            amount of unique serials systematically on this location. (see "STATUS")
				DIFFERENCE QTY/SERIAL?	                    Is there a difference between physical Qty on location and serials systematically on location?
				STATUS	                                    If status is 'Picked', the serial is actually on warehouse location and final location at the same time. It leaves the warhouse location as soon as it is physically shipped.
				ORDER_ID								    corresponding Order for which this item is picked
				PALLET_ID								    Shipping-Pallet-ID for traceability
**/
select * from (
    Select 
        serials.*,
        case
            when strans.Code = 'Pick' then 'Picked'
            else null
        end "STATUS",
        strans.ORDER_ID,
        strans.PALLET_ID
        --fullinv."REC DSTAMP",
        --fullinv."REC EXCEL DATE",
        --fullinv."DAYS IN STOCK"
      
    
    from
    (
        select 
            fullinv."LOCATION",
            fullinv."TAG",
            fullinv."SKU",
            fullinv."QUANTITY" "TOTAL SKU QTY ON LOC",
            fullinv."SERIAL",
            --fullinv."SERIAL STATUS",
            fullinv."CONDITION",
            serialcount."Distinct Serials" "UNIQUE SKU SERIALS ON LOCATION",
            
            case
                when (fullinv."SERIAL" is not null) and (fullinv."QUANTITY" = serialcount."Distinct Serials") then 'NO'
                when (fullinv."SERIAL" is not null) and (fullinv."QUANTITY" <> serialcount."Distinct Serials") then 'YES'
                when fullinv."SERIAL" is null then 'NOT SERIALIZED'
                else 'other'
            end "DIFFERENCE QTY/SERIAL?",
            
            fullinv."REC DSTAMP",
            fullinv."REC EXCEL DATE",
            fullinv."DAYS IN STOCK"
        
        from
        (
            SELECT 
               
                jinv.LOCATION_ID "LOCATION",
                jinv.TAG_ID "TAG",
                jinv.SKU_ID "SKU",
                jinv.QTY_ON_HAND "QUANTITY",
                jserial.SERIAL_NUMBER "SERIAL",
                jserial.STATUS "SERIAL STATUS",
                jinv.CONDITION_ID "CONDITION",
                jinv."REC DSTAMP",
                jinv."REC EXCEL DATE",
                jinv."DAYS IN STOCK"
                
            
            FROM
            (select
                tinv.TAG_ID,
                tinv.SKU_ID,
                tinv.QTY_ON_HAND,
                tinv.LOCATION_ID,
                tinv.CONDITION_ID,
                
                
                /**  Cases below will filter out the pick-locations, because of tag-merging on that locations.
                        Here we cant name the receive date for sure. Maybe there is a better way to filter those locations (Subzone, workzone...)
                **/
                case
                    when REGEXP_LIKE(tinv.LOCATION_ID, '*AA|*BB|*CC|*DD|*EE|*FF|*GG|*HH|*II', 'i') then null
                    else tinv.RECEIPT_DSTAMP
                end  "REC DSTAMP",
                
                case
                    when REGEXP_LIKE(tinv.LOCATION_ID, '*AA|*BB|*CC|*DD|*EE|*FF|*GG|*HH|*II', 'i') then null
                    else to_number(substr(tinv.RECEIPT_DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2)
                end "REC EXCEL DATE",
                case
                    when REGEXP_LIKE(tinv.LOCATION_ID, '*AA|*BB|*CC|*DD|*EE|*FF|*GG|*HH|*II', 'i') then null
                    else (to_number(substr(CURRENT_TIMESTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2)-to_number(substr(tinv.RECEIPT_DSTAMP - to_timestamp('01/01/1900','DD/MM/YYYY'),6,5)+2))
                end  "DAYS IN STOCK"
                 
           
            from V_INVENTORY tinv
            where tinv.CLIENT_ID = 'NLGLORY'
            and tinv.LOCATION_ID not in ('SUSPENSE') 
            ) jinv
            
            LEFT JOIN
            (select 
                tserial.TAG_ID,
                tserial.SERIAL_NUMBER,
                tserial.SKU_ID,
                tserial.STATUS
                
            
            from V_SERIAL_NUMBER tserial
            where tserial.STATUS = 'I'
            
            
            ) jserial
            
            on jinv.TAG_ID = jserial.TAG_ID
            
            order by jinv.LOCATION_ID /* all inventory incl serials */
        ) fullinv
        left join
        (
            SELECT 
               
                jinv.LOCATION_ID "LOCATION",
                jinv.TAG_ID "TAG",
                jinv.SKU_ID "SKU",
                --jinv.QTY_ON_HAND "QUANTITY",
                count(distinct jserial.SERIAL_NUMBER) "Distinct Serials"
                --jserial.STATUS "SERIAL STATUS",
                --jinv.CONDITION_ID "CONDITION"
                
            
            FROM
            (select
                tinv.TAG_ID,
                tinv.SKU_ID,
                tinv.QTY_ON_HAND,
                tinv.LOCATION_ID,
                tinv.CONDITION_ID
            
            from V_INVENTORY tinv
            where tinv.CLIENT_ID = 'NLGLORY'
            ) jinv
            
            LEFT JOIN
            (select 
                tserial.TAG_ID,
                tserial.SERIAL_NUMBER,
                tserial.SKU_ID,
                tserial.STATUS
                
            
            from V_SERIAL_NUMBER tserial
            where tserial.STATUS = 'I'
            
            
            ) jserial
            
            on jinv.TAG_ID = jserial.TAG_ID
            
            group by jinv.Location_id,jinv.Tag_id,jinv.SKU_ID
            
            order by jinv.LOCATION_ID /* summary how many serials per location per sku */
        ) serialcount
        
        on (fullinv."LOCATION" = serialcount."LOCATION") and (fullinv."TAG" = serialcount."TAG") and (fullinv."SKU" = serialcount."SKU")
    ) serials
    left join
    (
    select 
        V_SN_TRANSACTION.CODE,
        V_SN_TRANSACTION.SERIAL_NUMBER, 
        V_SN_TRANSACTION.TAG_ID,
        V_SN_TRANSACTION.ORDER_ID,
        V_SN_TRANSACTION.PALLET_ID
    from V_SN_TRANSACTION
    where V_SN_TRANSACTION.CODE = 'Pick'
    ) strans
    
    on strans.SERIAL_NUMBER = serials."SERIAL" and strans.TAG_ID = serials."TAG"
    
    order by serials."SKU",serials."TAG",serials."LOCATION",serials."SERIAL"
) fullinv
where fullinv."DIFFERENCE QTY/SERIAL?" in ('YES','NO')

;


