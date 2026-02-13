# 🏦 Czech Bank Data Engineering & Analysis Project

![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

## 📌 Project Overview
This project is an **End-to-End Data Engineering and Analytics** solution built using **Microsoft SQL Server (T-SQL)**.

The goal was to transform raw banking data into a structured Data Warehouse using the **Medallion Architecture (Bronze, Silver, Gold)**, and then perform advanced financial analysis to extract actionable business insights regarding loan risks, customer behavior, and financial trends.

## 📂 Repository Structure

The project files are organized as follows:

```text
├── 📂 Image/           # ER Diagrams, Schema snapshots, and Analysis visualizations
├── 📂 script/          # SQL scripts (numbered 01-10) covering DDL, ETL, and Analysis
├── 📦 Dataset.zip      # Compressed raw CSV data (Accounts, Transactions, Loans, etc.)
└── 📄 README.md        # Project Documentation

## 📌 Project Overview
End-to-End Data Engineering and Analysis project using **Microsoft SQL Server**. The project involves building a Data Warehouse (Bronze, Silver, Gold layers), performing ETL processes, and conducting advanced financial analysis on real-world banking data to extract actionable business insights.

## 🛠️ Tools & Technologies
- **Database:** SQL Server (SSMS)
- **Language:** T-SQL (CTE, Window Functions, Aggregations, Complex Joins, Stored Procedures)
- **Concept:** Data Warehousing (Medallion Architecture: Bronze -> Silver -> Gold)

## 📂 Project Structure
The repository is organized as follows:

1.  **`script/` Folder:** Contains 10 SQL scripts covering the entire pipeline:
    * **01-02:** DDL & Bronze Layer (Raw Data Ingestion).
    * **03-05:** Silver Layer (Data Cleaning & Standardization).
    * **06:** Gold Layer (Star Schema Modeling).
    * **07-10:** Advanced Analysis (Risk, Customers, Trends, Products).
2.  **`Image/` Folder:** ER Diagrams and analysis visualizations.
3.  **`Dataset.zip`:** Compressed raw CSV data (Accounts, Loans, Transactions, etc.).

## 📊 Key Analysis Modules
1.  **Loan Portfolio & Risk Management:**
    * Calculated default rates (Volume vs. Value) and vintage analysis.
2.  **Customer Behavior & Demographics:**
    * Segmented customers by age, gender, and financial wealth (Balance Tiers).
3.  **Financial Trends:**
    * Year-over-Year (YoY) growth and cash flow analysis (Inflow vs. Outflow).
4.  **Product Performance:**
    * Analyzed Credit Card product mix (Junior, Classic, Gold) and regional adoption.

## 💡 Key Insights
- **Risk Analysis:** Identified specific years with higher default rates, correlating with economic shifts.
- **Customer Segmentation:** The majority of high-net-worth clients hold **Gold Cards**, with a strong presence in the capital region.
- **Seasonality:** **December** consistently accounts for the highest transaction volume annually due to holiday spending.

## 🚀 How to Run
1.  **Clone** this repository.
2.  **Unzip** the `Dataset.zip` file into a folder named `data`.
3.  **Open SSMS** and connect to your SQL Server instance.
4.  **Run Scripts** inside the `script` folder sequentially from `01` to `10`.

---
*Author: [Your Name]*
*LinkedIn: [Your LinkedIn Profile Link]*
