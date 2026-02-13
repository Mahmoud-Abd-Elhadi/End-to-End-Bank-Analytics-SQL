/*
===============================================================================
Project Name:      Czech Bank Data Engineering & Analysis
Description:       End-to-End ETL Pipeline (Raw -> Silver -> Gold).
                   Transforming messy financial data into a clean Data Warehouse 
                   ready for Power BI reporting using Medallion Architecture.

Key Stages:
1. Ingestion:      Bulk inserting raw CSV data into Staging (Bronze) layer.
2. Cleaning:       Handling NULLs using Dynamic SQL, removing artifacts, 
                   and standardizing text formats.
3. Transformation: Translating values, parsing dates (DateFromParts), 
                   and type casting (Silver Layer).
4. Modeling:       Building a Star Schema with Fact & Dimension tables,
                   defining Primary Keys & Foreign Keys (Gold Layer).

Tools Used:        SQL Server (T-SQL), Window Functions, Dynamic SQL.
===============================================================================
*/

-- =============================================================================
-- 1.0 Database Initialization
-- =============================================================================
-- Purpose: Reset the environment to ensure a clean start for the pipeline.
-- =============================================================================
USE master

-- 1.1 Drop Database if it exists (Development Mode)
IF EXISTS (SELECT 1 FROM SYS.databases WHERE NAME = 'Bank_Analytics_DW')
BEGIN
	ALTER DATABASE Bank_Analytics_DW SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	DROP DATABASE Bank_Analytics_DW
END


---- 1.2 Create the new Data Warehouse
CREATE DATABASE Bank_Analytics_DW
GO

USE Bank_Analytics_DW
GO

-- =============================================================================
-- 2.0 Schema Configuration
-- =============================================================================
-- Purpose: Create schemas to organize data layers (Medallion Architecture).
-- =============================================================================

-- 2.1 Create Staging Schema (Bronze Layer)
-- This schema will hold the raw data as-is from the source system.
CREATE SCHEMA staging;
GO

-- =============================================================================
-- 3.0 Staging Tables Definition (DDL)
-- =============================================================================
-- Note: Data types are preserved exactly as provided in the original script.

-- 3.1 Table: District (Demographic Data)
CREATE TABLE staging.district
(
	district_id            INT PRIMARY KEY ,                   -- Primary Key in Source
	district_name          VARCHAR(100) ,
	region                 VARCHAR(100) ,
	[population]           INT ,
	num_muni_0_499         INT,                  
    num_muni_500_1999      INT,               
    num_muni_2000_9999     INT,              
    num_muni_gt_10000      INT,
	num_cities             INT,
	urban_ratio            DECIMAL(5,2),
	average_salary         DECIMAL(10,2),
	unemployment_rate_95   VARCHAR(50),                        -- VARCHAR due to potential dirty data ('?')
    unemployment_rate_96   DECIMAL(5,2),   
    entrepreneurs_per_1000 INT,          
    crimes_95              VARCHAR(50),                       
    crimes_96              INT
)
GO

-- 3.2 Table: Client (Customer Information)
CREATE TABLE staging.client 
(
	client_id    NVARCHAR(200) ,
	birth_number NVARCHAR(200) ,                                -- Contains birthdate and gender info
	district_id  NVARCHAR(200)
)
GO

-- 3.3 Table: Account
DROP TABLE staging.account
CREATE TABLE staging.account
(
	account_id     INT PRIMARY KEY,
    district_id    VARCHAR(50),            
    statement_freq VARCHAR(50),  
    date_opened    VARCHAR(50)
)
GO

-- 3.4 Table: Disposition
CREATE TABLE staging.disposition
(
	disp_id    INT PRIMARY KEY,
    client_id  INT,
    account_id INT,
    disp_type  NVARCHAR(50)
)
GO

-- 3.5 Table: Card
CREATE TABLE staging.[card]
(
	card_id     INT PRIMARY KEY,
    disp_id     INT,
    card_type   NVARCHAR(50),    
    issued_date NVARCHAR(50) 
)
GO

-- 3.6 Table: Loan
CREATE TABLE staging.loan
(
	loan_id         INT PRIMARY KEY,
    account_id      INT,
    loan_date       INT,                       -- Preserved as INT per your code
    loan_amount     DECIMAL(18,2),  
    duration_months INT,       
    monthly_payment DECIMAL(18,2),  
    loan_status     VARCHAR(5)                 -- Preserved as VARCHAR(5) per your code
)
GO

-- 3.7 Table: Order
CREATE TABLE staging.[order]
(
	order_id          INT PRIMARY KEY,
    account_id        INT,
    recipient_bank    NVARCHAR(10),     
    recipient_account NVARCHAR(50),  
    order_amount      DECIMAL(18,2),      
    payment_reason    NVARCHAR(50)
)
GO

-- 3.8 Table: Transaction
CREATE TABLE staging.[transaction] (
    trans_id        INT PRIMARY KEY,
    account_id      INT,
    trans_date      INT,                         -- Preserved as INT per your code     
    trans_type      NVARCHAR(50),         
    trans_method    NVARCHAR(100),      
    amount          DECIMAL(18,2),
    balance_after   DECIMAL(18,2),     
    trans_category  NVARCHAR(50),     
    partner_bank    NVARCHAR(50),       
    partner_account NVARCHAR(50)    
);
GO
-- =============================================================================
-- 4.0 Data Ingestion (Bulk Insert)
-- =============================================================================

-- 4.1 Load District Table
TRUNCATE TABLE staging.district
GO

BULK INSERT staging.district
    FROM 'C:\Queries\My_Project\Czech Financial Dataset\district.csv'
WITH
(
    FORMAT = 'CSV' ,
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '0x0a' ,
    FIELDQUOTE = '"',
    TABLOCK
)
GO

-- 4.2 Load Client Table
TRUNCATE TABLE staging.client
GO

BULK INSERT staging.client
    FROM 'C:\Queries\My_Project\Czech Financial Dataset\client.csv'
WITH
(
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '0x0a' ,  
    TABLOCK
)
GO

-- 4.3 Load Account Table
TRUNCATE TABLE staging.account
GO

BULK INSERT staging.account
    FROM 'C:\Queries\My_Project\Czech Financial Dataset\account.csv'
WITH
(
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '0x0a' ,
    TABLOCK
)
GO

-- 4.4 Load Disposition Table
TRUNCATE TABLE staging.disposition
GO

BULK INSERT staging.disposition
    FROM 'C:\Queries\My_Project\Czech Financial Dataset\disp.csv'
WITH
(
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '0x0a' , 
    TABLOCK
)
GO

-- 4.5 Load Card Table
TRUNCATE TABLE staging.[card]
GO

BULK INSERT staging.[card]
    FROM 'C:\Queries\My_Project\Czech Financial Dataset\card.csv'
WITH
( 
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '0x0a' ,
    TABLOCK
)
GO

-- 4.6 Load Loan Table
TRUNCATE TABLE staging.loan
GO

BULK INSERT staging.loan
    FROM 'C:\Queries\My_Project\Czech Financial Dataset\loan.csv'
WITH
( 
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '0x0a' , 
    TABLOCK
)
GO

-- 4.7 Load Order Table
TRUNCATE TABLE staging.[order]
GO

BULK INSERT staging.[order]
    FROM 'C:\Queries\My_Project\Czech Financial Dataset\order.csv'
WITH
(
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '0x0a' ,
    TABLOCK
)
GO

-- 4.8 Load Transaction Table
TRUNCATE TABLE staging.[transaction]
GO

BULK INSERT staging.[transaction]
    FROM 'C:\Queries\My_Project\Czech Financial Dataset\trans.csv'
WITH
(
    FIRSTROW = 2 ,
    FIELDTERMINATOR = ',' ,
    ROWTERMINATOR = '0x0a' , 
    TABLOCK
)
GO