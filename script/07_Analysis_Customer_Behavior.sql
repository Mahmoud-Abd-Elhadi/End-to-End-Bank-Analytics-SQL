/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           08_Analysis_Customer_Behavior.sql
Description:    Phase 8: Customer Demographics & Financial Behavior.
                - Who are our customers? (Age & Gender)
                - Who has the money? (Balance Analysis)
                - Where do they live? (Regional Wealth)
===============================================================================
*/

USE Bank_Analytics_DW;
GO


-- =============================================================================
-- 1.0 Age Distribution (Demographics) 
-- =============================================================================
-- Business Question: "Are we serving young professionals or retirees?"
-- Note: Calculating age relative to the latest data point (e.g., 1999) not today.
-- =============================================================================

DECLARE @MAX_DATE DATE = (SELECT MAX(trans_date) FROM [gold].[transaction])

SELECT
    CASE
        WHEN DATEDIFF(YEAR , birthdate , @MAX_DATE) < 25 THEN 'Youth (18-25)'
        WHEN DATEDIFF(YEAR , birthdate , @MAX_DATE) BETWEEN 25 AND 40 THEN 'Adults (25-40)'
        WHEN DATEDIFF(YEAR , birthdate , @MAX_DATE) BETWEEN 41 AND 60 THEN 'Middle Age (41-60)'
        ELSE 'Seniors (60+)' 
    END AS [Age Group],
    COUNT(client_id) AS [Client Count] ,
    ROUND((CAST(COUNT(client_id) AS FLOAT) /
        (SELECT COUNT(client_id) FROM [gold].[client])) * 100 , 2) AS [Percentage %]
FROM [gold].[client]
GROUP BY 
         CASE
            WHEN DATEDIFF(YEAR , birthdate , @MAX_DATE) < 25 THEN 'Youth (18-25)'
            WHEN DATEDIFF(YEAR , birthdate , @MAX_DATE) BETWEEN 25 AND 40 THEN 'Adults (25-40)'
            WHEN DATEDIFF(YEAR , birthdate , @MAX_DATE) BETWEEN 41 AND 60 THEN 'Middle Age (41-60)'
            ELSE 'Seniors (60+)' 
         END
ORDER BY [Client Count] DESC

-- ==============> USING CTEs
WITH Client_Ages AS 
(
    SELECT
        client_id ,
        DATEDIFF(YEAR , birthdate , (SELECT MAX(trans_date) FROM [gold].[transaction])) AS AGE_LAST_TRANS
    FROM [gold].[client]
)

, Age_Groups AS
(
    SELECT
        client_id ,
        CASE
            WHEN AGE_LAST_TRANS < 25 THEN 'Youth (18-25)'
            WHEN AGE_LAST_TRANS BETWEEN 25 AND 40 THEN 'Adults (25-40)'
            WHEN AGE_LAST_TRANS BETWEEN 41 AND 60 THEN 'Middle Age (41-60)'
            ELSE 'Seniors (60+)' 
         END AS Age_Group 
    FROM Client_Ages
)

SELECT
    Age_Group ,
    COUNT(client_id) AS [Client Count] ,
    ROUND((CAST(COUNT(client_id) AS FLOAT) /
          (SELECT COUNT(*) FROM [gold].[client])) * 100 , 2) AS [Percentage %]
FROM Age_Groups
GROUP BY Age_Group
ORDER BY [Client Count] DESC

-- =============================================================================
-- 2.0 Balance Analysis (Finding the Wealth) 
-- =============================================================================
-- Business Question: "How much money does each customer actually have right now?"
-- Logic: We must get the balance from the *LAST* transaction for each account.
-- =============================================================================

SELECT
    *
FROM [gold].[transaction]
ORDER BY account_id , trans_date

SELECT 
    *
FROM (
        SELECT 
            account_id ,
            balance_after ,
            ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY trans_date DESC , trans_id DESC) AS RN
        FROM [gold].[transaction]
        ) AS T
WHERE RN = 1
ORDER BY account_id , RN

-- =============================================================================
-- 3.0 Balance Analysis (Finding the Wealth) 
-- =============================================================================
-- Business Question: "How much money does each customer actually have right now?"
-- Logic: We must get the balance from the *LAST* transaction for each account.
-- =============================================================================
WITH Latest_Balances AS
(
    SELECT 
        account_id ,
        balance_after AS Current_Balance,
        ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY trans_date DESC , trans_id DESC) AS RN
    FROM [gold].[transaction]
)

SELECT
    CASE
        WHEN Current_Balance < 0 THEN 'In Debt (Negative)'
        WHEN Current_Balance BETWEEN 0 AND 10000 THEN 'Low Balance (< 10k)'
        WHEN Current_Balance BETWEEN 10001 AND 50000 THEN 'Mid Balance (10k-50k)'
        WHEN Current_Balance > 50000 THEN 'High Net Worth (> 50k)'
    END AS [Wealth Segment] ,
    COUNT(account_id) AS [Account Count] ,
    ROUND(CAST(AVG(Current_Balance) AS FLOAT) , 2) AS [Avg Balance]  
FROM Latest_Balances
WHERE RN = 1
GROUP BY 
        CASE
            WHEN Current_Balance < 0 THEN 'In Debt (Negative)'
            WHEN Current_Balance BETWEEN 0 AND 10000 THEN 'Low Balance (< 10k)'
            WHEN Current_Balance BETWEEN 10001 AND 50000 THEN 'Mid Balance (10k-50k)'
            WHEN Current_Balance > 50000 THEN 'High Net Worth (> 50k)'
        END
ORDER BY [Avg Balance] DESC

-- =============================================================================
-- 4.0 Regional Wealth (Where is the money?) 
-- =============================================================================
-- Business Question: "Which regions have the richest customers?"
-- =============================================================================

WITH Latest_Balances AS
(
    SELECT 
        account_id ,
        balance_after AS Current_Balance,
        ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY trans_date DESC , trans_id DESC) AS RN
    FROM [gold].[transaction]
)

SELECT TOP 10
    GD.district_name ,
    GD.region ,
    COUNT(LB.account_id) AS [Account Count] ,
    ROUND(CAST(AVG(Current_Balance) AS FLOAT) , 2) AS [Avg Balance]
FROM Latest_Balances AS LB
JOIN [gold].[account] AS GA
    ON LB.account_id = GA.account_id
JOIN [gold].[district] AS GD
    ON GA.district_id = GD.district_id
GROUP BY 
        GD.district_name ,
        GD.region
ORDER BY [Avg Balance] DESC

-- =============================================================================
-- 5.0 The VIP List (Top 10 Customers) 
-- =============================================================================
-- Business Question: "Who are our top 10 clients by current balance?"
-- =============================================================================

WITH Latest_Balances AS
(
    SELECT 
        account_id ,
        balance_after AS Current_Balance,
        ROW_NUMBER() OVER(PARTITION BY account_id ORDER BY trans_date DESC , trans_id DESC) AS RN
    FROM [gold].[transaction]
)

SELECT
    GC.client_id ,
    GD.region ,
    LB.Current_Balance
FROM Latest_Balances AS LB
JOIN [gold].[account] AS GA
    ON LB.account_id = GA.account_id
JOIN [gold].[disposition] AS GDP
    ON GDP.account_id = GA.account_id
JOIN [gold].[client] AS GC
    ON GC.client_id = GDP.client_id
JOIN [gold].[district] AS GD
    ON GD.district_id = GC.district_id
WHERE LB.RN = 1 AND GDP.disp_type = 'Owner'
ORDER BY LB.Current_Balance DESC