/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           09_Analysis_Financial_Trends.sql
Description:    Phase 9: Financial Trends & Macro Economic Analysis.
                - Year-over-Year (YoY) Growth.
                - Cash Flow Analysis (Credits vs. Withdrawals).
                - Seasonality Patterns (When do people spend?).
===============================================================================
*/

USE Bank_Analytics_DW;
GO

-- =============================================================================
-- 1.0 Customer Acquisition Growth (Year-over-Year) 
-- =============================================================================
-- Business Question: "Is our customer base growing? And how fast?"
-- =============================================================================

WITH Yearly_Accounts AS
(
    SELECT
        YEAR(created_date) AS [Year],
        COUNT(account_id) AS [New Accounts]
    FROM [gold].[account]
    GROUP BY YEAR(created_date)
)

SELECT
    [Year] ,
    [New Accounts] ,
    LAG([New Accounts]) OVER(ORDER BY [Year]) AS [Previous Year Accounts] ,
    [New Accounts] - LAG([New Accounts]) OVER(ORDER BY [Year]) AS [YoY Growth (Count)] ,
    ROUND((CAST([New Accounts] - LAG([New Accounts]) OVER(ORDER BY [Year]) AS FLOAT)  * 100 /
    LAG([New Accounts]) OVER(ORDER BY [Year])) , 2) AS [YoY Growth Rate %]
FROM Yearly_Accounts
ORDER BY [Year]

-- =============================================================================
-- 2.0 Cash Flow Analysis (Inflow vs. Outflow) 
-- =============================================================================
-- Business Question: "Are we collecting more money than we are giving out?"
-- =============================================================================
SELECT * FROM [gold].[transaction]

SELECT 
    YEAR(trans_date) AS [Year] ,
    SUM(CASE WHEN trans_type = 'Credit' THEN amount ELSE 0 END)    AS [Total Credit (Inflow)] ,
    SUM(CASE WHEN trans_type = 'Withdrawal' THEN amount ELSE 0 END) AS [Total Withdrawal (Outflow)],
    SUM(CASE WHEN trans_type = 'Credit' THEN amount ELSE 0 END) -
    SUM(CASE WHEN trans_type = 'Withdrawal' THEN amount ELSE 0 END) AS [Net Cash Flow]
FROM [gold].[transaction]
GROUP BY YEAR(trans_date)
ORDER BY [Year]

-- =============================================================================
-- 3.0 Seasonality Patterns (Monthly Activity) 
-- =============================================================================
-- Business Question: "Which months are the busiest? When do people withdraw the most?"
-- =============================================================================

SELECT
    MONTH(trans_date) AS [Month Number] ,
    DATENAME(MONTH , trans_date) AS [Month Name] ,
    COUNT(trans_id) AS [Total Transactions],
    SUM(amount) AS [Total Volume Moved]
FROM [gold].[transaction]
GROUP BY MONTH(trans_date) , DATENAME(MONTH , trans_date)
ORDER BY [Total Volume Moved] DESC

-----------------

SELECT
    * ,
     ROW_NUMBER() OVER(PARTITION BY [Year Number] ORDER BY [Total Volume Moved] DESC) AS RN
FROM (
        SELECT
            YEAR(trans_date) AS [Year Number] ,
            MONTH(trans_date) AS [Month Number] ,
            DATENAME(MONTH , trans_date) AS [Month Name] ,
            COUNT(trans_id) AS [Total Transactions],
            SUM(amount) AS [Total Volume Moved] 
        FROM [gold].[transaction]
        GROUP BY YEAR(trans_date) , MONTH(trans_date) , DATENAME(MONTH , trans_date)
        ) AS T
ORDER BY [Year Number] , [Total Volume Moved] DESC


-- =============================================================================
-- 4.0 Yearly Peak Volume Analysis (Highest Activity Month) 
-- =============================================================================
-- Business Question: "Which specific month had the highest transaction volume each year?"
-- =============================================================================

WITH Total_Volume AS
(
    SELECT
            YEAR(trans_date) AS [Year Number] ,
            MONTH(trans_date) AS [Month Number] ,
            DATENAME(MONTH , trans_date) AS [Month Name] ,
            COUNT(trans_id) AS [Total Transactions],
            SUM(amount) AS [Total Volume Moved] 
        FROM [gold].[transaction]
        GROUP BY YEAR(trans_date) , MONTH(trans_date) , DATENAME(MONTH , trans_date)
) 
 , Ranking_Total_Volume AS
(
    SELECT
        * ,
        ROW_NUMBER() OVER(PARTITION BY [Year Number] ORDER BY [Total Volume Moved] DESC) AS RN
    FROM Total_Volume
)

SELECT
    *
FROM Ranking_Total_Volume
WHERE RN = 1

-- =============================================================================
-- 5.0 Transaction Method Trends (Digital vs. Cash) 
-- =============================================================================
-- Business Question: "Are customers shifting from Cash to Bank Transfers over time?"
-- =============================================================================

SELECT * FROM  [gold].[transaction]
SELECT DISTINCT trans_method FROM [gold].[transaction]

SELECT
    YEAR(trans_date) AS [YEAR] ,
    SUM(CASE WHEN trans_method IN ('Cash withdrawal', 'Credit in cash', 'Credit card withdrawal') THEN 1 ELSE 0 END) AS [Cash Transactions],
    SUM(CASE WHEN trans_method IN ('Remittance to Another Bank', 'Collection from Another Bank') THEN 1 ELSE 0 END)  AS [Bank Transfers] ,
    CAST((SUM(CASE WHEN trans_method IN ('Remittance to Another Bank', 'Collection from Another Bank') THEN 1 ELSE 0 END) * 100 /
    COUNT(*)) AS FLOAT) AS [Digital Transfer Rate %]
FROM [gold].[transaction]
WHERE trans_method IS NOT NULL
GROUP BY YEAR(trans_date)
ORDER BY [YEAR]