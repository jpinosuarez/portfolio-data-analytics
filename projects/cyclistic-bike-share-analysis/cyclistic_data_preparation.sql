/* ============================================================
   Cyclistic Bike-Share Data Preparation Script
   Author: Joaquín Pino Suarez
   Date: 2025-08-10
   Description:
   SQL workflow for consolidating, cleaning, and preparing
   Cyclistic bike-share data for analysis (2024–2025).
   ============================================================ */

---------------------------------------------------------------
-- 1. CREATE CONSOLIDATED TABLE
---------------------------------------------------------------

CREATE TABLE viajes_cyclistic (
    ride_id NVARCHAR(50),
    rideable_type NVARCHAR(50),
    started_at DATETIME,
    ended_at DATETIME,
    start_station_name NVARCHAR(255),
    start_station_id NVARCHAR(255),
    end_station_name NVARCHAR(255),
    end_station_id NVARCHAR(255),
    start_lat FLOAT,
    start_lng FLOAT,
    end_lat FLOAT,
    end_lng FLOAT,
    member_casual NVARCHAR(50)
);

---------------------------------------------------------------
-- 2. INSERT DATA FROM EACH MONTHLY TABLE (JAN 2024–JUN 2025)
---------------------------------------------------------------

INSERT INTO viajes_cyclistic SELECT * FROM [202401-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202402-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202403-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202404-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202405-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202406-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202407-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202408-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202409-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202410-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202411-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202412-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202501-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202502-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202503-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202504-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202505-divvy-tripdata];
INSERT INTO viajes_cyclistic SELECT * FROM [202506-divvy-tripdata];

-- Check total number of records
SELECT COUNT(*) AS total_records FROM viajes_cyclistic;

---------------------------------------------------------------
-- 3. REMOVE DUPLICATES
---------------------------------------------------------------

WITH duplicates AS (
  SELECT *,
         ROW_NUMBER() OVER (PARTITION BY ride_id ORDER BY ride_id) AS row_num
  FROM viajes_cyclistic
)
DELETE FROM duplicates WHERE row_num > 1;

---------------------------------------------------------------
-- 4. CLEAN INVALID DATA
---------------------------------------------------------------

-- Remove rows with missing or invalid timestamps
DELETE FROM viajes_cyclistic
WHERE started_at IS NULL
   OR ended_at IS NULL
   OR DATEDIFF(MINUTE, started_at, ended_at) < 0;

-- Remove rows with undefined user type
DELETE FROM viajes_cyclistic
WHERE member_casual IS NULL
   OR member_casual NOT IN ('member', 'casual');

---------------------------------------------------------------
-- 5. ADD DERIVED VARIABLES
---------------------------------------------------------------

-- Ride length (in minutes)
ALTER TABLE viajes_cyclistic ADD ride_length INT;

UPDATE viajes_cyclistic
SET ride_length = DATEDIFF(MINUTE, started_at, ended_at);

-- Day of week (e.g., Monday, Tuesday, etc.)
ALTER TABLE viajes_cyclistic ADD day_of_week VARCHAR(20);

UPDATE viajes_cyclistic
SET day_of_week = DATENAME(WEEKDAY, started_at);

---------------------------------------------------------------
-- 6. ADD TIME FEATURES (HOUR, MONTH, SEASON)
---------------------------------------------------------------

ALTER TABLE viajes_cyclistic ADD 
    start_hour INT,
    start_month INT,
    start_month_name VARCHAR(20),
    season VARCHAR(10);

UPDATE viajes_cyclistic
SET 
    start_hour = DATEPART(HOUR, started_at),
    start_month = DATEPART(MONTH, started_at),
    start_month_name = DATENAME(MONTH, started_at);

-- Assign season based on month number
UPDATE viajes_cyclistic
SET season = 
    CASE 
        WHEN start_month IN (12, 1, 2) THEN 'Winter'
        WHEN start_month IN (3, 4, 5) THEN 'Spring'
        WHEN start_month IN (6, 7, 8) THEN 'Summer'
        WHEN start_month IN (9, 10, 11) THEN 'Fall'
        ELSE 'Unknown'
    END;

---------------------------------------------------------------
-- 7. VALIDATION QUERIES
---------------------------------------------------------------

-- Check for negative or zero durations
SELECT COUNT(*) AS negative_durations
FROM viajes_cyclistic
WHERE ride_length <= 0;

-- Verify user types
SELECT DISTINCT member_casual FROM viajes_cyclistic;

-- Sample validation
SELECT TOP 5 * FROM viajes_cyclistic;

---------------------------------------------------------------
-- 8. CREATE FINAL CLEANED VIEW FOR ANALYSIS
---------------------------------------------------------------

CREATE VIEW viajes_analisis AS
SELECT 
    ride_id,
    rideable_type,
    started_at,
    ended_at,
    ride_length,
    day_of_week,
    start_hour,
    start_month,
    start_month_name,
    season,
    member_casual
FROM viajes_cyclistic
WHERE ride_length > 0;

---------------------------------------------------------------
-- END OF SCRIPT
---------------------------------------------------------------