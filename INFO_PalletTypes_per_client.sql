select CLIENT_ID, CONFIG_ID, PALLET_TYPE_GROUP, VOLUME, HEIGHT, DEPTH, WIDTH, WEIGHT, LOAD_METRES, NOTES from V_PALLET_CONFIG

where CLIENT_ID = 'NLNEDAP'
order by CONFIG_ID