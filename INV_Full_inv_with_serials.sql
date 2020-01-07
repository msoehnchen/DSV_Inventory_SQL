/**
	Full CargoWrite inventory, with serials linked to the TAG's
**/

SELECT 
   
    jinv.LOCATION_ID "LOCATION",
    jinv.TAG_ID "TAG",
    jinv.SKU_ID "SKU",
    jserial.SERIAL_NUMBER "SERIAL",
    jserial.STATUS "SERIAL STATUS",
    jinv.CONDITION_ID "CONDITION"
    

FROM
(select
    tinv.TAG_ID,
    tinv.SKU_ID,
    tinv.LOCATION_ID,
    tinv.CONDITION_ID

from V_INVENTORY tinv) jinv

LEFT JOIN
(select 
    tserial.TAG_ID,
    tserial.SERIAL_NUMBER,
    tserial.SKU_ID,
    tserial.STATUS
    

from V_SERIAL_NUMBER tserial
where tserial.STATUS = 'I' --make shure to only show the serials which are I = InStock


) jserial

on jinv.TAG_ID = jserial.TAG_ID

order by jinv.LOCATION_ID;
