# Tailwind Traders Power BI Case Project – SQL-Based ETL Workflow

## Overview
This document outlines the structured ETL workflow used to prepare and integrate raw CSV datasets into Power BI for the Tailwind Traders Capstone Project.  

To simulate enterprise-grade analytics, all datasets were first uploaded to **SQL Server**, enabling robust staging, normalization, and relational modeling. This approach highlights my skills in **ETL design**, **SQL schema development**, and **Power BI integration**.

---

## Source Datasets
- `Countries.csv`  
- `Purchases.csv`  
- `Sales.csv`  

---

## ETL Workflow

### 1. Extract – Raw CSV Ingestion
- Verified file integrity and schema consistency across all three datasets.  
- Imported each CSV into its respective **staging table** in SQL Server:
  - `dbo.Countries_Staging`  
  - `dbo.Purchases_Staging`  
  - `dbo.Sales_Staging`  

### 2. Transform – Staging & Data Cleaning
- Applied column trimming, null handling, and type casting in staging tables.  
- Added metadata fields (`LoadDate`, `SourceFile`) for traceability.  
- Removed duplicates and standardized naming conventions.  
- Validated foreign key references (e.g., country codes, product IDs).

### 3. Normalize – Relational Schema Design
- Migrated cleaned data into **normalized production tables**:
  - `dbo.Countries` – dimension table  
  - `dbo.Customers` – extracted from Sales  
  - `dbo.Products` – extracted from Purchases  
  - `dbo.Suppliers` – extracted from Purchases  
  - `dbo.Sales` – fact table  
  - `dbo.Purchases` – fact table  
- Applied **1NF–3NF normalization**:
  - Atomic fields and unique rows  
  - Lookup separation for reusable entities  
  - Referential integrity via foreign keys  

### 4. Load – SQL Server to Power BI
- Connected Power BI to SQL Server using native connectors.  
- Used **Power Query** for final shaping and filtering.  
- Built a star schema with clear relationships:
  - `Sales` and `Purchases` linked to `Customers`, `Products`, `Countries`, and `Calendar`  
- Created calculated tables for **Sales in USD** using historical exchange rates.

---

## Reporting & Automation
- Developed:
  - **Sales Overview** and **Profit Overview** reports  
  - **Executive Dashboard** with KPIs and drill-downs  
- Configured:
  - Mobile layout  
  - Daily alert for Gross Revenue USD < $400  
  - Subscriptions for automated report delivery  

---

## Key Takeaways
- Simulating SQL-based ingestion and normalization reflects real-world enterprise ETL pipelines.  
- Staging tables ensured clean, auditable data transformation.  
- Normalized schema supports scalable analytics and efficient Power BI modeling.  
- This workflow demonstrates readiness for roles involving **data engineering, reporting automation, and business intelligence**.
