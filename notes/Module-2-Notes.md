[Back to Notes ReadMe](Readme.md)

# Module 2 : Get Data in Power BI

*Learning Path: Prepare and visualize data with Microsoft Power BI*  
*Focus: Connecting to different data sources, storage modes, and performance considerations*

---

## Learning Objectives
By the end of this module, I can:
- Identify and connect to a data source
- Get data from relational databases (SQL Server)
- Get data from files (Excel, CSV, TXT)
- Get data from applications and online services
- Get data from Azure Analysis Services
- Select a storage mode (Import vs DirectQuery)
- Fix performance issues
- Resolve data import errors

---

## Introduction
Scenario: Tailwind Traders needs reports built from multiple sources:
- **SQL Server** → Sales transactions
- **Excel files** → HR employee data
- **Cosmos DB (NoSQL)** → Warehouse shipments
- **Azure Analysis Services** → Financial projections

Power BI + Power Query = unify, clean, and model this data before publishing reports.

---

## Get Data from Files
- **Flat files**: CSV, TXT, fixed width → single table, no hierarchy
- **Excel workbooks**: Common for HR and departmental data

**File locations:**
- Local → one‑time import, no sync
- OneDrive for Business → auto‑sync with semantic model
- OneDrive Personal → similar, but requires sign‑in
- SharePoint Team Sites → connect via URL or root folder

Best practice: Use cloud storage (OneDrive/SharePoint) for automatic synchronization.

---

## Get Data from Relational Databases
- Use **Get Data → SQL Server** in Power BI Desktop
- Enter **server name** + **database name**
- Choose **Import (default)** or **DirectQuery**
- Authenticate with:
  - Windows credentials
  - Database credentials
  - Microsoft account (for Azure)

**Options:**
- Load → bring data as‑is
- Transform Data → clean with Power Query before loading

---

## Import Data via SQL Query
Instead of loading entire tables:
- Write SQL queries to select only needed columns/rows
- Example:

```sql
SELECT ID, NAME, SALESAMOUNT
FROM SALES
WHERE OrderDate >= '2020-01-01'

