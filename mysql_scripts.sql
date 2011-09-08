LOAD DATA LOCAL INFILE '/Users/scott/Desktop/Region Definitions.csv' INTO TABLE `electrodrive_regions` FIELDS TERMINATED BY ',' ENCLOSED BY '' LINES TERMINATED BY '\r'

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

SELECT
	ic.`id` AS 'industry class id', ic.name AS 'industry class',
	ig.id AS 'industry group id', ig.name AS 'industry group',
	iss.id AS 'industry subdivision id', iss.name AS 'industry subdivision',
	id.id AS 'industry division id', id.name AS 'industry division',
	`sie`.employees,

FROM `industry-classes` AS ic INNER JOIN `industry-groups` ig ON ic.parent_id = ig.id
INNER JOIN `industry-subdivisions` iss ON ig.parent_id = `iss`.`id`
INNER JOIN `industry-divisions` id ON iss.parent_id = id.id
INNER JOIN `sla_industry_employees` sie ON sie.`industry_class_id` = ic.id
WHERE sie.employees > 0


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

# Find the number of employees in a Electrodrive Segment in an Electrodrive Region
SELECT left(ssd_industry_employees.ssd_id,1), `electrodrive_regions`.`region_name`, `electrodrive_segments`.`segment_name`, sum(employees)
FROM `ssd_industry_employees`
INNER JOIN `electrodrive_segments` ON (`ssd_industry_employees`.`industry_class_id` = `electrodrive_segments`.`industry_class_id`)
INNER JOIN `electrodrive_regions` ON (
	(LENGTH(region_code) = 5 AND region_code = ssd_industry_employees.ssd_id) OR
	(LENGTH(region_code) = 3 AND region_code = LEFT(ssd_industry_employees.ssd_id,3))
)
group by 2,3
order by 1,2,3

# The coefficents for each product in each segment based on Victoria sales
SELECT
	`electrodrive_segments`.`segment_name`,
	`victoria_sales`.`model`,
	(`victoria_sales`.`quantity`) AS 'quantity sold',
	sum(employees) as employees_in_segment,
	((`victoria_sales`.`quantity`) / sum(employees) * 1000) as coefficient_per_thousand
	FROM `ssd_industry_employees`
INNER JOIN `electrodrive_segments` ON (`ssd_industry_employees`.`industry_class_id` = `electrodrive_segments`.`industry_class_id`)
inner join `victoria_sales` ON (`victoria_sales`.`electrodrive_segment` = `electrodrive_segments`.`segment_name`)
WHERE LEFT(ssd_id,1) = '2'
GROUP BY `electrodrive_segments`.`segment_name`, `victoria_sales`.model
ORDER BY `electrodrive_segments`.`segment_name`

# Get's the project sales for each reach and each product
SELECT (DATEDIFF(max(STR_TO_DATE(order_date, '%m/%d/%Y')),min(STR_TO_DATE(order_date, '%m/%d/%Y'))) / 365) FROM sales WHERE LENGTH(order_date) > 0 AND state = 'VIC' into @num_years;

SELECT
	rse.`state_name`, rse.region_name, 	product_coefficients.`model`,
	ROUND(SUM(`coefficient_per_thousand` * rse.`sum(employees)`/ @num_years / 1000),1) AS sales_benchmark
FROM
	`region_segment_employees` AS rse INNER JOIN `product_coefficients` ON (rse.segment_name = product_coefficients.segment_name)
GROUP BY rse.region_name, product_coefficients.`model`
ORDER BY 1,2,4,3
