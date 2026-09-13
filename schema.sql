
-- Enable foreign key constraint enforcement (off by default in SQLite)
PRAGMA foreign_keys = ON;

-------------------------------------------------------
-- STORES TABLE (store id)
-------------------------------------------------------
CREATE TABLE stores (
    store_id INTEGER PRIMARY KEY -- unique identifier for each store
);

-------------------------------------------------------
-- WEEKS TABLE (week id + date + holiday flag + environmental and macroeconomic variables)
-------------------------------------------------------
CREATE TABLE weeks (
    week_id INTEGER PRIMARY KEY,          -- unique identifier for each week
    date TEXT UNIQUE NOT NULL,            -- date of the week (stored as TEXT, ISO8601 format)
    holiday_flag INTEGER NOT NULL CHECK (holiday_flag IN (0, 1)), -- 1 = holiday week, 0 = non-holiday week
    temperature REAL NOT NULL,            -- average temperature recorded during the week
    fuel_price REAL NOT NULL,             -- average fuel price recorded during the week
    CPI REAL NOT NULL,                    -- Consumer Price Index recorded during the week
    unemployment REAL NOT NULL            -- unemployment rate recorded during the week
);

-------------------------------------------------------
-- WEEKLY SALES TABLE (sale id, weekly sales, FK store and week)
-------------------------------------------------------
CREATE TABLE weekly_sales (
    sale_id INTEGER PRIMARY KEY,          -- unique identifier for each sales record
    store_id INTEGER NOT NULL,            -- store associated with this observation
    week_id INTEGER NOT NULL,             -- week associated with this observation
    weekly_sales REAL NOT NULL,           -- total sales amount for the store in that week
    FOREIGN KEY (store_id) REFERENCES stores(store_id),
    FOREIGN KEY (week_id) REFERENCES weeks(week_id),
    UNIQUE (store_id, week_id)            -- a store can have only one observation per week
);

-------------------------------------------------------
-- INDEXES
-- (Indexes are automatically created for "UNIQUE" constraints -->
-- The constraints on weeks.date and on (store_id, week_id) already have corresponding indexes)
-------------------------------------------------------

-- Speeds up filtering/grouping sales records by store
CREATE INDEX indx_weekly_sales_store ON weekly_sales(store_id);

-- Speeds up joins between weekly_sales and weeks
CREATE INDEX indx_weekly_sales_week ON weekly_sales(week_id);

-- Speeds up comparisons between holiday and non-holiday weeks
CREATE INDEX indx_weeks_holiday_flag ON weeks(holiday_flag);


-------------------------------------------------------
-- VIEWS
-------------------------------------------------------

-- store_total_sales VIEW:
-- Total and average weekly sales for each store
CREATE VIEW store_total_sales AS
SELECT
    s.store_id,
    SUM(ws.weekly_sales) AS total_sales,
    ROUND(AVG(ws.weekly_sales), 2) AS avg_weekly_sales,
    COUNT(ws.sale_id) AS weeks_recorded
FROM stores s
JOIN weekly_sales ws ON s.store_id = ws.store_id
GROUP BY s.store_id;

-- holiday_vs_non_holiday_sales VIEW:
-- Average sales during holiday weeks vs non-holiday weeks
CREATE VIEW holiday_vs_non_holiday_sales AS
SELECT
    w.holiday_flag,
    ROUND(AVG(ws.weekly_sales), 2) AS avg_sales,
    COUNT(ws.sale_id) AS num_observations
FROM weekly_sales ws
JOIN weeks w ON ws.week_id = w.week_id
GROUP BY w.holiday_flag;

-- weekly_sales_with_conditions VIEW:
-- Combines each sales observation with the economic and environmental conditions of the corresponding week
CREATE VIEW weekly_sales_with_conditions AS
SELECT
    ws.sale_id,
    ws.store_id,
    w.date,
    w.holiday_flag,
    w.temperature,
    w.fuel_price,
    w.CPI,
    w.unemployment,
    ws.weekly_sales
FROM weekly_sales ws
JOIN weeks w ON ws.week_id = w.week_id;
