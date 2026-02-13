/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           04_Gold_Data_Modeling.sql
Description:    Phase 4: Gold Layer Modeling.
                - Create the Gold Schema.
                - Replicate tables from Silver to Gold.
                - Apply Data Constraints (Primary Keys).
                - Define Relationships (Foreign Keys).
===============================================================================
*/

USE Bank_Analytics_DW;
GO

-- =============================================================================
-- 1.0 DDL & Data Replication (Silver -> Gold)
-- =============================================================================
-- Purpose: Create Dimension and Fact tables in the Gold schema by copying
--          clean data from the Silver layer.
-- =============================================================================

PRINT '>> Starting Gold Layer Modeling...';

CREATE SCHEMA gold;
GO

-- 1.1 Copy Tables
SELECT * INTO [gold].[district]    FROM [silver].[district];
SELECT * INTO [gold].[client]      FROM [silver].[client];
SELECT * INTO [gold].[account]     FROM [silver].[account];
SELECT * INTO [gold].[disposition] FROM [silver].[disposition];
SELECT * INTO [gold].[card]        FROM [silver].[card];
SELECT * INTO [gold].[loan]        FROM [silver].[loan];
SELECT * INTO [gold].[order]       FROM [silver].[order];
SELECT * INTO [gold].[transaction] FROM [silver].[transaction];

PRINT '   Tables replicated to Gold schema.';
GO

-- =============================================================================
-- 2.0 Defining Primary Keys (Integrity Constraints)
-- =============================================================================
-- Purpose: Ensure entity integrity by defining Primary Keys.
-- Note: Columns must be altered to NOT NULL before setting them as PK.
-- =============================================================================

PRINT '>> Applying Primary Keys...';

-- 2.1 District PK
ALTER TABLE [gold].[district] ALTER COLUMN [district_id] INT NOT NULL;
ALTER TABLE [gold].[district] ADD CONSTRAINT PK_gold_district PRIMARY KEY ([district_id]);

-- 2.2 Client PK
ALTER TABLE [gold].[client] ALTER COLUMN [client_id] INT NOT NULL;
ALTER TABLE [gold].[client] ADD CONSTRAINT PK_gold_client PRIMARY KEY ([client_id]);

-- 2.3 Account PK
ALTER TABLE [gold].[account] ALTER COLUMN [account_id] INT NOT NULL;
ALTER TABLE [gold].[account] ADD CONSTRAINT PK_gold_account PRIMARY KEY ([account_id]);

-- 2.4 Disposition PK
ALTER TABLE [gold].[disposition] ALTER COLUMN [disp_id] INT NOT NULL;
ALTER TABLE [gold].[disposition] ADD CONSTRAINT PK_gold_disposition PRIMARY KEY ([disp_id]);

-- 2.5 Card PK
ALTER TABLE [gold].[card] ALTER COLUMN [card_id] INT NOT NULL;
ALTER TABLE [gold].[card] ADD CONSTRAINT PK_gold_card PRIMARY KEY ([card_id]);

-- 2.6 Loan PK
ALTER TABLE [gold].[loan] ALTER COLUMN [loan_id] INT NOT NULL;
ALTER TABLE [gold].[loan] ADD CONSTRAINT PK_gold_loan PRIMARY KEY ([loan_id]);

-- 2.7 Order PK
ALTER TABLE [gold].[order] ALTER COLUMN [order_id] INT NOT NULL;
ALTER TABLE [gold].[order] ADD CONSTRAINT PK_gold_order PRIMARY KEY ([order_id]);

-- 2.8 Transaction PK
ALTER TABLE [gold].[transaction] ALTER COLUMN [trans_id] INT NOT NULL;
ALTER TABLE [gold].[transaction] ADD CONSTRAINT PK_gold_transaction PRIMARY KEY ([trans_id]);

PRINT '   Primary Keys applied.';
GO

-- =============================================================================
-- 3.0 Defining Foreign Keys (Relationships)
-- =============================================================================
-- Purpose: Enforce referential integrity and define the Snowflake Schema relationships.
-- =============================================================================

PRINT '>> Applying Foreign Keys...';

-- 3.1 Client Relationships
-- Relationship: Client -> District
ALTER TABLE [gold].[client]
ADD CONSTRAINT FK_client_district 
FOREIGN KEY ([district_id]) REFERENCES [gold].[district]([district_id]);

-- 3.2 Account Relationships
-- Relationship: Account -> District
ALTER TABLE [gold].[account]
ADD CONSTRAINT FK_account_district 
FOREIGN KEY ([district_id]) REFERENCES [gold].[district]([district_id]);

-- 3.3 Disposition Relationships
-- Relationship: Disposition -> Client
ALTER TABLE [gold].[disposition]
ADD CONSTRAINT FK_disposition_client 
FOREIGN KEY ([client_id]) REFERENCES [gold].[client]([client_id]);

-- Relationship: Disposition -> Account
ALTER TABLE [gold].[disposition]
ADD CONSTRAINT FK_disposition_account 
FOREIGN KEY ([account_id]) REFERENCES [gold].[account]([account_id]);

-- 3.4 Card Relationships
-- Relationship: Card -> Disposition
ALTER TABLE [gold].[card]
ADD CONSTRAINT FK_card_disposition 
FOREIGN KEY ([disp_id]) REFERENCES [gold].[disposition]([disp_id]);

-- 3.5 Loan Relationships
-- Relationship: Loan -> Account
ALTER TABLE [gold].[loan]
ADD CONSTRAINT FK_loan_account
FOREIGN KEY ([account_id]) REFERENCES [gold].[account]([account_id]);

-- 3.6 Order Relationships
-- Relationship: Order -> Account
ALTER TABLE [gold].[order]
ADD CONSTRAINT FK_order_account
FOREIGN KEY ([account_id]) REFERENCES [gold].[account]([account_id]);

-- 3.7 Transaction Relationships
-- Relationship: Transaction -> Account
ALTER TABLE [gold].[transaction]
ADD CONSTRAINT FK_transaction_account
FOREIGN KEY ([account_id]) REFERENCES [gold].[account]([account_id]);

PRINT '   Foreign Keys applied.';
PRINT '>> PHASE 5 COMPLETE: Data Modeling (Gold Layer) Finalized.';
GO