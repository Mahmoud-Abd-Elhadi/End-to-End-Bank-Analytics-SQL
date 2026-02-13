/*
===============================================================================
Project:        Czech Bank Data Engineering & Analysis
File:           02_Transformation_Silver.sql
Description:    Phase 2: Data Transformation & Standardization.
                - Translate Czech values to English.
                - Normalize categorical values (Payment Reasons, Transaction Types).
                - Parse and Convert Date columns (from 'YYMMDD' string format to DATE type).
                - Extract Gender and Birthdate from Birth Number.
===============================================================================
*/

USE Bank_Analytics_DW;
GO

-- =============================================================================
-- 1.0 Value Standardization & Translation
-- =============================================================================
-- Purpose: Translate Czech terms to English and normalize categorical data.
-- =============================================================================
PRINT '>> Starting Transformation (Translation & Standardization)...';


-- 1.1 Standardize Regions (District Table)
UPDATE [staging].[district]
SET region = 
    CASE 
        WHEN region = 'Prague' OR region = 'Praha' THEN 'Prague'
        WHEN region = 'central Bohemia' OR region = 'Stredni Cechy' THEN 'Central Bohemia'
        WHEN region = 'South Bohemia'   OR region = 'Jizni Cechy'   THEN 'South Bohemia'
        WHEN region = 'West Bohemia'    OR region = 'Zapadni Cechy' THEN 'West Bohemia'
        WHEN region = 'North Bohemia'   OR region = 'Severni Cechy' THEN 'North Bohemia'
        WHEN region = 'East Bohemia'    OR region = 'Vychodni Cechy'THEN 'East Bohemia'
        WHEN region = 'South Moravia'   OR region = 'Jizni Morava'  THEN 'South Moravia'
        WHEN region = 'North Moravia'   OR region = 'Severni Morava'THEN 'North Moravia'
        ELSE region
    END;

 
UPDATE [staging].[district]
SET district_name =
    CASE 
        WHEN district_name = 'Hl.m. Praha' THEN 'Prague'
        ELSE district_name
    END;


-- 1.2 Standardize Statement Frequency (Account Table)
UPDATE [staging].[account]
SET statement_freq = 
    CASE 
        WHEN statement_freq = 'POPLATEK MESICNE'   THEN 'Monthly Issuance'
        WHEN statement_freq = 'POPLATEK TYDNE'     THEN 'Weekly Issuance'
        WHEN statement_freq = 'POPLATEK PO OBRATU' THEN 'Issuance After Transaction'
        ELSE statement_freq 
    END;


-- 1.3 Standardize Disposition Type (Disposition Table)
UPDATE [staging].[disposition]
SET disp_type = 
    CASE 
        WHEN disp_type LIKE '%OWNER%'     THEN 'Owner'       
        WHEN disp_type LIKE '%DISPONENT%' THEN 'User'         
        ELSE disp_type 
    END;


-- 1.4 Standardize Card Type (Card Table)
UPDATE [staging].[card]
SET card_type = 
    CASE 
        WHEN card_type = 'junior'  THEN 'Junior'
        WHEN card_type = 'classic' THEN 'Classic'
        WHEN card_type = 'gold'    THEN 'Gold'
        ELSE card_type 
    END;


-- 1.5 Standardize Loan Status (Loan Table)
-- Ensure the column is large enough for English descriptions
ALTER TABLE [staging].[loan]
ALTER COLUMN loan_status VARCHAR(50)

UPDATE [staging].[loan]
SET loan_status = 
    CASE 
        WHEN loan_status LIKE '%A%' THEN 'Finished - Good Standing'  
        WHEN loan_status LIKE '%B%' THEN 'Finished - Defaulted'      
        WHEN loan_status LIKE '%C%' THEN 'Running - Good Standing'   
        WHEN loan_status LIKE '%D%' THEN 'Running - In Debt'          
        ELSE loan_status 
    END;


-- 1.6 Standardize Payment Reason (Order Table)
UPDATE [staging].[order]
SET payment_reason = 
    CASE 
        WHEN payment_reason LIKE '%POJISTNE%' THEN 'Insurance Payment'
        WHEN payment_reason LIKE '%SIPO%'     THEN 'Household Payment'
        WHEN payment_reason LIKE '%LEASING%'  THEN 'Leasing Payment'
        WHEN payment_reason LIKE '%UVER%'     THEN 'Loan Payment'
        ELSE payment_reason
    END;

 
-- 1.7 Standardize Transaction Types & Methods (Transaction Table)
UPDATE [staging].[transaction]
SET trans_type = 
    CASE 
        WHEN trans_type = 'PRIJEM' THEN 'Credit'        
        WHEN trans_type = 'VYDAJ'  THEN 'Withdrawal'   
        WHEN trans_type = 'VYBER'  THEN 'Withdrawal'    
        ELSE trans_type
    END;

 
UPDATE [staging].[transaction]
SET trans_method = 
    CASE 
        WHEN trans_method = 'VYBER KARTOU'   THEN 'Credit Card Withdrawal'     
        WHEN trans_method = 'VKLAD'          THEN 'Credit in Cash'              
        WHEN trans_method = 'PREVOD Z UCTU'  THEN 'Collection from Another Bank'  
        WHEN trans_method = 'VYBER'          THEN 'Cash Withdrawal'             
        WHEN trans_method = 'PREVOD NA UCET' THEN 'Remittance to Another Bank'  
        ELSE trans_method
    END;

 
UPDATE [staging].[transaction]
SET trans_category = 
    CASE 
        WHEN trans_category = 'POJISTNE'    THEN 'Insurance Payment'    
        WHEN trans_category = 'SLUZBY'      THEN 'Statement Payment'   
        WHEN trans_category = 'UROK'        THEN 'Interest Credited'    
        WHEN trans_category = 'SANKC. UROK' THEN 'Sanction Interest'    
        WHEN trans_category = 'SIPO'        THEN 'Household Payment'    
        WHEN trans_category = 'DUCHOD'      THEN 'Old-age Pension'      
        WHEN trans_category = 'UVER'        THEN 'Loan Payment'         
        ELSE trans_category
    END;

-- =============================================================================
-- 2.0 Date Parsing & Logic Application
-- =============================================================================
-- Purpose: Convert raw 'YYMMDD' strings into proper DATE types.
--          Extract Gender from birth number logic.
-- =============================================================================
PRINT '>> Starting Date Parsing & Logic...';
--------------
-- 2.1 Client: Extract Birth Date & Gender from 'birth_number'
-- Logic: YYMMDD. If MM > 50, it's Female (MM-50 is the month).
--------------
SELECT
   birth_number ,
   SUBSTRING(birth_number , 1 , 2) + 1900 
FROM [staging].[client]


SELECT 
    CAST(
        CONCAT(
          CAST(SUBSTRING(birth_number , 1 , 2) + 1900  AS INT)  , '-' ,
               CASE
                   WHEN CAST(SUBSTRING(birth_number , 3 , 2) AS INT) > 50 THEN CAST(SUBSTRING(birth_number , 3 , 2) AS INT) - 50
                   ELSE CAST(SUBSTRING(birth_number , 3 , 2) AS INT)
               END  , '-' ,
               CAST(SUBSTRING(birth_number , 5 , 2) AS INT)
               )
               AS DATE ) AS birthdate
FROM [staging].[client]

ALTER TABLE [staging].[client]
ADD birthdate DATE

UPDATE [staging].[client]
SET birthdate = DATEFROMPARTS (
                    CAST(SUBSTRING(birth_number , 1 , 2) + 1900  AS INT) ,
                    CASE
                        WHEN CAST(SUBSTRING(birth_number , 3 , 2) AS INT) > 50 
                        THEN CAST(SUBSTRING(birth_number , 3 , 2) AS INT) - 50
                        ELSE CAST(SUBSTRING(birth_number , 3 , 2) AS INT)
                    END ,
                    CAST(SUBSTRING(birth_number , 5 , 2) AS INT)
                    )

ALTER TABLE [staging].[client] 
ADD gender VARCHAR(15)

UPDATE [staging].[client] 
SET gender =  CASE
                  WHEN CAST(SUBSTRING(birth_number , 3 , 2) AS INT) > 50 THEN 'Female'
                  ELSE 'Male'
              END

-- Drop original column as it's no longer needed
ALTER TABLE [staging].[client] 
DROP COLUMN birth_number
 
-------------- 
-- 2.2 Account: Convert 'date_opened' to DATE
-------------- 
SELECT * FROM [staging].[account]

ALTER TABLE [staging].[account]
ADD created_date DATE

UPDATE [staging].[account]
SET created_date = DATEFROMPARTS (
                        CAST(SUBSTRING(date_opened , 1 , 2) AS INT) + 1900 ,
                        CAST(SUBSTRING(date_opened , 3 , 2) AS INT) ,
                        CAST(SUBSTRING(date_opened , 5 , 2) AS INT)
                        )

ALTER TABLE [staging].[account]
DROP COLUMN date_opened

------------
-- 2.3 Card: Convert 'issued_date' to DATE
-- First, ensure it's in a format we can update (it's NVARCHAR(50))
------------
SELECT * FROM [staging].[card]

UPDATE [staging].[card]
SET issued_date = DATEFROMPARTS (
                         CAST(SUBSTRING(issued_date , 1 , 2) AS INT) + 1900 ,
                         CAST(SUBSTRING(issued_date , 3 , 2) AS INT) ,
                         CAST(SUBSTRING(issued_date , 5 , 2) AS INT)
                         )

------------
-- 2.4 Loan: Convert 'loan_date' to DATE
------------
SELECT * FROM [staging].[loan]

ALTER TABLE [staging].[loan]
ALTER COLUMN loan_date VARCHAR(20)

UPDATE [staging].[loan]
SET loan_date = DATEFROMPARTS (
                         CAST(SUBSTRING(loan_date , 1 , 2) AS INT) + 1900 ,
                         CAST(SUBSTRING(loan_date , 3 , 2) AS INT)  ,
                         CAST(SUBSTRING(loan_date , 5 , 2) AS INT)
                         )

-------------------
-- 2.5 Transaction: Convert 'trans_date' to DATE
-------------------
SELECT * FROM [staging].[transaction]

ALTER TABLE [staging].[transaction]
ALTER COLUMN trans_date VARCHAR(20)

UPDATE [staging].[transaction]
SET trans_date = DATEFROMPARTS (
                         CAST(SUBSTRING(trans_date , 1 , 2) AS INT) + 1900 ,
                         CAST(SUBSTRING(trans_date , 3 , 2) AS INT)  ,
                         CAST(SUBSTRING(trans_date , 5 , 2) AS INT)
                         )
--======================================================================

PRINT '   Date parsing complete.';
PRINT '>> PHASE 3 COMPLETE: Data Transformed and Standardized.';
GO