/** Nedap UDF2 Check
    Binding variable :SHOW_LOTS - use '0' to show only empty UDF2's
                                  use '1' to also show LOT-NUMBERS (default)
**/

SELECT 
LOCATION_ID,
TAG_ID,
SKU_ID,
DESCRIPTION,
QTY_ON_HAND,
QTY_ALLOCATED,
USER_DEF_TYPE_2

FROM V_INVENTORY I
where i.CLIENT_ID = 'NLNEDAP'
and 
case
    when nvl(:SHOW_LOTS,1) = 1 and (i.USER_DEF_TYPE_2 <> i.SKU_ID or i.USER_DEF_TYPE_2 is null) then 1
    when :SHOW_LOTS = 0 and i.USER_DEF_TYPE_2 is null then 1
    else 0
end = 1
--and I.LOCATION_ID like '1%'

order by I.LOCATION_ID
