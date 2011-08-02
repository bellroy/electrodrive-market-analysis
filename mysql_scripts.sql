LOAD DATA LOCAL INFILE '' INTO TABLE database.table FIELDS TERMINATED BY '' ENCLOSED BY '"' LINES TERMINATED BY '\r'

#creates a flattened view of the regions – not useful by itself, but if you get tableau to extract the data, it will be better
CREATE OR REPLACE VIEW regions AS (
SELECT s.region_id AS 'sla_id', LEFT(s.region_id, 5) AS 'ssd_id', LEFT(s.region_id, 3) AS 'sd_id', LEFT(s.region_id,1) AS 'state_id', 
sla_names.name AS 'sla_name', ssd_names.`name` AS 'ssd_name', sd_names.name AS 'sd_name' , state_names.name AS 'state_name',
q.latitude AS sla_latitude, q.longitude as sla_longitude
FROM region_names as s 
INNER JOIN region_names AS sla_names ON s.region_id = sla_names.region_id
INNER JOIN region_names AS ssd_names ON LEFT(s.region_id, 5) = ssd_names.region_id
INNER JOIN region_names AS sd_names ON LEFT(s.region_id, 3) = sd_names.region_id	
INNER JOIN region_names AS state_names ON LEFT(s.region_id, 1) = state_names.region_id
INNER JOIN statistical_local_areas AS q ON q.sla_id = s.region_id
WHERE LENGTH(s.region_id) = 9
)
