/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           01_Data_Cleaning.sql
Description:    Phase 1: Data Cleaning & Standardization.
                - Removal of non-standard artifacts (e.g., double quotes).
                - Handling NULL values across all tables using Dynamic SQL.
                - Deep cleaning of specific columns (removing hidden characters like CHAR(10)/CHAR(13)).
===============================================================================
*/

USE Bank_Analytics_DW;
GO

-- =============================================================================
-- 1.0 Basic Artifact Removal (Removing Quotes)
-- =============================================================================
-- Purpose: Remove double quotes ("") that were imported as part of the string values.
-- =============================================================================

PRINT '>> Starting Basic Cleaning (Removing Quotes)...';

-- 1.1 Client Table
SELECT * FROM staging.client 
UPDATE [staging].[client]
SET birth_number = REPLACE(birth_number , '"' , '')

-- 1.2 Account Table
UPDATE [staging].[account]
SET statement_freq = REPLACE(statement_freq , '"' , '')

-- 1.3 Disposition Table
UPDATE [staging].[disposition]
SET  disp_type = REPLACE(disp_type , '"' , '')
 
-- 1.4 Card Table
UPDATE [staging].[card]
SET card_type = REPLACE(card_type , '"' , '')
 
-- 1.5 Loan Table
UPDATE [staging].[loan]
SET loan_status = REPLACE(loan_status , '"' , '')
 
-- 1.6 Order Table
UPDATE [staging].[order]
SET recipient_bank = REPLACE(recipient_bank , '"' , '') ,
    recipient_account = REPLACE(recipient_account , '"' , '') ,
    payment_reason = REPLACE(payment_reason , '"' , '')

-- 1.7 Transaction Table
UPDATE [staging].[transaction]
SET trans_type = REPLACE(trans_type , '"' , '') ,
    trans_method = REPLACE(trans_method , '"' , '') ,
    trans_category = REPLACE(trans_category , '"' , '') ,
    partner_bank = REPLACE(partner_bank , '"' , '') ,
    partner_account = REPLACE(partner_account , '"' , '')

PRINT '   Quotes removed successfully.';
GO

-- =============================================================================
-- 2.0 Advanced NULL Handling (Dynamic SQL Automation)
-- =============================================================================
-- Purpose: Automate the process of replacing placeholders ('', ' ', '?', 'NULL', 'nan')
--          with actual SQL NULLs across ALL text columns in ALL tables.
-- Technique: Using a Cursor to iterate through tables instead of repeating code.
-- =============================================================================

---------------------
-- 2.1 District Table
---------------------
DECLARE @TableName NVARCHAR(256) = '[staging].[district]'; 
DECLARE @Sql NVARCHAR(MAX) = '';


SELECT @Sql = @Sql + 
    'UPDATE ' + @TableName + 
    ' SET ' + QUOTENAME(COLUMN_NAME) + ' = NULL' + 
    ' WHERE ' + QUOTENAME(COLUMN_NAME) + ' IN ('''', '' '', ''?'', ''"?"'', ''NULL'', ''nan'');' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName, 2)
  AND TABLE_NAME = PARSENAME(@TableName, 1)
  AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

PRINT 'Cleaning Text Columns in: ' + @TableName;

EXEC sp_executesql @Sql;
 
-------------------
-- 2.2 Client Table
-------------------
DECLARE @TableName NVARCHAR(256) = '[staging].[client]' ;
DECLARE @Sql NVARCHAR(MAX) = '' ;

SELECT @Sql = @Sql 
             + 'UPDATE ' + @TableName 
             + ' SET ' + QUOTENAME(COLUMN_NAME) + ' = NULL' 
             + ' WHERE ' + QUOTENAME(COLUMN_NAME) + ' IN ('''', '' '', ''?'', ''"?"'', ''NULL'', ''nan'')' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName , 2)
AND TABLE_NAME = PARSENAME(@TableName , 1)
AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

PRINT 'Cleaning Text Columns in: ' + @TableName;

EXEC sp_executesql @Sql;

UPDATE [staging].[client] 
SET [district_id] = REPLACE(REPLACE(REPLACE([district_id], CHAR(10), ''), CHAR(13), ''), ' ', '');
 
--------------------
-- 2.3 Account Table
--------------------
DECLARE @TableName NVARCHAR(MAX) = '[staging].[account]' ;
DECLARE @Sql NVARCHAR(MAX) = ''

SELECT @Sql = @Sql +
       'UPDATE' + @TableName +
       ' SET' + QUOTENAME(COLUMN_NAME) + ' = NULL' +
       ' WHERE' + QUOTENAME(COLUMN_NAME) + ' IN ('''' , '' '' , ''?'' , ''"?"'' , ''NULL'', ''nan'')' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName , 2)
AND TABLE_NAME = PARSENAME(@TableName , 1) 
AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

PRINT 'Cleaning Text Columns in: ' + @TableName;

EXEC sp_executesql @Sql;

------------------------
-- 2.4 Disposition Table
------------------------
DECLARE @TableName NVARCHAR(MAX) = '[staging].[disposition]' ;
DECLARE @Sql NVARCHAR(MAX) = ''

SELECT @Sql = @Sql +
       'UPDATE' + @TableName +
       ' SET' + QUOTENAME(COLUMN_NAME) + ' = NULL' +
       ' WHERE' + QUOTENAME(COLUMN_NAME) + ' IN ('''' , '' '' , ''?'' , ''"?"'' , ''NULL'', ''nan'')' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName , 2)
AND TABLE_NAME = PARSENAME(@TableName , 1) 
AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

PRINT 'Cleaning Text Columns in: ' + @TableName;

EXEC sp_executesql @Sql;
 
-----------------
-- 2.5 Card Table
-----------------
DECLARE @TableName NVARCHAR(MAX) = '[staging].[card]' ;
DECLARE @Sql NVARCHAR(MAX) = ''

SELECT @Sql = @Sql +
       'UPDATE' + @TableName +
       ' SET' + QUOTENAME(COLUMN_NAME) + ' = NULL' +
       ' WHERE' + QUOTENAME(COLUMN_NAME) + ' IN ('''' , '' '' , ''?'' , ''"?"'' , ''NULL'', ''nan'')' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName , 2)
AND TABLE_NAME = PARSENAME(@TableName , 1) 
AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

PRINT 'Cleaning Text Columns in: ' + @TableName;

EXEC sp_executesql @Sql;

-----------------
-- 2.6 Loan Table
-----------------
DECLARE @TableName NVARCHAR(MAX) = '[staging].[loan]' ;
DECLARE @Sql NVARCHAR(MAX) = ''

SELECT @Sql = @Sql +
       'UPDATE' + @TableName +
       ' SET' + QUOTENAME(COLUMN_NAME) + ' = NULL' +
       ' WHERE' + QUOTENAME(COLUMN_NAME) + ' IN ('''' , '' '' , ''?'' , ''"?"'' , ''NULL'', ''nan'')' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName , 2)
AND TABLE_NAME = PARSENAME(@TableName , 1) 
AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

PRINT 'Cleaning Text Columns in: ' + @TableName;

EXEC sp_executesql @Sql;

------------------
-- 2.7 Order Table
------------------
DECLARE @TableName NVARCHAR(MAX) = '[staging].[order]' ;
DECLARE @Sql NVARCHAR(MAX) = ''

SELECT @Sql = @Sql +
       'UPDATE' + @TableName +
       ' SET' + QUOTENAME(COLUMN_NAME) + ' = NULL' +
       ' WHERE' + QUOTENAME(COLUMN_NAME) + ' IN ('''' , '' '' , ''?'' , ''"?"'' , ''NULL'', ''nan'')' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName , 2)
AND TABLE_NAME = PARSENAME(@TableName , 1) 
AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

PRINT 'Cleaning Text Columns in: ' + @TableName;

EXEC sp_executesql @Sql;

------------------------
-- 2.8 Transaction Table
------------------------
DECLARE @TableName NVARCHAR(MAX) = '[staging].[transaction]'; 
DECLARE @Sql NVARCHAR(MAX) = '';

DECLARE @SafeTableName NVARCHAR(MAX) = 
    QUOTENAME(PARSENAME(@TableName, 2)) + '.' + QUOTENAME(PARSENAME(@TableName, 1));

SELECT @Sql = @Sql + 
       'UPDATE ' + @SafeTableName + 
       ' SET ' + QUOTENAME(COLUMN_NAME) + ' = NULL' +
       ' WHERE LTRIM(RTRIM(' + QUOTENAME(COLUMN_NAME) + ')) = ''''' + 
       ' OR ' + QUOTENAME(COLUMN_NAME) + ' IN (''?'' , ''"?"'' , ''NULL'', ''nan'');' + CHAR(13)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = PARSENAME(@TableName, 2)
  AND TABLE_NAME = PARSENAME(@TableName, 1)
  AND DATA_TYPE IN ('char', 'nchar', 'varchar', 'nvarchar', 'text', 'ntext');

PRINT 'Cleaning Table (Deep Clean): ' + @SafeTableName;

EXEC sp_executesql @Sql;
 
-- =============================================================================
-- 3.0 Deep Cleaning (Hidden Characters & Whitespace)
-- =============================================================================
-- Purpose: Remove hidden line feeds (CHAR(10)), carriage returns (CHAR(13)), 
--          and extra spaces from critical ID and description columns.
-- =============================================================================
------------------
--3.1 Client Table
------------------
UPDATE [staging].[client] 
SET [district_id] = REPLACE(REPLACE(REPLACE([district_id], CHAR(10), ''), CHAR(13), ''), ' ', '');

------------------
-- 3.2 Order Table
------------------
SELECT TOP 10 
    payment_reason, 
    ASCII(payment_reason) AS [Code_of_First_Char],  
    LEN(payment_reason) AS [Length]
FROM [staging].[order]
WHERE payment_reason IS NOT NULL 
  AND payment_reason NOT LIKE '%[0-9]%'; 


SELECT TOP 10 ASCII(SUBSTRING(payment_reason, 2, 1)) 
FROM [staging].[order] 
WHERE LEN(payment_reason) = 2;
 
UPDATE [staging].[order]
SET payment_reason = NULL
WHERE REPLACE(REPLACE(REPLACE(payment_reason, CHAR(13), ''), CHAR(10), ''), ' ', '') = ''; 

------------------------
-- 3.2 Transaction Table
------------------------
SELECT TOP 10 
    partner_account, 
    ASCII(partner_account) AS [Code_of_First_Char],  
    LEN(partner_account) AS [Length]
FROM staging.[transaction]
WHERE partner_account IS NOT NULL 
  AND partner_account NOT LIKE '%[0-9]%'; 

UPDATE [staging].[transaction]
SET [partner_account] = REPLACE(REPLACE(REPLACE([partner_account], CHAR(10), ''), CHAR(13), ''), ' ', '');


-- =============================================================================
-- 4.0 Validation Queries (Optional / Ad-hoc)
-- =============================================================================
-- Use these queries to verify data quality after cleaning.
-- =============================================================================

-- 4.1 Validate Order Table
SELECT TOP 10 
    payment_reason, 
    ASCII(payment_reason) AS [Code_of_First_Char],  
    LEN(payment_reason) AS [Length]
FROM [staging].[order]
WHERE payment_reason IS NOT NULL 
  AND payment_reason NOT LIKE '%[0-9]%'; 


SELECT TOP 10 ASCII(SUBSTRING(payment_reason, 2, 1)) 
FROM [staging].[order] 
WHERE LEN(payment_reason) = 2;


-- 4.2 Validate Transaction Table
SELECT TOP 10 
    partner_account, 
    ASCII(partner_account) AS [Code_of_First_Char],  
    LEN(partner_account) AS [Length]
FROM staging.[transaction]
WHERE partner_account IS NOT NULL 
  AND partner_account NOT LIKE '%[0-9]%'; 
