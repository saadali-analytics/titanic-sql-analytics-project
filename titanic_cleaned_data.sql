-- =========================================
-- 1. CREATE DATABASE
-- =========================================

DROP DATABASE titanicDatabase;

CREATE DATABASE titanicDatabase;
GO

-- Switch context to the new database
USE titanicDatabase;
GO

-- View system tables (to check current DB objects)
SELECT * FROM sys.tables;


-- =========================================
-- 2. CREATE TABLE (SAFE DROP FIRST)
-- =========================================

-- Drop table if it already exists to avoid errors
DROP TABLE IF EXISTS titanic_dataset;

-- Create Titanic dataset table
CREATE TABLE titanic_dataset 
(
    passengerID INT PRIMARY KEY,     -- Unique ID for each passenger
    isSurvivor CHAR(1),             -- Survival flag (Y/N after cleaning)
    ticketClass INT,            -- Passenger class (First/Second/Third)
    passengerName VARCHAR(100),    -- Full name of passenger
    gender VARCHAR(10),            -- Gender (M/F after transformation)
    age VARCHAR(5),                -- Age of passenger
    sibling_or_spouse INT,         -- Number of siblings/spouse onboard
    parent_or_child INT,           -- Number of parents/children onboard
    ticket VARCHAR(20),            -- Ticket number
    ticketPrice FLOAT,             -- Fare paid for ticket
    cabin VARCHAR(50),             -- Cabin number
    portAboarded VARCHAR(20)       -- Embarkation port (C/Q/S converted later)
);


-- =========================================
-- 3. CLEAR TABLE DATA (IF RE-RUNNING SCRIPT)
-- =========================================

TRUNCATE TABLE titanic_dataset;


-- =========================================
-- 4. BULK INSERT DATA FROM CSV FILE
-- =========================================

BULK INSERT titanic_dataset 
FROM "D:\titanic_dataset.csv"
WITH
(
    FORMAT = 'CSV',          -- CSV file format
    FIRSTROW = 2,            -- Skip header row
    FIELDQUOTE = '"',        -- Treat quoted text as single value (important for names with commas)
    FIELDTERMINATOR = ',',   -- Column separator
    ROWTERMINATOR = '\n'     -- Row separator
);


-- *********************************************************************************
-- Data CLeaning 
-- *********************************************************************************

-- View first 5 rows
SELECT TOP 5 * FROM titanic_dataset;

-- Check unique values in columns before updating them. 

SELECT DISTINCT isSurvivor FROM titanic_dataset;
SELECT DISTINCT portAboarded FROM titanic_dataset;
SELECT DISTINCT ticketClass FROM titanic_dataset;


-- =========================================
-- TRANSFORMATION
-- =========================================

UPDATE titanic_dataset
SET

-- Convert survival flag from 1/0 ? Y/N
isSurvivor = 
CASE 
    WHEN isSurvivor = '1' THEN 'Y'
    ELSE 'N'
END,

-- Replace NULL cabin values with 'NA'
cabin =
CASE 
    WHEN cabin IS NULL THEN 'NA'
    ELSE cabin 
END,

-- Convert port codes to full names
portAboarded = 
CASE 
    WHEN portAboarded = 'Q' THEN 'Queenstown'
    WHEN portAboarded = 'S' THEN 'Southampton'
    WHEN portAboarded = 'C' THEN 'Cherbourg'
END,

-- Round ticket price to 2 decimal places
ticketPrice = ROUND(ticketPrice, 2),

-- Convert gender to short form
gender = 
CASE 
    WHEN gender = 'male' THEN 'M'
    ELSE 'F'
END;


-- Convert ticket class into Categories


ALTER TABLE titanic_dataset
ADD ticketClassAbrv VARCHAR(20);

UPDATE titanic_dataset
SET ticketClassAbrv = 
CASE 
    WHEN ticketClass = 1 THEN 'First Class'
    WHEN ticketClass = 2 THEN 'Second Class'
    ELSE 'Third Class'
END;



-- =========================================
-- AGE DATA ANALYSIS
-- =========================================


-- Count missing age values (NULLs)

SELECT COUNT(*) 
FROM titanic_dataset
WHERE age IS NULL;


-- Result: 177 rows have missing age values


--Replace NULL with NA first. 

UPDATE titanic_dataset
SET age = ISNULL(age,'NA');


-- Calculate median where Age is not NULL 

SELECT PERCENTILE_CONT(0.5)
WITHIN GROUP (ORDER BY CAST(age as DECIMAL(5,2))) OVER()
from titanic_dataset
WHERE age <> 'NA';

--28 is the Median Age.


--Create a New Column 

ALTER TABLE titanic_dataset
ADD  ageImputed DECIMAL(5,2);

UPDATE titanic_dataset
SET ageImputed = 
CASE 
    WHEN age <> 'NA' THEN CAST(age as DECIMAL(5,2)) 
    ELSE 28
END;


-- Get basic statistics of age column


SELECT 
    MIN(ageImputed) AS MinAge,
    MAX(ageImputed) AS MaxAge,
    AVG(ageImputed) AS AvgAge
FROM titanic_dataset;

-- Result:
-- Min = 0.42, Max = 80, Avg ? 29.3


-- =========================================
-- CREATE AGE GROUP COLUMN
-- =========================================

ALTER TABLE titanic_dataset 
ADD ageGroup VARCHAR(20);

-- Categorize passengers into age groups
UPDATE titanic_dataset
SET ageGroup = 
CASE 
    WHEN (ageImputed >0 AND ageImputed<=10) THEN 'Child 1-10'
    WHEN (ageImputed >10 AND ageImputed<=18) THEN 'Teenager 11-18'
    WHEN (ageImputed >18 AND ageImputed<=40) THEN 'Adult 19-40'
    WHEN (ageImputed >40 AND ageImputed<=55) THEN 'Middle Aged 41-55'
    WHEN ageImputed > 55 THEN 'Elderly >55'
END;


-- Verify age group distribution
SELECT DISTINCT ageGroup 
FROM titanic_dataset;

-- =========================================
-- PASSENGER NAME CLEANING
-- =========================================

-- Add new columns for splitting full name

ALTER TABLE titanic_dataset 
ADD firstName VARCHAR(100),
    lastName VARCHAR(30);


-- =========================================
-- SPLIT FULL NAME INTO FIRST & LAST NAME
-- =========================================

UPDATE titanic_dataset 
SET 
    -- Extract last name (before comma)
    lastName = SUBSTRING(
        TRIM(passengerName),
        1,
        CHARINDEX(',', TRIM(passengerName)) - 1
    ),

    -- Extract first name (after comma)
    firstName = SUBSTRING(
        TRIM(passengerName),
        CHARINDEX(',', TRIM(passengerName)) + 1,
        LEN(TRIM(passengerName))
    );



ALTER TABLE titanic_dataset 
ADD familySize INT,
    cabinDeck CHAR(1),
    ticketCategory VARCHAR(15);


-- =======================================================
-- CALCULATE TOTAL FAMILY SIZE
-- =======================================================

UPDATE titanic_dataset
SET familySize = sibling_or_spouse+parent_or_child;

-- =======================================================
-- EXTRACT CABIN DECK
-- =======================================================

-- Extract first letter of cabin

UPDATE titanic_dataset
SET cabinDeck = LEFT(cabin,1)
WHERE cabin <> 'NA';


-- Replace missing cabins with N

UPDATE titanic_dataset
SET cabinDeck = 'N'
WHERE cabin = 'NA';


-- Verify deck distribution

SELECT COUNT(*),cabinDeck
FROM titanic_dataset
GROUP BY cabinDeck
ORDER BY COUNT(*) DESC;

-- =======================================================
-- CALCULATE FAIR BANDS
-- =======================================================

WITH percentile_based_bands AS
(
     SELECT DISTINCT
     PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ticketPrice) OVER() AS low_tier,
     PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ticketPrice) OVER() AS mid_tier,
     PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY ticketPrice) OVER() AS high_tier
     FROM titanic_dataset
)
SELECT count(*),
CASE 
WHEN ticketPrice<=low_tier THEN 'LOW'
WHEN ticketPrice>low_tier and ticketPrice<=mid_tier THEN 'MID'
WHEN ticketPrice>mid_tier and ticketPrice<=high_tier THEN 'HIGH'
ELSE 'TOO HIGH'
END 
FROM titanic_dataset 
CROSS JOIN percentile_based_bands
GROUP BY 
CASE 
WHEN ticketPrice<=low_tier THEN 'LOW'
WHEN ticketPrice>low_tier and ticketPrice<=mid_tier THEN 'MID'
WHEN ticketPrice>mid_tier and ticketPrice<=high_tier THEN 'HIGH'
ELSE 'TOO HIGH'
END;




---- UPDATE TICKET CATEGORY COLUMN

with percentile_based_bands AS
(
     SELECT DISTINCT
     PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY ticketPrice) OVER() AS low_tier,
     PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY ticketPrice) OVER() AS mid_tier,
     PERCENTILE_CONT(0.90) WITHIN GROUP (ORDER BY ticketPrice) OVER() AS high_tier
     FROM titanic_dataset
)
UPDATE titanic_dataset
SET ticketCategory = 
CASE 
WHEN ticketPrice<=low_tier THEN 'LOW'
WHEN ticketPrice>low_tier and ticketPrice<=mid_tier THEN 'MID'
WHEN ticketPrice>mid_tier and ticketPrice<=high_tier THEN 'HIGH'
ELSE 'TOO HIGH'
END 
FROM titanic_dataset 
CROSS JOIN percentile_based_bands;

--========================================================
--END
--========================================================