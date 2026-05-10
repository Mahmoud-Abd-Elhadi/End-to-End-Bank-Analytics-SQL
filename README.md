# 🏦 Czech Bank Data Engineering & Analysis Project

![SQL Server](https://img.shields.io/badge/Database-SQL%20Server-CC2927?style=for-the-badge&logo=microsoft-sql-server)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)

## 📊 Interactive Dashboard
**[🔗 View the Live Dashboard on NovyPro](https://www.novypro.com/profile_projects/mahmoudabdalhadi?Popup=memberProject&Data=1778429109501x471091646274359940)**

*(Dashboard Preview)*
![Czech Bank Dashboard](https://github.com/Mahmoud-Abd-Elhadi/End-to-End-Bank-Analytics-SQL/blob/main/Image/Dashboard%20Img.png)

## 📌 Project Overview
This project is a comprehensive **End-to-End Data Engineering and Business Intelligence** solution. 

The goal was to transform raw banking data into a structured Data Warehouse using **Microsoft SQL Server**, and subsequently build a dynamic, interactive **Power BI** dashboard to extract actionable business insights regarding client metrics, cash flow patterns, and overall banking operations.

## 🚀 Technical Execution & Workflow

### 🛠️ Phase 1: Data Engineering (SQL Server)
* **Medallion Architecture:** Designed and implemented Bronze, Silver, and Gold layers to ingest, clean, and structure the raw data.
* **ETL Processes:** Executed complex T-SQL scripts to handle data transformation, resolve inconsistencies, and prepare the data for reporting.

### 📈 Phase 2: Business Intelligence (Power BI)
* **Data Connectivity:** Utilized **Import Mode** to load the clean Gold-layer datasets into Power BI, ensuring optimal performance and fast visual rendering.
* **Data Modeling:** Constructed a robust relational data model (Star Schema) to establish clear relationships between dimension and fact tables, ensuring accurate filtering.
* **Advanced DAX Calculations:** Engineered complex DAX formulas to create dynamic measures, including:
  * Time-Intelligence calculations for historical tracking.
  * Custom business KPIs such as Net Cash Flow, Loan to Deposit Ratio (LDR), and Cash Withdrawal Percentages.
  * Deep-dive analysis into client standing orders and card withdrawal volumes.
* **Dashboard Design:** Designed an intuitive, user-friendly UI with clean visualizations and interactive navigation panes for seamless stakeholder reporting.

## 📂 Repository Structure
The project files are organized as follows:
```text
├── 📂 Image/             # ER Diagrams, Schema snapshots, and Dashboard visualizations
├── 📂 script/            # SQL scripts (numbered 01-10) covering DDL, ETL, and Analysis
├── 📊 Czech_Bank.pbix    # Power BI Dashboard file
├── 📦 Dataset.zip        # Compressed raw CSV data (Accounts, Transactions, Loans, etc.)
└── 📄 README.md          # Project Documentation
```

---

## 👤 Author
**[Mahmoud Abd Elhadi]**
*Data Analyst*

<p align="left">
  <a href="https://www.linkedin.com/in/mahmoud-abd-elhadi/" target="_blank">
    <img src="https://img.icons8.com/color/48/000000/linkedin.png" alt="LinkedIn" width="40"/>
  </a>
  &nbsp;&nbsp;
  <a href="https://github.com/Mahmoud-Abd-Elhadi" target="_blank">
    <img src="https://img.icons8.com/fluent/48/000000/github.png" alt="GitHub" width="40"/>
  </a>
</p>
