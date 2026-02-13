/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           03_Type_Casting_and_Silver_Migration.sql
Description:    Phase 3: Final Data Type Conversion & Schema Migration.
                - Convert numeric strings to INT/DECIMAL.
                - Confirm DATE types for temporal columns.
                - Create 'silver' schema and transfer cleaned tables into it.
===============================================================================
*/

USE Bank_Analytics_DW;
GO

-- =============================================================================
-- 1.0 Final Data Type Conversion (Casting)
-- =============================================================================
-- Purpose: Convert validated string data into efficient native SQL types.
--          This ensures data integrity and storage optimization.
-- =============================================================================

PRINT '>> Starting Final Type Casting...';

-- 1.1 District Table: Convert Metrics to Numeric Types
ALTER TABLE [staging].[district]
ALTER COLUMN [unemployment_rate_95] DECIMAL(5, 2);

ALTER TABLE [staging].[district]
ALTER COLUMN [entrepreneurs_per_1000] DECIMAL(5, 2);

ALTER TABLE [staging].[district]
ALTER COLUMN [crimes_95] INT;

-- 1.2 Client Table: Convert IDs to Integer
ALTER TABLE [staging].[client]
ALTER COLUMN [client_id] INT;

ALTER TABLE [staging].[client]
ALTER COLUMN [district_id] INT;

-- 1.3 Account Table: Convert FKs to Integer
ALTER TABLE [staging].[account]
ALTER COLUMN [district_id] INT;

-- 1.4 Card Table: Confirm Date Type
ALTER TABLE [staging].[card]
ALTER COLUMN [issued_date] DATE;

-- 1.5 Loan Table: Confirm Date Type
ALTER TABLE [staging].[loan]
ALTER COLUMN [loan_date] DATE;

-- 1.6 Order Table: Convert Account Numbers to Integer
-- Note: Converting account numbers to INT will remove any leading zeros.
ALTER TABLE [staging].[order]
ALTER COLUMN [recipient_account] INT;

-- 1.7 Transaction Table: Date & Account Conversion
ALTER TABLE [staging].[transaction] 
ALTER COLUMN [trans_date] DATE;

ALTER TABLE [staging].[transaction]
ALTER COLUMN [partner_account] INT;

PRINT '   Type casting complete.';
GO

-- =============================================================================
-- 2.0 Schema Migration (Staging -> Silver)
-- =============================================================================
-- Purpose: Move the now-clean and typed tables into the 'silver' schema.
--          This marks the data as "Trusted" and ready for modeling.
-- =============================================================================

PRINT '>> Starting Schema Migration to Silver...';

-- 2.1 Create Silver Schema (if not exists)
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'silver')
BEGIN
    EXEC('CREATE SCHEMA silver');
END
GO

-- 2.2 Transfer Tables
ALTER SCHEMA silver TRANSFER [staging].[account];
ALTER SCHEMA silver TRANSFER [staging].[card];
ALTER SCHEMA silver TRANSFER [staging].[client];
ALTER SCHEMA silver TRANSFER [staging].[disposition];
ALTER SCHEMA silver TRANSFER [staging].[district];
ALTER SCHEMA silver TRANSFER [staging].[loan];
ALTER SCHEMA silver TRANSFER [staging].[order];
ALTER SCHEMA silver TRANSFER [staging].[transaction];

-- 2.3 Cleanup
-- Drop staging schema if empty (Optional, strictly speaking we keep it for next load)
-- DROP SCHEMA staging; 

PRINT '>> PHASE 4 COMPLETE: Tables moved to Silver Layer.';
GO