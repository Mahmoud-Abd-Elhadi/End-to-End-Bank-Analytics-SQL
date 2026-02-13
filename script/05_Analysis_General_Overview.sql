/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           05_Analysis_General_Overview.sql
Description:    Phase 5: General Data Exploration & KPIs.
                - "The Big Picture": High-level metrics (KPIs).
                - Demographics (Who are we serving?).
                - Geography (Where are we?).
                - Timeline (When did this happen?).
===============================================================================
*/

USE Bank_Analytics_DW;
GO


-- =============================================================================
-- 1.0 Executive Summary (High-Level KPIs) 
-- =============================================================================
-- Business Question: "Give me the headline numbers for our bank."
-- =============================================================================
SELECT
    (SELECT COUNT(*) FROM [gold].[client])         AS [Total Client Base] ,
    (SELECT COUNT(*) FROM [gold].[account])        AS [Total Accounts] ,
    (SELECT COUNT(*) FROM [gold].[loan])       AS [Loans Issued] ,
    (SELECT COUNT(*) FROM [gold].[card])         AS [Cards Issued] ,
    (SELECT COUNT(*) FROM [gold].[transaction])    AS [Total Transactions Volume] ,
    (SELECT FORMAT(SUM(amount) , 'N0') FROM [gold].[transaction]) AS [Total Money Moved (CZK)] 


-- =============================================================================
-- 2.0 Geographical Footprint (Market Penetration) 
-- =============================================================================
-- Business Question: "Are we too concentrated in the capital (Prague)?"
-- =============================================================================

SELECT TOP 10
    GD.district_id AS [District ID],
    GD.district_name AS [District Name],
    GD.region AS Region,
    COUNT(GC.client_id) [Client Count],
    ROUND((CAST(COUNT(GC.client_id) AS FLOAT) / 
    (SELECT COUNT(client_id) FROM [gold].[client])) * 100 , 2) AS [Market Share %]
FROM [gold].[district] AS GD
JOIN [gold].[client]   AS GC
ON GD.district_id = GC.district_id
GROUP BY GD.district_id ,
         GD.district_name ,
         GD.region
ORDER BY COUNT(GC.client_id) DESC

-- =============================================================================
-- 3.0 Demographic Mix (Gender Split) 
-- =============================================================================
-- Business Question: "What is our customer gender breakdown?"
-- =============================================================================

SELECT
    gender AS Gender ,
    COUNT(client_id) AS [Client Count] ,
    ROUND((CAST(COUNT(client_id) AS FLOAT) /
    (SELECT COUNT(client_id) FROM [gold].[client])) * 100 , 2) AS [Percentage %]
FROM [gold].[client]
GROUP BY gender
ORDER BY [Client Count] DESC

-- =============================================================================
-- 4.0 Historical Depth (Data Timeline) ⏳
-- =============================================================================
-- Business Question: "What is the time range of this dataset? Is it historical or recent?"
-- =============================================================================

SELECT
    MIN([created_date]) AS First_Account_Opened,
    MAX([created_date]) AS Last_Account_Opened,
    CONCAT(
           DATEDIFF(YEAR , MIN([created_date]) , MAX([created_date])) , ' Year ,' ,
           DATEDIFF(MONTH , MIN([created_date]) , MAX([created_date]))  % 12 , ' Month'
           ) AS Data_Time_Range
FROM [gold].[account]

-- =============================================================================
-- 5.0 Product Adoption (Cards vs. Loans)  
-- =============================================================================
-- Business Question: "How many of our clients are borrowing vs. just using cards?"
-- =============================================================================

SELECT
    'Loans' AS [Product] ,
    COUNT(loan_id) AS Total_Count ,
    ROUND((CAST(COUNT(loan_id) AS FLOAT) / 
    (SELECT COUNT(*) FROM [gold].[account])) * 100 , 2) AS [Penetration Rate %]
FROM [gold].[loan]
UNION ALL
SELECT
    'Credit Card' AS [Product] ,
    COUNT(card_id) AS Total_Count ,
    ROUND((CAST(COUNT(card_id) AS FLOAT) / 
    (SELECT COUNT(*) FROM [gold].[account])) * 100 , 2) AS [Penetration Rate %]
FROM [gold].[card]
