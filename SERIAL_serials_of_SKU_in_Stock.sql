Select

    i.tag_id TAG,
    i.SKU_id SKU,
    i.Location_id LOCATION,
    s.serial_number SERIAL,
    s.status
    
from V_INVENTORY i, V_SERIAL_NUMBER s
where i.SKU_id = :SKU and i.TAG_id = s.tag_id
