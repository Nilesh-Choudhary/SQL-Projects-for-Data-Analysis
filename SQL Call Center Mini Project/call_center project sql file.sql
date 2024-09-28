-- Create the database
create database call_center;

--  Use the created database
use call_center;

show tables;

-- Note: In MySQL Workbench, you would now use the "Table Data Import Wizard" to import data from a CSV file into a table.

-- Import data from the CSV file using the Table Data Import Wizard
-- (In MySQL Workbench, go to Server -> Data Import -> Import from CSV File)

--  ------------------------------------------------------------------------------Data Inspection----------------------------------------------------------------------------------------

select * from `call center`;

alter table `call center`
rename 	mytable;

-- Check the number of rows
SELECT COUNT(*) AS rows_num FROM mytable;

# lets see data 
SELECT * FROM mytable LIMIT 10;

describe mytable;

 -- ----------------------------------------------------------------------------- Cleaning our data ---------------------------------------------------------------------------------------------------------

SET SQL_SAFE_UPDATES = 0;

UPDATE mytable SET call_timestamp = str_to_date(call_timestamp, "%m/%d/%Y");

UPDATE mytable SET csat_score = NULL WHERE csat_score = 0;

SET SQL_SAFE_UPDATES = 1;

SELECT * FROM mytable LIMIT 10;

describe mytable;

select call_timestamp,date(call_timestamp) from mytable;

-- ----------------------------------------------------------------------------- Exploring our data ------------------------------------------------------------------------------------------------------------------

-- lets see the shape pf our data, i.e, the number of columns and rows
SELECT COUNT(*) AS rows_num FROM mytable;
SELECT COUNT(*) AS cols_num FROM information_schema.columns WHERE table_name = 'mytable' ;

# -- Checking the distinct values of some columns:

SELECT DISTINCT sentiment FROM mytable;
SELECT DISTINCT reason FROM mytable;
SELECT DISTINCT channel FROM mytable;
SELECT DISTINCT response_time FROM mytable;
SELECT DISTINCT call_center FROM mytable;

-- The count and precentage from total of each of the distinct values we got:
SELECT sentiment, COUNT(*) AS count,ROUND((COUNT(*) / (SELECT COUNT(*) FROM mytable)) * 100, 1) AS pct
FROM mytable GROUP BY sentiment ORDER BY pct DESC;


SELECT reason, count(*), ROUND((COUNT(*) / (SELECT COUNT(*) FROM mytable)) * 100, 1) AS pct
FROM mytable GROUP BY reason ORDER BY pct DESC;

SELECT channel, COUNT(*) AS count,ROUND((COUNT(*) / (SELECT COUNT(*) FROM mytable)) * 100, 1) AS pct
FROM mytable GROUP BY channel ORDER BY pct DESC;


SELECT response_time,COUNT(*) AS count,ROUND((COUNT(*) / (SELECT COUNT(*) FROM mytable)) * 100, 1) AS pct
FROM mytable GROUP BY response_time ORDER BY pct DESC;


SELECT call_center, COUNT(*) AS count,ROUND((COUNT(*) / (SELECT COUNT(*) FROM mytable)) * 100, 1) AS pct
FROM mytable GROUP BY call_center ORDER BY pct DESC;


SELECT state, COUNT(*) FROM mytable GROUP BY 1 ORDER BY 2 DESC;

SELECT DAYNAME(call_timestamp) as Day_of_call, COUNT(*) num_of_calls FROM mytable GROUP BY 1 ORDER BY 2 DESC;

-- ------------------------------------------------------------------------ Aggregations----------------------------------------------------------------------------------------------------------------

SELECT MIN(csat_score) AS min_score, MAX(csat_score) AS max_score, ROUND(AVG(csat_score),1) AS avg_score
FROM mytable WHERE csat_score != 0;

SELECT MIN(call_timestamp) AS earliest_date, MAX(call_timestamp) AS most_recent FROM mytable;

SELECT MIN(`call duration in minutes`) AS min_call_duration,MAX(`call duration in minutes`) AS max_call_duration,AVG(`call duration in minutes`) AS avg_call_duration FROM mytable;

SELECT call_center, response_time, COUNT(*) AS count
FROM mytable GROUP BY 1,2 ORDER BY 1,3 DESC;

SELECT call_center,AVG(`call duration in minutes`) AS avg_call_duration
FROM mytable GROUP BY call_center ORDER BY avg_call_duration DESC;

SELECT channel, AVG(`call duration in minutes`) AS avg_call_duration
FROM mytable GROUP BY channel ORDER BY avg_call_duration DESC;

SELECT state, COUNT(*) FROM mytable GROUP BY 1 ORDER BY 2 DESC;

SELECT state, reason, COUNT(*) FROM mytable GROUP BY 1,2 ORDER BY 1,2,3 DESC;

SELECT state, sentiment , COUNT(*) FROM mytable GROUP BY 1,2 ORDER BY 1,3 DESC;

SELECT state, AVG(csat_score) as avg_csat_score FROM mytable WHERE csat_score != 0 GROUP BY 1 ORDER BY 2 DESC;

SELECT sentiment, AVG(`call duration in minutes`) AS avg_call_duration
FROM mytable GROUP BY sentiment ORDER BY avg_call_duration DESC;

SELECT call_timestamp,MAX(`call duration in minutes`) OVER(PARTITION BY call_timestamp) AS max_call_duration
FROM mytable ORDER BY max_call_duration DESC;


-- ----------------------------------------------------------------------------- Insightful Queries ------------------------------------------------------------------------------------------------------------------
-- Distribution of Calls by City:
SELECT city, COUNT(*) AS count, ROUND((COUNT(*) / (SELECT COUNT(*) FROM mytable)) * 100, 1) AS pct
FROM mytable GROUP BY city ORDER BY count DESC;


-- Average CSAT Score by Call Center:
SELECT call_center, AVG(csat_score) AS avg_csat_score
FROM mytable WHERE csat_score IS NOT NULL GROUP BY call_center ORDER BY avg_csat_score DESC;


-- Total and Average Call Duration by State:
SELECT state,SUM(`call duration in minutes`) AS total_call_duration, AVG(`call duration in minutes`) AS avg_call_duration
FROM mytable GROUP BY state ORDER BY total_call_duration DESC;


-- Sentiment Breakdown by Channel:
SELECT channel, sentiment, COUNT(*) AS count
FROM mytable GROUP BY channel, sentiment ORDER BY channel, count DESC;


-- Response Time Analysis by Call Center:
SELECT call_center, response_time, COUNT(*) AS count
FROM mytable GROUP BY call_center, response_time ORDER BY call_center, response_time;


-- Average Call Duration by Reason:
SELECT reason, AVG(`call duration in minutes`) AS avg_call_duration
FROM mytable GROUP BY reason ORDER BY avg_call_duration DESC;


-- Monthly Call Volume:
SELECT DATE_FORMAT(call_timestamp, '%Y-%m') AS month, COUNT(*) AS call_volume
FROM mytable GROUP BY month ORDER BY month DESC;

-- Call Volume by Day of the Week:
SELECT DAYNAME(call_timestamp) AS day_of_week, COUNT(*) AS call_volume
FROM mytable GROUP BY day_of_week ORDER BY FIELD(day_of_week, 'Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');


-- Call Volume by Hour of the Day:
SELECT HOUR(call_timestamp) AS hour_of_day, COUNT(*) AS call_volume
FROM mytable GROUP BY hour_of_day ORDER BY hour_of_day;


-- Correlation Between Call Duration and CSAT Score:
SELECT `call duration in minutes` AS call_duration, AVG(csat_score) AS avg_csat_score
FROM mytable WHERE csat_score IS NOT NULL GROUP BY `call duration in minutes` ORDER BY call_duration;


-- Analysis of Billing Question Calls:
SELECT state, COUNT(*) AS billing_call_count, AVG(`call duration in minutes`) AS avg_call_duration
FROM mytable WHERE reason = 'Billing Question' GROUP BY state ORDER BY billing_call_count DESC;


-- Call Center Performance Comparison:

SELECT call_center, SUM(CASE WHEN sentiment = 'Very Positive' THEN 1 ELSE 0 END) AS very_positive_count, SUM(CASE WHEN sentiment = 'Very Negative' THEN 1 ELSE 0 END) AS very_negative_count,
AVG(`call duration in minutes`) AS avg_call_duration,AVG(csat_score) AS avg_csat_score
FROM mytable GROUP BY call_center ORDER BY very_positive_count DESC, very_negative_count ASC;


-- Service Outage Call Analysis:
SELECT state, COUNT(*) AS service_outage_calls, AVG(`call duration in minutes`) AS avg_call_duration
FROM mytable WHERE reason = 'Service Outage' GROUP BY state ORDER BY service_outage_calls DESC;


-- Sentiment Analysis by State:
SELECT state, sentiment, COUNT(*) AS count
FROM mytable GROUP BY state, sentiment ORDER BY state, count DESC;


-- Response Time Impact on CSAT Score:
SELECT response_time, AVG(csat_score) AS avg_csat_score
FROM mytable WHERE csat_score IS NOT NULL GROUP BY response_time ORDER BY avg_csat_score DESC;





