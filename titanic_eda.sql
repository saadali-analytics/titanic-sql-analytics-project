-- *********************************************************************************
-- Data Exploration 
-- *********************************************************************************

-- =========================================
-- PREVIEW CLEANED DATASET
-- =========================================

SELECT TOP 5
    passengerID,
    isSurvivor,
    firstName,
    gender,
    ageImputed,
    ageGroup,
    familySize,
    ticketPrice,
    ticketClass,
    ticketClassAbrv,
    ticketCategory,
    cabinDeck,
    portAboarded
FROM titanic_dataset;


-- =========================================
-- HIGH-LEVEL DATASET STATISTICS
-- =========================================

SELECT 'Total Passengers' AS Stats,
       COUNT(passengerID) AS Count
FROM titanic_dataset
UNION ALL
SELECT 'Total Survivors',
       COUNT(*)
FROM titanic_dataset
WHERE isSurvivor = 'Y'
UNION ALL
SELECT 'Total Passengers with Family Members',
       COUNT(passengerID)
FROM titanic_dataset
WHERE familySize > 1
UNION ALL
SELECT 'Median Age',
       (
           SELECT DISTINCT
               PERCENTILE_CONT(0.5)
               WITHIN GROUP (ORDER BY ageImputed) OVER ()
           FROM titanic_dataset
       )
UNION ALL
SELECT ageGroup,
       COUNT(ageGroup)
FROM titanic_dataset
GROUP BY ageGroup
UNION ALL
SELECT ticketClassAbrv,
       COUNT(ticketClassAbrv)
FROM titanic_dataset
GROUP BY ticketClassAbrv
UNION ALL
SELECT ticketCategory,
       COUNT(ticketCategory)
FROM titanic_dataset
GROUP BY ticketCategory
UNION ALL
SELECT gender,
       COUNT(gender)
FROM titanic_dataset
GROUP BY gender;


-- =========================================
-- PASSENGERS BY GENDER
-- =========================================

-- Male passengers accounted for approximately 65% of all passengers, while females represented 35%.

SELECT
    gender,
    COUNT(gender) AS count_by_type,

    CAST(
        COUNT(gender) * 100.00 /
        SUM(COUNT(*)) OVER ()
    AS DECIMAL(3,0)) AS pct_of_grand_total
FROM titanic_dataset
GROUP BY gender;


-- =========================================
-- SURVIVAL DISTRIBUTION
-- =========================================

-- Approximately 38% of passengers survived, while 62% did not survive.

SELECT
    isSurvivor,
    COUNT(isSurvivor) AS count_by_type,

    CAST(
        COUNT(isSurvivor) * 100.00 /
        SUM(COUNT(*)) OVER ()
    AS DECIMAL(3,0)) AS pct_of_grand_total
FROM titanic_dataset
GROUP BY isSurvivor;


-- =========================================
-- SURVIVORS BY GENDER
-- =========================================

-- Female passengers represented nearly 68% of all survivors despite being a minority onboard.

SELECT
    gender,
    COUNT(gender) AS count_by_type,

    CAST(
        COUNT(gender) * 100.00 /
        SUM(COUNT(gender)) OVER ()
    AS DECIMAL(5,2)) AS pct_of_grand_total
FROM titanic_dataset
WHERE isSurvivor = 'Y'
GROUP BY gender;


-- =========================================
-- SURVIVAL PROBABILITY BY GENDER
-- =========================================

-- Approximately 74% of female passengers survived, compared to only 19% of male passengers.

SELECT
    gender,
    pct_grand_total

FROM
(
    SELECT
        gender,
        isSurvivor,
        COUNT(gender) AS count_by_type,

        CAST(
            COUNT(gender) * 100.00 /
            SUM(COUNT(gender)) OVER (PARTITION BY gender)
        AS DECIMAL(3,0)) AS pct_grand_total

    FROM titanic_dataset
    GROUP BY gender, isSurvivor
) t

WHERE isSurvivor = 'Y'
ORDER BY gender;


-- =========================================
-- SURVIVAL BY GENDER AND AGE GROUP
-- =========================================

-- Elderly female passengers demonstrated the highest survival ratio among females.
-- Male children showed better survival outcomes compared to adult and elderly male passengers.

SELECT
    gender,
    ageGroup,
    pct_grand_total

FROM
(
    SELECT
        gender,
        isSurvivor,
        ageGroup,
        COUNT(*) AS count_by_type,

        SUM(COUNT(gender)) OVER (PARTITION BY gender)
            AS total_gender_count,

        CAST(
            COUNT(gender) * 100.00 /
            SUM(COUNT(gender)) OVER (PARTITION BY gender, ageGroup)
        AS DECIMAL(3,0)) AS pct_grand_total

    FROM titanic_dataset
    GROUP BY gender, isSurvivor, ageGroup
) t
WHERE isSurvivor = 'Y'
ORDER BY pct_grand_total DESC;


-- =========================================
-- SURVIVAL BY AGE GROUP
-- =========================================

-- Children experienced the highest survival rates among all age groups.

SELECT
    ageGroup,
    total_survivors,
    pct_of_grand_total_per_class
FROM
(
    SELECT
        ageGroup,
        isSurvivor,

        COUNT(isSurvivor) AS total_survivors,

        CAST(
            COUNT(isSurvivor) * 100.00 /
            SUM(COUNT(isSurvivor)) OVER (PARTITION BY ageGroup)
        AS DECIMAL(3,0)) AS pct_of_grand_total_per_class

    FROM titanic_dataset
    GROUP BY ageGroup, isSurvivor
) t
WHERE isSurvivor = 'Y'
ORDER BY pct_of_grand_total_per_class DESC;


-- =========================================
-- SURVIVAL BY GENDER, AGE GROUP, AND CLASS
-- =========================================

-- Female passengers in First and Second Class achieved extremely high survival rates.
-- Male passengers in Third Class experienced the lowest survival probabilities.
-- Third Class male children had significantly lower survival rates compared to children in higher classes.

SELECT
    gender,
    ageGroup,
    ticketClassAbrv,
    pct_grand_total

FROM
(
    SELECT
        gender,
        isSurvivor,
        ageGroup,
        ticketClassAbrv,

        COUNT(*) AS count_by_type,

        SUM(COUNT(*)) OVER
        (
            PARTITION BY gender, ageGroup, ticketClassAbrv
        ) AS total_gender_count,

        CAST(
            COUNT(*) * 100.00 /
            SUM(COUNT(gender)) OVER
            (
                PARTITION BY gender, ageGroup, ticketClassAbrv
            )
        AS DECIMAL(3,0)) AS pct_grand_total

    FROM titanic_dataset
    GROUP BY gender,
             isSurvivor,
             ageGroup,
             ticketClassAbrv
) t

WHERE isSurvivor = 'Y'
ORDER BY gender,
         ticketClassAbrv,
         pct_grand_total DESC;


-- =========================================
-- MEDIAN TICKET PRICE BY EMBARKATION PORT
-- =========================================

-- Southampton had the highest passenger volume.
-- Cherbourg passengers paid the highest median fares,especially in First Class.
-- Queenstown passengers were predominantly associated with Third Class travel.

SELECT
    portAboarded,
    ticketClassAbrv,
    COUNT(*) AS total_customers,
    median_price

FROM
(
    SELECT
        portAboarded,
        ticketClassAbrv,

        PERCENTILE_CONT(0.5)
        WITHIN GROUP (ORDER BY ticketPrice)
        OVER
        (
            PARTITION BY portAboarded, ticketClassAbrv
        ) AS median_price

    FROM titanic_dataset
    WHERE portAboarded IS NOT NULL
) t

GROUP BY
    portAboarded,
    ticketClassAbrv,
    median_price

ORDER BY
    ticketClassAbrv,
    median_price DESC;


-- =========================================
-- PASSENGERS BY EMBARKATION PORT
-- =========================================

-- Southampton accounted for approximately 65%
-- of all passengers onboard.

SELECT
    portAboarded,
    COUNT(*) AS total_passengers,

    CAST(
        COUNT(*) * 100.00 /
        SUM(COUNT(*)) OVER ()
    AS DECIMAL(10,0)) AS pct_of_grand_total
FROM titanic_dataset
GROUP BY portAboarded
ORDER BY pct_of_grand_total DESC;


-- =========================================
-- SURVIVAL BY PASSENGER CLASS
-- =========================================

-- First Class passengers achieved significantly
-- higher survival rates compared to Second and Third Class.

SELECT
    ticketClassAbrv,
    total_survivors,
    pct_of_grand_total_per_class

FROM
(
    SELECT
        ticketClassAbrv,
        isSurvivor,

        COUNT(isSurvivor) AS total_survivors,

        CAST(
            COUNT(isSurvivor) * 100.00 /
            SUM(COUNT(isSurvivor)) OVER
            (
                PARTITION BY ticketClassAbrv
            )
        AS DECIMAL(3,0)) AS pct_of_grand_total_per_class

    FROM titanic_dataset
    GROUP BY ticketClassAbrv, isSurvivor
) t

WHERE isSurvivor = 'Y'
ORDER BY pct_of_grand_total_per_class DESC;


-- =========================================
-- TOP FARE-PAYING PASSENGERS
-- =========================================

SELECT TOP 5
    passengerID,
    isSurvivor,
    firstName,
    lastName,
    ticketClass,
    gender,
    age,
    sibling_or_spouse,
    parent_or_child,
    ticketPrice,
    portAboarded,
    ageGroup
FROM titanic_dataset
ORDER BY ticketPrice DESC;


-- =========================================
-- SURVIVAL BASED ON FAMILY MEMBERS
-- =========================================

-- Passengers traveling with family members demonstrated slightly higher survival rates compared to solo travelers.

WITH family_data AS
(
    SELECT
        isSurvivor,

        CASE
            WHEN sibling_or_spouse >= 1
                 OR parent_or_child >= 1
                THEN 'Y'
            ELSE 'N'
        END AS family_members_aboard

    FROM titanic_dataset
)

SELECT
    family_members_aboard,
    survival_rate

FROM
(
    SELECT
        family_members_aboard,
        isSurvivor,

        COUNT(isSurvivor) AS survivors_count,

        CAST(
            COUNT(isSurvivor) * 100.00 /
            SUM(COUNT(isSurvivor)) OVER
            (
                PARTITION BY family_members_aboard
            )
        AS DECIMAL(3,0)) AS survival_rate

    FROM family_data
    GROUP BY family_members_aboard, isSurvivor
) t

WHERE isSurvivor = 'Y'
ORDER BY survival_rate DESC;


-- =========================================
-- SURVIVAL BASED ON FARE CATEGORY
-- =========================================

-- Even low-fare female passengers survived at higher rates than high-fare male passengers.
-- Gender remained the strongest predictor of survival.

SELECT
    ticketCategory,
    gender,
    total_survivors,
    pct_of_grand_total_per_ticketCategory

FROM
(
    SELECT
        ticketCategory,
        gender,
        isSurvivor,

        COUNT(isSurvivor) AS total_survivors,

        CAST(
            COUNT(isSurvivor) * 100.00 /
            SUM(COUNT(isSurvivor)) OVER
            (
                PARTITION BY ticketCategory, gender
            )
        AS DECIMAL(3,0)) AS pct_of_grand_total_per_ticketCategory

    FROM titanic_dataset
    GROUP BY ticketCategory,
             gender,
             isSurvivor
) t

WHERE isSurvivor = 'Y'
ORDER BY pct_of_grand_total_per_ticketCategory DESC;


-- =========================================
-- TOP 1% FARE ANALYSIS
-- =========================================

-- Female passengers within the top 1% fare category achieved a 100% survival rate.
-- A small number of extremely wealthy male passengers still did not survive.

SELECT
    ticketCategory,
    gender,
    total_survivors,
    CAST
    (
        (
            SELECT DISTINCT
                PERCENTILE_CONT(0.99)
                WITHIN GROUP (ORDER BY ticketPrice) OVER ()
            FROM titanic_dataset
        ) AS DECIMAL(3,0)
    ) AS top_1_percent_price,
    pct_of_grand_total_per_ticketCategory
FROM
(
    SELECT
        ticketCategory,
        gender,
        isSurvivor,
        COUNT(isSurvivor) AS total_survivors,
        CAST(
            COUNT(isSurvivor) * 100.00 /
            SUM(COUNT(isSurvivor)) OVER
            (
                PARTITION BY ticketCategory, gender
            )
        AS DECIMAL(3,0)) AS pct_of_grand_total_per_ticketCategory
    FROM titanic_dataset
    WHERE ticketPrice >=
    (
        SELECT DISTINCT
            PERCENTILE_CONT(0.99)
            WITHIN GROUP (ORDER BY ticketPrice) OVER ()
        FROM titanic_dataset
    )
    GROUP BY ticketCategory,
             gender,
             isSurvivor
) t
WHERE isSurvivor = 'Y'
ORDER BY pct_of_grand_total_per_ticketCategory DESC;


-- =========================================
-- SURVIVAL BASED ON CABIN DECK
-- =========================================

-- Passengers associated with upper cabin decks generally demonstrated higher survival rates.
-- Missing cabin information was strongly associated with lower survival probabilities.

SELECT
    cabinDeck,
    total_survivors,
    total,
    pct_of_survivors

FROM
(
    SELECT
        isSurvivor,
        cabinDeck,

        COUNT(*) AS total_survivors,

        SUM(COUNT(*)) OVER
        (
            PARTITION BY cabinDeck
        ) AS total,

        CAST(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER
            (
                PARTITION BY cabinDeck
            )
        AS DECIMAL(5,2)) AS pct_of_survivors

    FROM titanic_dataset
    GROUP BY isSurvivor, cabinDeck
) t

WHERE isSurvivor = 'Y'
ORDER BY pct_of_survivors DESC;


-- =========================================
-- SURVIVAL BASED ON FAMILY SIZE
-- =========================================

-- Moderate family sizes appeared to correlate
-- with higher survival probabilities.
-- Extremely large family groups experienced
-- poor survival outcomes.

SELECT
    familySize,
    total_survivors,
    totalSize,
    pct_of_survivors

FROM
(
    SELECT
        familySize,
        isSurvivor,

        COUNT(*) AS total_survivors,

        SUM(COUNT(*)) OVER
        (
            PARTITION BY familySize
        ) AS totalSize,

        CAST(
            COUNT(*) * 100.0 /
            SUM(COUNT(*)) OVER
            (
                PARTITION BY familySize
            )
        AS DECIMAL(5,2)) AS pct_of_survivors
    FROM titanic_dataset
    WHERE familySize > 0
    GROUP BY isSurvivor, familySize
) t
WHERE isSurvivor = 'Y'
ORDER BY pct_of_survivors DESC;

--========================================================
--END
--========================================================
