/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           10_Analysis_Cards_Services.sql
Description:    Phase 10: Credit Card Portfolio & Product Mix.
                - Which card types are most popular? (Junior vs. Classic vs. Gold).
                - Card Issuance Trends (Are we selling more cards?).
                - Relationship between Wealth & Card Type.
===============================================================================
*/

USE Bank_Analytics_DW;
GO

-- =============================================================================
-- 1.0 Card Portfolio Breakdown (Product Mix) 
-- =============================================================================
-- Business Question: "What is our best-selling card? Do people prefer 'Gold' or 'Classic'?"
-- =============================================================================

SELECT * FROM [gold].[card]

SELECT
    card_type AS [Card Type],
    COUNT(card_id) AS [Total Cards Issued],
    CAST(COUNT(card_id) * 100 / (SELECT COUNT(*) FROM [gold].[card]) AS decimal(5,2)) AS [Share %]
FROM [gold].[card]
GROUP BY card_type
ORDER BY [Total Cards Issued] DESC

-- =============================================================================
-- 2.0 Card Issuance Trend (Sales Performance) 
-- =============================================================================
-- Business Question: "Are card sales increasing year-over-year?"
-- =============================================================================

SELECT
    YEAR(issued_date) AS [Year],
    COUNT(card_id) AS [Cards Issued],
    LAG(COUNT(card_id)) OVER(ORDER BY YEAR(issued_date)) AS [Pervious Year],
    COUNT(card_id) - LAG(COUNT(card_id)) OVER(ORDER BY YEAR(issued_date)) AS [YoY Growth]
FROM [gold].[card]
GROUP BY YEAR(issued_date)
ORDER BY [Year]

-- =============================================================================
-- 3.0 Wealth vs. Card Type (Are Gold Cards really for the Rich?) 
-- =============================================================================
-- Business Question: "What is the average loan amount for holders of each card type?"
-- =============================================================================

SELECT
    GC.card_type AS [Card Type] ,
    COUNT(DISTINCT GL.loan_id) AS [Number of Loans],
    CAST(AVG(GL.loan_amount) AS DECIMAL(10,2)) AS [Avg Loan Amount (CZK)]
FROM [gold].[card] AS GC
JOIN [gold].[disposition] AS GDP
    ON GC.disp_id = GDP.disp_id
JOIN [gold].[account] AS GA
    ON GDP.account_id = GA.account_id
JOIN [gold].[loan] AS GL
    ON GA.account_id = GL.account_id
WHERE GL.loan_id IS NOT NULL
GROUP BY GC.card_type
ORDER BY [Avg Loan Amount (CZK)] DESC

-- =============================================================================
-- 4.0 Regional Preferences (Where do we sell Gold Cards?) 
-- =============================================================================
-- Business Question: "Which region buys the most Gold Cards?"
-- =============================================================================

SELECT
    GD.district_name AS [District Name],
    GD.region AS Region,
    COUNT(GC.card_id) AS [Gold Cards Count]
FROM [gold].[card] AS GC 
JOIN [gold].[disposition] AS GDP  
    ON GC.disp_id = GDP.disp_id
JOIN [gold].[account] AS GA 
    ON GDP.account_id = GA.account_id
JOIN [gold].[district] AS GD 
    ON GA.district_id = GD.district_id
WHERE GC.card_type = 'Gold'
GROUP BY 
        GD.district_name , GD.region
ORDER BY [Gold Cards Count] DESC

-- =============================================================================
-- 5.0 Demographics: Age vs. Card Type 
-- =============================================================================
-- Business Question: "Are our card products aligned with customer age groups?"
-- =============================================================================

WITH Card_Holders_Age AS
(
    SELECT
        GC.card_type AS Card_Type ,
        DATEDIFF(YEAR , GCT.birthdate , (SELECT MAX(issued_date) FROM [gold].[card])) AS Customer_Age
    FROM [gold].[card] AS GC 
    JOIN [gold].[disposition] AS GDP  
        ON GC.disp_id = GDP.disp_id
    JOIN [gold].[client] AS GCT
        ON GDP.client_id = GCT.client_id
)

SELECT
    Card_Type ,
    MIN(Customer_Age) AS [Youngest Holder],
    MAX(Customer_Age) AS [Oldest Holder],
    AVG(Customer_Age) AS [Average Age]
FROM Card_Holders_Age
GROUP BY Card_Type
ORDER BY [Average Age]