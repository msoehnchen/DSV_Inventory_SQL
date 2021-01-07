SELECT
    location_id,
    sku_id,
    tag_id,
    qty_on_hand,
    TO_CHAR(receipt_dstamp,'YYYY/MM/DD') rec_date
FROM
    v_inventory
WHERE
    sku_id IN (
        '100S14375',
        '100S14377'
    )