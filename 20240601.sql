-- =========================
--
-- Project: Google Certification Capstone Project
-- Dataset: Fitbit Fitness Tracker Data https://www.kaggle.com/datasets/arashnic/fitbit 
-- Language: PostgreSQL
--
-- =========================


-- =========================
-- [SECTION 1] TABLE CREATION
-- CSVs imported via command line
-- =========================


-- 2024-05-16
CREATE TABLE steps_min (
	id BIGINT,
	"timestamp" TIMESTAMP,
	steps INT
);

-- 2024-05-16
CREATE TABLE mets_min (
	id BIGINT,
	"timestamp" TIMESTAMP,
	mets INT
);

-- 2024-05-16
CREATE TABLE intensity_min (
	id BIGINT,
	"timestamp" TIMESTAMP,
	intensity INT
);

-- 2024-05-16
CREATE TABLE calories_min (
	id BIGINT,
	"timestamp" TIMESTAMP,
	kcal_burned NUMERIC
);

-- 2024-05-16
CREATE TABLE combined_min AS 
	SELECT s.id, s.timestamp, s.steps, m.mets, i.intensity, c.kcal_burned
	FROM steps_min s
	JOIN mets_min m ON s.id = m.id AND s.timestamp = m.timestamp
	JOIN intensity_min i ON s.id = i.id AND s.timestamp = i.timestamp
	JOIN calories_min c ON s.id = c.id AND s.timestamp = c.timestamp;

-- 2024-05-16
CREATE TABLE sleep_min (
	id BIGINT,
	"timestamp" TIMESTAMP,
	sleep_state INT,
	log_id BIGINT
);

-- 2024-05-16
CREATE TABLE daily_activity (
	id BIGINT,
	"date" DATE,
	steps_total INT,
	distance_total NUMERIC,
	tracker_distance NUMERIC,
	logged_activities_distance NUMERIC,
	very_active_distance NUMERIC,
	moderately_active_distance NUMERIC,
	light_active_distance NUMERIC,
	sedentary_active_distance NUMERIC,
	very_active_min INT,
	fairly_active_min INT,
	lightly_active_min INT,
	sedentary_min INT,
	calories INT
);

-- 2024-05-18
CREATE TABLE data_viz (
	id BIGINT,
	--sleep_log TEXT,
	days_logged INT,
	user_type TEXT,
	total_step_days INT,
	days_w_step_count INT
);

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
CREATE TEMP TABLE temp_table (
	id BIGINT,
	"timestamp" TIMESTAMP,
	steps INT,
	mets NUMERIC,
	intensity INT,
	kcal_burned NUMERIC
);

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?CREATE TABLE combined_min2 (
	id BIGINT,
	"timestamp" TIMESTAMP,
	steps INT,
	mets NUMERIC,
	intensity INT,
	kcal_burned NUMERIC
);

-- 2024-05-20
CREATE TABLE heartrate_sec (
	id BIGINT,
	"timestamp" TIMESTAMP.
	heart_rate INT
);

-- 2024-05-26
CREATE TABLE weight (
	id BIGINT,
	"timestamp" TIMESTAMP,
	kg NUMERIC,
	lb NUMERIC,
	fat INT,
	BMI NUMERIC,
	is_manual_report TEXT,
	log_id BIGINT
);


-- =========================
-- [SECTION 2] ALTERATION
-- =========================


-- 2024-05-16
ALTER TABLE combined_min 
ALTER COLUMN intensity TYPE TEXT
USING intensity::TEXT;

-- 2024-05-16
UPDATE combined_min
SET intensity = CASE 
	WHEN intensity = '0' THEN 'sedendary'
	WHEN intensity = '1' THEN 'lightly active'
	WHEN intensity = '2' THEN 'moderately active'
	WHEN intensity = '3' THEN 'very active' 
ELSE intensity END;

-- 2024-05-16
ALTER TABLE combined_min 
ALTER COLUMN mets TYPE NUMERIC
USING mets::NUMERIC;

-- 2024-05-16
-- move decimal one left
UPDATE combined_min
SET mets = ROUND(mets / 10, 1);

-- 2024-05-18
-- add all unique users
INSERT INTO data_viz (id)
SELECT DISTINCT id
FROM daily_activity
ORDER BY id;

-- 2024-05-18
-- add number of sleep logs
UPDATE data_viz d
SET days_logged = s.log_count
FROM (
    SELECT
        id,
        COUNT(DISTINCT log_id) AS log_count
    FROM sleep_min
    GROUP BY id
) s
WHERE d.id = s.id;

/* 2024-05-18 unnecessary colummn
-- 2024-05-18
-- inidcate if user has logged sleep or not
UPDATE data_viz
SET sleep_log = CASE WHEN days_logged IS NOT NULL THEN 'yes' ELSE 'no' END;
*/

-- 2024-05-18
-- add total days user has step data
UPDATE data_viz d
SET total_step_days = c.total_days
FROM (
	SELECT
	    id,
	    COUNT(DISTINCT DATE("timestamp")) AS total_days
	FROM combined_min
	GROUP BY id
) c
WHERE d.id = c.id;

-- 2024-05-18
-- add days with step count
UPDATE data_viz d
SET days_w_step_count = c.has_step_count
FROM (
	SELECT
	    id,
    	COUNT(DISTINCT CASE WHEN steps > 0 THEN DATE("timestamp") END) AS has_step_count
	FROM combined_min
	GROUP BY id
) c
WHERE d.id = c.id;

-- 2024-05-18
-- active = has step count 50+% of tracked days
-- sedentary = has step count less than 50% of tracked days
UPDATE data_viz d
SET user_type = c.user_type
FROM (
	SELECT
		id,
	    CASE WHEN step_percentage >= 50 THEN 'active' ELSE 'sedentary' END AS user_type
	FROM (
	    SELECT
	        id,
	        (COUNT(DISTINCT CASE WHEN steps > 0 THEN DATE("timestamp") END) * 100.0 / COUNT(DISTINCT DATE("timestamp"))) AS step_percentage
	    FROM combined_min
	    GROUP BY id
	)
) c
WHERE d.id = c.id;

-- 2024-05-18
-- don't really need sleep_log column, can just query days_sleep_logged as IS NULL or IS NOT NULL
ALTER TABLE data_viz DROP COLUMN sleep_log;
ALTER TABLE data_viz RENAME COLUMN days_logged TO days_sleep_logged;

-- 2024-05-18
-- add mets, intensity, and kcal (aka "other metrics") days count
-- add column for other metrics
ALTER TABLE data_viz
ADD COLUMN days_w_other_metrics INT;

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
UPDATE data_viz d
SET days_w_other_metrics = c.days_w_kcal_data
FROM (
	SELECT
		id,
		COUNT(DISTINCT CASE WHEN kcal_burned > 0 THEN DATE("timestamp") END) AS days_w_kcal_data
	FROM combined_min
	GROUP BY id
	) c
WHERE d.id = c.id;
INSERT INTO temp_table (id, "timestamp", steps)
SELECT 
	id,
	"timestamp",
	steps
FROM (
	SELECT id, "timestamp", steps, COUNT(*)
	FROM steps_min
	GROUP BY id, "timestamp", steps
	HAVING COUNT(*) > 1
);

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
UPDATE temp_table c
SET mets = m.mets
FROM (
	SELECT id, "timestamp", mets, COUNT(*)
	FROM mets_min
	GROUP BY id, "timestamp", mets
	HAVING COUNT(*) > 1
	) m
WHERE c.id = m.id AND c.timestamp = m.timestamp;

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
UPDATE temp_table c
SET intensity = i.intensity
FROM (
	SELECT id, "timestamp", intensity, COUNT(*)
	FROM intensity_min
	GROUP BY id, "timestamp", intensity
	HAVING COUNT(*) > 1
	) i
WHERE c.id = i.id AND c.timestamp = i.timestamp;

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
UPDATE temp_table c
SET kcal_burned = k.kcal_burned
FROM (
	SELECT id, "timestamp", kcal_burned, COUNT(*)
	FROM calories_min
	GROUP BY id, "timestamp", kcal_burned
	HAVING COUNT(*) > 1
	) k
WHERE c.id = k.id AND c.timestamp = k.timestamp;
INSERT INTO combined_min2 (id, "timestamp", steps)
SELECT 
	id,
	"timestamp",
	steps
FROM steps_min;

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
UPDATE combined_min2 c
SET mets = m.mets
FROM mets_min m
WHERE c.id = m.id AND c.timestamp = m.timestamp;

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
UPDATE combined_min2 c
SET intensity = i.intensity
FROM intensity_min i
WHERE c.id = i.id AND c.timestamp = i.timestamp;

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
UPDATE combined_min2 c
SET kcal_burned = k.kcal_burned
FROM calories_min k
WHERE c.id = k.id AND c.timestamp = k.timestamp;

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
-- add one copy of records back into new table from temp table
INSERT INTO combined_min2 (id, "timestamp", steps, mets, intensity, kcal_burned)
SELECT * FROM temp_table;

-- 2024-05-18
-- change column type from integer to text
ALTER TABLE combined_min2
ALTER COLUMN intensity TYPE TEXT
USING intensity::TEXT;

-- 2024-05-18
-- update integer values to correct text values
UPDATE combined_min2
SET intensity = CASE 
	WHEN intensity = '0' THEN 'sedendary'
	WHEN intensity = '1' THEN 'lightly active'
	WHEN intensity = '2' THEN 'moderately active'
	WHEN intensity = '3' THEN 'very active' 
ELSE intensity END;

-- 2024-05-18
-- change column type from integer to numeric
ALTER TABLE combined_min2
ALTER COLUMN mets TYPE NUMERIC
USING mets::NUMERIC;

-- 2024-05-18
-- update METS values (METS values are multiplied by 10 when exported from Fitbit)
UPDATE combined_min2
SET mets = ROUND(mets / 10, 1);

-- 2024-05-20
ALTER TABLE data_viz
ADD COLUMN days_heartrate INT;

-- 2024-05-20
UPDATE data_viz d
SET days_heartrate = h.date_count
FROM (
	SELECT
		id,
		COUNT(DISTINCT DATE("timestamp")) AS date_count
	FROM heartrate_sec
	GROUP BY id
) h
WHERE d.id = h.id;

-- 2024-05-20
-- previously removed id6391747486 data from data_viz
INSERT INTO data_viz (id, days_sleep_logged, user_type, total_step_days, days_w_step_count, days_w_other_metrics, days_heartrate)
VALUES (6391747486, 0, 'sedentary', 28, 2, 28, 3);

-- 2024-05-20
-- inacurate, not number of days it's number of logs
ALTER TABLE data_viz RENAME COLUMN days_sleep_logged to sleep_log_count;

-- 2024-05-20
UPDATE data_viz 
SET sleep_log_count = 0 WHERE sleep_log_count IS NULL;

-- 2024-05-20
UPDATE data_viz 
SET days_heartrate = 0 WHERE days_heartrate IS NULL;

-- 2024-05-26
ALTER TABLE data_viz
ADD COLUMN weight_log_count INT;

-- 2024-05-26
UPDATE data_viz d
SET weight_log_count = w.weight_log_count
FROM (
	SELECT
	    id,
    	COUNT(DISTINCT log_id) AS weight_log_count
	FROM weight
	GROUP BY id
) w
WHERE d.id = w.id;

-- 2024-05-27
-- add days with step count
UPDATE data_viz d
SET days_w_step_count = c.percent_w_steps
FROM (
	SELECT
		id,
		days_w_step_count * 100 / total_step_days AS percent_w_steps
	FROM data_viz
) c
WHERE d.id = c.id;


-- =========================
-- [SECTION 3] VERIFICATION
-- =========================


-- 2024-05-16
-- How many users?
SELECT COUNT(DISTINCT id)
FROM daily_activity;

-- 2024-05-17
-- How many days does each user have METs data for?
SELECT
	id,
	COUNT(DISTINCT CASE WHEN mets > 0 THEN DATE("timestamp") END) AS days_with_mets
FROM combined_min
GROUP BY id
ORDER BY days_with_mets;

-- 2024-05-17
-- Do Fitbit intensity categories align with METs values?
SELECT
    mets,
    intensity
FROM combined_min
WHERE
    (mets = '1.0' AND intensity != 'sedentary')
    OR (mets BETWEEN '1.1' AND '2.9' AND intensity != 'lightly active')
    OR (mets BETWEEN '3.0' AND '5.9' AND intensity != 'moderately active')
    OR (mets >= '6.0' AND intensity != 'very active');

-- 2024-05-17
-- null values
SELECT *
FROM daily_activity
WHERE logged_activities_distance IS NULL;
	
-- 2024-05-17
-- How many users?
SELECT COUNT(DISTINCT id)
FROM daily_activity;

-- 2024-05-18
-- How many days have data for each metric?
SELECT
	id,
	COUNT(DISTINCT CASE WHEN steps > 0 THEN DATE("timestamp") END) AS days_w_steps_data,
	COUNT(DISTINCT CASE WHEN mets > 0 THEN DATE("timestamp") END) AS days_w_mets_data,
	COUNT(DISTINCT CASE WHEN intensity IS NOT NULL THEN DATE("timestamp") END) AS days_w_intensity_data,
	COUNT(DISTINCT CASE WHEN kcal_burned > 0 THEN DATE("timestamp") END) AS days_w_kcal_data
FROM combined_min
GROUP BY id;

-- 2024-05-18
-- Do mets, intensity, and kcal all have the same amount of days containing data?
SELECT
	id,
	CASE 
		WHEN days_w_mets_data = days_w_intensity_data AND days_w_mets_data = days_w_kcal_data 
		THEN 'same' ELSE 'not same'
	END
FROM (
	SELECT
		id,
		COUNT(DISTINCT CASE WHEN steps > 0 THEN DATE("timestamp") END) AS days_w_steps_data,
		COUNT(DISTINCT CASE WHEN mets > 0 THEN DATE("timestamp") END) AS days_w_mets_data,
		COUNT(DISTINCT CASE WHEN intensity IS NOT NULL THEN DATE("timestamp") END) AS days_w_intensity_data,
		COUNT(DISTINCT CASE WHEN kcal_burned > 0 THEN DATE("timestamp") END) AS days_w_kcal_data
	FROM combined_min
	GROUP BY id
);

-- 2024-05-18
-- Do other metrics and total steps have same amount of days
SELECT
	id,
	CASE 
		WHEN total_step_days = days_w_other_metrics THEN 'same' ELSE 'not same'
	END
FROM data_viz;

-- 2024-05-18
-- figure out why user 2891001357 has all null fields
-- previously deleted from combined_min
SELECT COUNT(DISTINCT "date")
FROM sleep_min
WHERE id = '2891001357';
-- no data in sleep_min

-- 2024-05-18
SELECT COUNT(DISTINCT "date")
FROM mets_min
WHERE id = '2891001357';

-- 2024-05-18
SELECT COUNT(DISTINCT "date")
FROM steps_min
WHERE id = '2891001357';

-- 2024-05-18
SELECT COUNT(DISTINCT "date")
FROM calories_min
WHERE id = '2891001357';
-- single day of data (2016-04-05) in calories_min, mets_min and steps_min

-- 2024-05-18
SELECT COUNT(DISTINCT "date")
FROM daily_activity
WHERE id = '2891001357';
-- inconsistency in data, 8 days of step data in daily_activity vs 1 day in steps_min

-- 2024-05-18
-- How many days of data does each user have (in combined_min vs daily_activity table)?
-- How many days difference are between the two tables, if any?
SELECT 
	c.id,
	COUNT(DISTINCT DATE("timestamp")) AS combined_count,
	da.days_count AS daily_count,
	ABS(COUNT(DISTINCT DATE("timestamp")) - da.days_count) AS difference
FROM combined_min c
JOIN (
	SELECT
		id,
		COUNT(DISTINCT "date") AS days_count
	FROM daily_activity
	GROUP BY id
) da ON c.id = da.id
GROUP BY c.id, da.days_count
ORDER BY combined_count;

-- 2024-05-18
-- How many days of data does each user have?
SELECT 
	s.id,
	da.days_count AS daily_count,
	COUNT(DISTINCT DATE("timestamp")) AS steps_count,
	c.days_count AS combined_count
FROM steps_min s
JOIN (
	SELECT
		id,
		COUNT(DISTINCT "date") AS days_count
	FROM daily_activity
	GROUP BY id
) da ON s.id = da.id
JOIN (
	SELECT
		id,
		COUNT(DISTINCT DATE("timestamp")) AS days_count
	FROM combined_min
	GROUP BY id
) c ON s.id = c.id
GROUP BY s.id, da.days_count, c.days_count
ORDER BY s.id;

-- 2024-05-18
-- How many days of data does each user have?
SELECT 
	s.id,
	da.days_count AS daily_count,
	COUNT(DISTINCT DATE("timestamp")) AS steps_count,
	c.days_count AS combined_count
FROM steps_min s
JOIN (
	SELECT
		id,
		COUNT(DISTINCT "date") AS days_count
	FROM daily_activity
	GROUP BY id
) da ON s.id = da.id
JOIN (
	SELECT
		id,
		COUNT(DISTINCT DATE("timestamp")) AS days_count
	FROM combined_min2
	GROUP BY id
) c ON s.id = c.id
GROUP BY s.id, da.days_count, c.days_count
ORDER BY s.id

-- 2024-05-20
SELECT DISTINCT id
FROM heartrate_sec;

-- 2024-05-26
SELECT 
	id, 
	COUNT(DISTINCT log_id) AS log_id_count
FROM weight 
GROUP BY id;

-- 2024-05-26
SELECT
	COUNT(DISTINCT id)
FROM data_viz
WHERE total_step_days >= 30


-- =========================
-- [SECTION 4] REMOVAL
-- =========================


-- 2024-05-16
-- remove duplicates
DELETE FROM combined_min
WHERE ctid NOT IN (
	SELECT MIN(ctid)
	FROM combined_min
	GROUP BY id, "timestamp"
);

-- 2024-05-16
-- remove outlier based on single row assumption
DELETE FROM combined_min
WHERE id = '2891001357';

-- 2024-05-16
DELETE FROM sleep_min
WHERE ctid NOT IN (
	SELECT MIN(ctid)
	FROM sleep_min
	GROUP BY id, "timestamp"
);

-- 2024-05-16
DELETE FROM daily_activity
WHERE ctid NOT IN (
	SELECT MIN(ctid)
	FROM daily_activity
	GROUP BY id, "date"
);

-- 2024-05-18
-- delete outlier
DELETE FROM data_viz
WHERE id = '2891001357';

/* 2024-05-20: should've removed from combined_min2 analysis not data_viz table
-- 2024-05-18
-- has (sometimes significantly) less than 30+ days of data
DELETE FROM data_viz
WHERE id = '6391747486';
*/

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
-- delete all records (original and duplicate) from new table if match with temp table
DELETE FROM combined_min2
WHERE (id, "timestamp", steps, mets, intensity, kcal_burned) IN (
    SELECT *
    FROM temp_table
);

-- 2024-05-18
-- re: why are counts different in combined_min, steps_min, daily_activity?
DROP TEMP TABLE temp_table;

-- 2024-05-20
-- replaced with combined_min2
DROP TABLE combined_min;


-- =========================
-- [SECTION 5] ANALYIZATION
-- =========================


-- 2024-05-16
-- How many minutes did each user spend in each intensity?
SELECT
	id,
	COUNT(CASE WHEN intensity = 'sedendary' THEN 1 END) AS inactive_mins,
	COUNT(CASE WHEN intensity = 'lightly active' THEN 1 END) AS light_mins,
	COUNT(CASE WHEN intensity = 'moderately active' THEN 1 END) AS moderate_mins,
	COUNT(CASE WHEN intensity = 'very active' THEN 1 END) AS very_active_mins
FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
GROUP BY id;

-- 2024-05-16
-- How many sleep logs does each user have?
SELECT 
	DISTINCT id, 
	COUNT(DISTINCT log_id) AS log_count
FROM sleep_min
GROUP BY id
ORDER BY COUNT(DISTINCT log_id);

-- 2024-05-16
-- How many users log their distance?
SELECT COUNT(DISTINCT id)
FROM daily_activity
WHERE logged_activities_distance != 0;

-- 2024-05-16
-- How many users have days when they're completely sedentary?
SELECT COUNT(DISTINCT id)
FROM daily_activity
WHERE logged_activities_distance = 0
	AND distance_total = 0
	AND steps_total = 0;

-- 2024-05-16
-- Are there any users that are completely sendentary everyday?
SELECT
	DISTINCT id,
	COUNT(CASE WHEN steps_total = 0 AND distance_total = 0 THEN 1 END) AS zero_data_count,
	COUNT(CASE WHEN steps_total > 0 AND distance_total > 0  THEN 1 END) AS has_data_count
FROM daily_activity
GROUP BY id
HAVING COUNT(CASE WHEN steps_total = 0 AND distance_total = 0 THEN 1 END) > 0
	AND COUNT(CASE WHEN steps_total > 0 AND distance_total > 0  THEN 1 END) = 0;

-- 2024-05-17
-- How many users have at least one data entry with 0 steps?
SELECT COUNT(DISTINCT id)
FROM combined_min
WHERE steps = 0;

-- 2024-05-17
-- How many times does a user have 0 steps by day?
SELECT
	DISTINCT id,
	DATE("timestamp"),
	SUM(steps) AS total_steps,
	COUNT(CASE WHEN steps = 0 THEN 1 END) AS zero_step_count
FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
GROUP BY  id, DATE("timestamp")
ORDER BY id, DATE("timestamp");

-- 2024-05-17
-- How many days have step data per user?
-- How many days have 0 steps versus more than 0 steps?
SELECT
    id,
    COUNT(DISTINCT DATE("timestamp")) AS total_days,
    COUNT(DISTINCT CASE WHEN steps > 0 THEN DATE("timestamp") END) AS has_step_count,
    COUNT(DISTINCT CASE WHEN steps = 0 THEN DATE("timestamp") END) AS no_step_count
FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
GROUP BY id
ORDER BY COUNT(DISTINCT DATE("timestamp"));

-- 2024-05-17
-- What is the percentage of days each user has 0 steps or more than 0 steps?
SELECT
    id,
    COUNT(DISTINCT CASE WHEN steps > 0 THEN DATE("timestamp") END) * 100 / COUNT(DISTINCT DATE("timestamp")) AS percentage_has_step,
	COUNT(DISTINCT CASE WHEN steps = 0 THEN DATE("timestamp") END) * 100 / COUNT(DISTINCT DATE("timestamp")) AS percentage_no_step
FROM combined_min
GROUP BY id
ORDER BY COUNT(DISTINCT CASE WHEN steps > 0 THEN DATE("timestamp") END) * 100 / COUNT(DISTINCT DATE("timestamp"));

-- 2024-05-26
-- How many days are sedentary vs not sendentary (based on step count)?
SELECT
    id,
    sedentary_day_count,
    has_steps_day_count,
    total_day_count,
    (sedentary_day_count + has_steps_day_count) AS verify_total
FROM (
    SELECT
        id,
        COUNT(
            CASE WHEN logged_activities_distance = 0 
            AND distance_total = 0
            AND steps_total = 0 THEN 1 END) 
        AS sedentary_day_count,
        COUNT(
            CASE WHEN logged_activities_distance > 0 
            OR distance_total > 0
            OR steps_total > 0 THEN 1 END) 
        AS has_steps_day_count,
        COUNT(DISTINCT "date") AS total_day_count
    FROM daily_activity
    GROUP BY id
) AS activity_counts
WHERE total_day_count >= 30;

-- 2024-05-17
-- How many users have step counts more than 50% of tracked days (aka active_users)
-- How many have step counts less than 50% of tracked days (aka sedentary_users)?
SELECT
    SUM(CASE WHEN step_percentage >= 50 THEN 1 ELSE 0 END) AS active_users,
    SUM(CASE WHEN step_percentage < 50 THEN 1 ELSE 0 END) AS sedentary_users
FROM (
    SELECT
        id,
        (COUNT(DISTINCT CASE WHEN steps > 0 THEN DATE("timestamp") END) * 100.0 / COUNT(DISTINCT DATE("timestamp"))) AS step_percentage
    FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
    GROUP BY id
) AS subquery;

-- 2024-05-17
-- How many minutes out of all tracked days did users have a step count?
SELECT
	id,
	COUNT(DISTINCT DATE("timestamp")) AS total_days,
	COUNT(DISTINCT CASE WHEN steps > 0 THEN "timestamp" END) AS min_walked
FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
GROUP BY id
ORDER BY min_walked;

-- 2024-05-17
-- What is the average minutes walked per day by each user?
SELECT
    id,
	CAST(
		COUNT(DISTINCT CASE WHEN steps > 0 THEN "timestamp" END) / COUNT(DISTINCT DATE("timestamp"))
	AS NUMERIC) AS avg_min_walked_per_day
FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
GROUP BY id
ORDER BY avg_min_walked_per_day DESC;

-- 2024-05-17
-- How many minutes out of all tracked days did users have any step data?
SELECT
	id,
	COUNT(DISTINCT CASE WHEN steps >= 0 THEN "timestamp" END) AS min_walked
FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
GROUP BY id
ORDER BY min_walked DESC;

-- 2024-05-17
-- How many minutes is each user's METs in each grouping?
-- 1.0 METs resting | 1.1-2.9 METs light | 3-5.9 METs moderate | 6.0+ METs intense
SELECT
	id,
	COUNT(mets) AS total_mets_min,
	COUNT(DISTINCT CASE WHEN mets = '1.0' THEN "timestamp" END) AS resting_min,
	COUNT(DISTINCT CASE WHEN mets > '1.0' AND mets <= '2.9' THEN "timestamp" END) AS light_min,
	COUNT(DISTINCT CASE WHEN mets > '2.9' AND mets <= '5.9' THEN "timestamp" END) AS moderate_min,
	COUNT(DISTINCT CASE WHEN mets >= '6.0' THEN "timestamp" END) AS intense_min
FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
GROUP BY id
ORDER BY total_mets_min DESC;

-- 2024-05-17
-- What is the average minutes in 3-5.9 METs per day by each user?
SELECT
    id,
	CAST(
		COUNT(DISTINCT CASE WHEN mets > '2.9' AND mets <= '5.9' THEN "timestamp" END) / COUNT(mets)
	AS NUMERIC) AS avg_min_moderate_mets_per_day
FROM combined_min
GROUP BY id;

-- 2024-05-17
-- What is the average minutes in 1.0 METs per day by each user?
SELECT
    id,
	CAST(
		COUNT(DISTINCT CASE WHEN mets = '1.0' THEN "timestamp" END) / COUNT(mets)
	AS NUMERIC) AS avg_min_resting_mets_per_day
FROM combined_min2 -- 2024-05-26 updated combined_min to combined_min2
GROUP BY id
ORDER BY avg_min_resting_mets_per_day DESC;

-- 2024-05-26
-- What is the average minutes of each METs grouping per day by each user?
SELECT
    id,
	CAST(
		COUNT(DISTINCT CASE WHEN mets = '1.0' THEN "timestamp" END) / COUNT(mets)
	AS NUMERIC) AS avg_min_resting_mets_per_day,
	CAST(
		COUNT(DISTINCT CASE WHEN mets > '1.0' AND mets <= '2.9' THEN "timestamp" END) / COUNT(mets)
	AS NUMERIC) AS avg_min_light_mets_per_day,
	CAST(
		COUNT(DISTINCT CASE WHEN mets > '2.9' AND mets <= '5.9' THEN "timestamp" END) / COUNT(mets)
	AS NUMERIC) AS avg_min_moderate_mets_per_day,
	CAST(
		COUNT(DISTINCT CASE WHEN mets > '5.9' THEN "timestamp" END) / COUNT(mets)
	AS NUMERIC) AS avg_min_active_mets_per_day
FROM combined_min2
GROUP BY id
ORDER BY avg_min_resting_mets_per_day DESC;

-- 2024-05-17
-- How many minutes has kcal data for each user?
SELECT 
	id,
	COUNT(kcal_burned) AS kcal_min
FROM combined_min
GROUP BY id
ORDER BY kcal_min;

-- 2024-05-17
-- How many log IDs total?
SELECT COUNT(DISTINCT log_id)
FROM sleep_min;

-- 2024-05-17
-- Per user, how many minutes of sleep data do they have?
-- How many minutes in each sleep state?
SELECT
	id,
	COUNT("timestamp") AS total_min,
	COUNT(CASE WHEN sleep_state = '1' THEN 1 END) AS alseep_min,
	COUNT(CASE WHEN sleep_state = '2' THEN 1 END) AS restless_min,
	COUNT(CASE WHEN sleep_state = '3' THEN 1 END) AS awake_min,
	COUNT("timestamp") / 60 AS total_as_hour,
	(COUNT("timestamp") / 60) / 24 AS total_as_days
FROM sleep_min
GROUP BY id
ORDER BY total_min DESC;

-- 2024-05-17
-- How many logs does each user have?
SELECT
	DISTINCT id,
	COUNT(DISTINCT log_id) AS log_count
FROM sleep_min
GROUP BY id
ORDER BY log_count

-- 2024-05-17
-- How many total sleep users?
-- How many users have less than a week of logs? Less than a month?
-- How many users have a months worth of logs?
SELECT
	COUNT(*) AS total_users,
	SUM(CASE WHEN log_count = '1' THEN 1 END) AS one_log,
	SUM(CASE WHEN log_count <= '7' THEN 1 END) AS less_than_7,
	SUM(CASE WHEN log_count < '30' THEN 1 END) AS less_than_month,
	SUM(CASE WHEN log_count >= '30' THEN 1 END) AS month_or_more
FROM (
	SELECT
		DISTINCT id,
		COUNT(DISTINCT log_id) AS log_count
	FROM sleep_min
	GROUP BY id
) AS subquery;

-- 2024-05-17
-- Per user, how many minutes of sleep data do they have where they have 30+ logs?
-- How many minutes in each sleep state where they have 30+ logs?
SELECT
	id,
	COUNT("timestamp") AS total_min,
	COUNT(CASE WHEN sleep_state = '1' THEN 1 END) AS alseep_min,
	COUNT(CASE WHEN sleep_state = '2' THEN 1 END) AS restless_min,
	COUNT(CASE WHEN sleep_state = '3' THEN 1 END) AS awake_min,
	COUNT("timestamp") / 60 AS total_as_hour,
	(COUNT("timestamp") / 60) / 24 AS total_as_days
FROM sleep_min
GROUP BY id
HAVING COUNT(DISTINCT log_id) >= '30'
ORDER BY total_min DESC;

-- 2024-05-17
-- How many users log their distance?
SELECT COUNT(DISTINCT id)
FROM daily_activity
WHERE logged_activities_distance != 0;

-- 2024-05-17
-- How many users have days when they're completely sedentary?
SELECT COUNT(DISTINCT id)
FROM daily_activity
WHERE logged_activities_distance = 0
	AND distance_total = 0
	AND steps_total = 0;

-- 2024-05-17
-- Are there any users that are completely sendentary everyday?
SELECT
	DISTINCT id,
	COUNT(CASE WHEN steps_total = 0 AND distance_total = 0 THEN 1 END) AS zero_data_count,
	COUNT(CASE WHEN steps_total > 0 AND distance_total > 0  THEN 1 END) AS has_data_count
FROM daily_activity
GROUP BY id
HAVING COUNT(CASE WHEN steps_total = 0 AND distance_total = 0 THEN 1 END) > 0
	AND COUNT(CASE WHEN steps_total > 0 AND distance_total > 0  THEN 1 END) = 0;

-- 2024-05-20
-- How many days of data does each user have?
SELECT
	DISTINCT id,
	COUNT(DISTINCT DATE("timestamp")) AS date_count
FROM heartrate_sec
GROUP BY id
ORDER BY date_count;

-- 2024-05-20
-- How many users have 30+ days of data?
SELECT COUNT(*)
FROM (
	SELECT id
	FROM heartrate_sec
	GROUP BY id
	HAVING COUNT(DISTINCT DATE("timestamp")) >= 30
);

2891001357 : 0 sleepLogs, user_type, 0 daysWithStepData, 0 daysHaveStepCount, 0 daysWithOtherMetrics, 0 daysWithHeartrateData, 0 days sleepdata
6391747486 : 0 sleepLogs, sedentary, 28 daysWithStepData, 2 daysHaveStepCount, 28 daysWithOtherMetrics, 3 daysWithHeartrateData, 28 daysSleepData

-- 2024-05-26
-- out of active/sedentary users who is using sleep, heartrate, weight?
SELECT
	id,
	user_type,
	CASE WHEN sleep_log_count > 0 THEN 'yes' ELSE 'no' END AS tracks_sleep,
	CASE WHEN days_heartrate > 0 THEN 'yes' ELSE 'no' END AS tracks_heartrate,
	CASE WHEN weight_log_count IS NOT NULL THEN 'yes' ELSE 'no' END AS tracks_weight
FROM data_viz
ORDER BY user_type;

-- 2024-05-26
-- what is the average amount of days?
SELECT
	MIN(total_step_days) AS min_total_step,
	ROUND(AVG(total_step_days), 1) AS avg_total_step,
	MAX(total_step_days) AS max_total_step
FROM data_viz -- 26,51,59
WHERE id != '6391747486' -- 26,51.7,59 (33 users)
WHERE total_step_days >= 30 -- 34,52.5,59 (32 users)
;

-- 2024-05-26
SELECT
	MIN(days_w_step_count) AS min_step_count,
	ROUND(AVG(days_w_step_count), 1) AS avg_step_count,
	MAX(days_w_step_count) AS max_step_count
FROM data_viz -- 2,25.2,45
WHERE id != '6391747486' -- 5,25.9,45 (33 users)
WHERE days_w_step_count >= 30 -- 31,35.7,45
;

-- 2024-05-26
SELECT COUNT(DISTINCT id)
FROM data_viz
WHERE days_w_step_count >= 30; -- 15

-- 2024-05-26
SELECT
	MIN(days_w_other_metrics) AS min_o_metrics,
	ROUND(AVG(days_w_other_metrics), 1) AS avg_o_metrics,
	MAX(days_w_other_metrics) AS max_o_metrics
FROM data_viz -- 26,51,59
WHERE id != '6391747486' -- 26,51.7,59 (33 users)
WHERE days_w_other_metrics >= 30 -- 34, 52.5,59
;

-- 2024-05-26
SELECT COUNT(DISTINCT id)
FROM data_viz
WHERE days_w_other_metrics >= 30; -- 32

-- 2024-05-26
-- what is the average step count per user?
SELECT
    id,
    ROUND(AVG(sum_steps), 2) AS avg_steps
FROM (
    SELECT
        id,
        SUM(steps) AS sum_steps,
        DATE("timestamp") AS date_part
    FROM combined_min2
	GROUP BY id, date_part
) AS steps_date
GROUP BY id
ORDER BY avg_steps DESC;

-- 2024-05-27
-- what is the average METs per user?
SELECT
    id,
    ROUND(AVG(mets_sum), 2) AS avg_mets
FROM (
    SELECT
        id,
        sum(mets) as mets_sum,
        DATE("timestamp") AS date_part
    FROM combined_min2
	GROUP BY id, date_part
) AS mets_date
GROUP BY id
ORDER BY avg_mets DESC;

-- 2024-05-27
-- What is the average amount of minutes (for the entire sample) for METs and intensity?
-- 1.0 METs resting | 1.1-2.9 METs light | 3-5.9 METs moderate | 6.0+ METs intense
SELECT
	date_count,
	count(distinct id) AS id_count,
	ROUND(AVG(total_mets_min), 1) AS total_mets_avg,
	ROUND(AVG(light_m_min), 1) AS light_mets_avg,
	ROUND(AVG(moderate_m_min), 1) AS moderate_mets_avg,
	ROUND(AVG(intense_m_min), 1) AS intense_mets_avg,
	ROUND(AVG(total_intensity_min), 1) AS total_intensity_avg,
	ROUND(AVG(sedentary_i_min), 1) AS sedentary_intensity_avg,
	ROUND(AVG(light_i_min), 1) AS light_intensity_avg,
	ROUND(AVG(moderate_i_min), 1) AS moderate_intensity_avg,
	ROUND(AVG(intense_i_min), 1) AS active_intensity_avg
FROM (
	SELECT
		id,
		COUNT(DISTINCT DATE("timestamp")) AS date_count,
		COUNT(mets) AS total_mets_min,
		COUNT(DISTINCT CASE WHEN mets = '1.0' THEN "timestamp" END) AS resting_m_min,
		COUNT(DISTINCT CASE WHEN mets > '1.0' AND mets <= '2.9' THEN "timestamp" END) AS light_m_min,
		COUNT(DISTINCT CASE WHEN mets > '2.9' AND mets <= '5.9' THEN "timestamp" END) AS moderate_m_min,
		COUNT(DISTINCT CASE WHEN mets >= '6.0' THEN "timestamp" END) AS intense_m_min,
		COUNT(intensity) AS total_intensity_min,
		COUNT(DISTINCT CASE WHEN intensity = 'sedendary' THEN "timestamp" END) AS sedentary_i_min,
		COUNT(DISTINCT CASE WHEN intensity = 'lightly active' THEN "timestamp" END) AS light_i_min,
		COUNT(DISTINCT CASE WHEN intensity = 'moderately active' THEN "timestamp" END) AS moderate_i_min,
		COUNT(DISTINCT CASE WHEN intensity = 'very active' THEN "timestamp" END) AS intense_i_min
	FROM combined_min2
	GROUP BY id
	HAVING id != '2891001357' OR id != '6391747486'
) AS subquery
GROUP BY date_count
HAVING date_count >= 30;


