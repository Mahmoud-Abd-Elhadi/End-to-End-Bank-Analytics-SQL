/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           06_Analysis_Loan_Risk.sql
Description:    Phase 6: Loan Portfolio & Risk Management.
                - Analyzing Loan Quality (Good vs. Bad).
                - Calculating Default Rates (The most critical banking KPI).
                - Identifying High-Risk Regions.
===============================================================================
*/

USE Bank_Analytics_DW;
GO


-- =============================================================================
-- 1.0 Loan Portfolio Health (The Status Quo) 
-- =============================================================================
-- Business Question: "Break down our loans by status. Are we making money or losing it?"
-- =============================================================================

SELECT
    loan_status AS [Loan Status],
    COUNT(loan_id) AS [Total Loans],
    SUM(loan_amount) AS [Total Amount (CZK)],
    ROUND(AVG(loan_amount) , 2) AS [Avg Loan Size],
    ROUND((CAST(COUNT(loan_id) AS FLOAT) / 
    (SELECT COUNT(*) FROM [gold].[loan])) * 100 , 2) AS [Volume %]
FROM [gold].[loan]
GROUP BY loan_status
ORDER BY [Total Loans]

-- =============================================================================
-- 2.0 The "Default Rate" (The Scary Number) 
-- =============================================================================
-- Business Question: "What is our Default Rate? (Percentage of bad loans)"
-- =============================================================================

WITH LOANS AS
(
SELECT
    loan_status AS [Loan Status],
    COUNT(loan_id) AS [Total Loans],
    SUM(loan_amount) AS [Total Amount (CZK)],
    ROUND(AVG(loan_amount) , 2) AS [Avg Loan Size],
    ROUND((CAST(COUNT(loan_id) AS FLOAT) / 
    (SELECT COUNT(*) FROM [gold].[loan])) * 100 , 2) AS [Volume %]
FROM [gold].[loan]
GROUP BY loan_status
)

SELECT
    [Loan Status] ,
    ROUND((CAST([Total Amount (CZK)] AS FLOAT) /
    (SELECT SUM([Total Amount (CZK)]) FROM LOANS)) * 100 ,2) AS Default_Money_Rate
FROM LOANS
WHERE [Loan Status] IN ('Finished - Defaulted', 'Running - In Debt')
ORDER BY [Total Loans]

---------------------

SELECT 
    CAST(
    SUM(
    CASE
        WHEN loan_status IN ('Finished - Defaulted', 'Running - In Debt') THEN 1
        ELSE 0
    END) * 100 / COUNT(*) AS DECIMAL(5,2)) AS Default_Rate ,
    SUM(
    CASE
        WHEN loan_status IN ('Finished - Defaulted', 'Running - In Debt') THEN loan_amount
        ELSE 0
    END) AS [Total Risk Amount (CZK)]
FROM [gold].[loan]

-- =============================================================================
-- 3.0 Geographical Risk Analysis (Blackspots) 
-- =============================================================================
-- Business Question: "Are there specific regions where people don't pay back?"
-- =============================================================================

SELECT TOP 10
    GD.district_name AS [District Name],
    GD.region AS Region ,
    COUNT(GL.loan_id) AS [Total Loans Issued] ,
    SUM(
        CASE
            WHEN GL.loan_status IN ('Finished - Defaulted', 'Running - In Debt') THEN 1
            ELSE 0
        END ) AS [Bad Loans Count] ,
     ROUND((CAST(SUM(CASE WHEN GL.loan_status IN ('Finished - Defaulted', 'Running - In Debt') THEN 1 ELSE 0 END ) AS FLOAT) 
     / COUNT(GL.loan_id)) , 2) AS [Regional Default Rate %]
FROM [gold].[loan] AS GL
JOIN [gold].[account] AS GA
    ON GL.account_id = GA.account_id
JOIN [gold].[district] AS GD
    ON GD.district_id = GA.district_id
GROUP BY GD.district_name ,
         GD.region
ORDER BY [Bad Loans Count] DESC , 
         [Regional Default Rate %] DESC

-- =============================================================================
-- 4.0 Financial Exposure (Active Loans) 
-- =============================================================================
-- Business Question: "How much money is currently 'out there' (Running Loans)?"
-- =============================================================================

SELECT 
    loan_status ,
    COUNT(loan_id) AS [Total Loans Issued] ,
    SUM(loan_amount) AS [Outstanding Balance (Approx)]
FROM [gold].[loan]
WHERE loan_status LIKE 'Running%'
GROUP BY loan_status

-- =============================================================================
-- 5.0 Risk Evolution over Time (Vintage Analysis) 
-- =============================================================================
-- Business Question: "Is our credit quality improving or deteriorating over the years?"
-- =============================================================================

SELECT
    YEAR(loan_date) AS [LOAN YEAR] ,
    COUNT(loan_id) AS [Total Loans Issued] ,
    SUM(
        CASE
            WHEN loan_status IN ('Finished - Defaulted', 'Running - In Debt') THEN 1
            ELSE 0
        END ) AS [Bad Loans Count] ,
     ROUND((CAST(SUM(CASE WHEN loan_status IN ('Finished - Defaulted', 'Running - In Debt') THEN 1 ELSE 0 END ) AS FLOAT) 
     / COUNT(loan_id)) , 2) AS [Regional Default Rate %]
FROM [gold].[loan]
GROUP BY YEAR(loan_date)
ORDER BY [LOAN YEAR]

-- =============================================================================
-- 6.0 Risk by Loan Duration (Short vs. Long Term) 
-- =============================================================================
-- Business Question: "Are long-term loans riskier than short-term ones?"
-- =============================================================================

SELECT 
    duration_months AS [Loan Duration (Months)], 
    COUNT(loan_id) [Total Loans Issued],
    ROUND((CAST(SUM(CASE WHEN loan_status IN ('Finished - Defaulted', 'Running - In Debt') THEN 1 ELSE 0 END ) AS FLOAT) 
     / COUNT(loan_id)) , 2) AS [Regional Default Rate %]
FROM [gold].[loan]
GROUP BY duration_months
ORDER BY[Loan Duration (Months)]