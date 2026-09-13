
-------------------------------------------------------
-- Data management (INSERT / UPDATE / DELETE)
-------------------------------------------------------

-- Add a new store
INSERT INTO stores (store_id)
VALUES (46);

-- Add a new week observation
INSERT INTO weeks (week_id, date, holiday_flag, temperature, fuel_price, CPI, unemployment)
VALUES (144, '2013-08-02', 0, 78.5, 3.45, 221.34, 7.1);

-- Add a new weekly sales observation for a store
INSERT INTO weekly_sales (sale_id, store_id, week_id, weekly_sales)
VALUES (6436, 46, 144, 512345.67);

-- Update a sales value that was entered incorrectly
UPDATE weekly_sales
SET weekly_sales = 520000.00
WHERE sale_id = 6436;

-- Update the unemployment rate recorded for a specific week
UPDATE weeks
SET unemployment = 7.3
WHERE week_id = 144;

-- Remove a sales record entered by mistake
DELETE FROM weekly_sales
WHERE sale_id = 6436;

-- Remove a store that was added incorrectly
-- (possible only if it has no related weekly_sales records, since store_id is stored a foreign key)
DELETE FROM stores
WHERE store_id = 46;

-- Remove the test week added above
DELETE FROM weeks
WHERE week_id = 144;

-------------------------------------------------------
-- Analytical queries (SELECT)
-------------------------------------------------------

-- 5 stores with the highest total sales
SELECT store_id, total_sales
FROM store_total_sales
ORDER BY total_sales DESC
LIMIT 5;

-- 5 stores with the lowest average weekly sales
SELECT store_id, avg_weekly_sales
FROM store_total_sales
ORDER BY avg_weekly_sales ASC
LIMIT 5;

-- Examine sales for a specific week
SELECT store_id, weekly_sales
FROM weekly_sales
WHERE week_id = 1
ORDER BY weekly_sales DESC;

-- Compare average sales between holiday and non-holiday weeks
SELECT
    CASE holiday_flag WHEN 1 THEN 'Holiday' ELSE 'Non-holiday' END AS week_type,
    avg_sales,
    num_observations
FROM holiday_vs_non_holiday_sales;

-- Analyze weekly sales together with economic/environmental conditions for a specific store
SELECT date, weekly_sales, temperature, fuel_price, CPI, unemployment
FROM weekly_sales_with_conditions
WHERE store_id = 1
ORDER BY date;

-- Find weeks with high unemployment (above 8%) and their average sales across all stores
SELECT w.week_id, w.date, w.unemployment, ROUND(AVG(ws.weekly_sales), 2) AS avg_sales
FROM weeks w
JOIN weekly_sales ws ON w.week_id = ws.week_id
WHERE w.unemployment > 8.0
GROUP BY w.week_id
ORDER BY w.unemployment DESC;

-- Compare total sales of two specific stores
SELECT store_id, total_sales
FROM store_total_sales
WHERE store_id IN (1, 2);

