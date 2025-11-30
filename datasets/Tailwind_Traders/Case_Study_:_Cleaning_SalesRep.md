# Case Study: Cleaning SalesRep Data in TailwindTradersDB

## Objective
_Ensure reliable filtering and reporting in **TailwindTradersDB** by diagnosing and fixing hidden whitespace issues in the `SalesRep` column of the `Sales` table._

## Problem Discovery
At first, queries like:

```sql
SELECT * FROM Sales WHERE SalesRep = 'Alice';
```
returned no rows, even though the  column visibly contained values such as .

## Diagnostic Process
### Step 1 – Check string length

```Sql
SELECT DISTINCT SalesRep, LEN(SalesRep) AS Length
FROM Sales
WHERE SalesRep LIKE 'Alice%';
```
Result:  → unexpected extra character.

### Step 2 – Inspect hidden characters

```sql
SELECT 
    SalesRep,
    LEN(SalesRep) AS Length,
    DATALENGTH(SalesRep) AS ByteLength,
    ASCII(LEFT(SalesRep, 1)) AS FirstCharCode,
    ASCII(RIGHT(SalesRep, 1)) AS LastCharCode
FROM Sales
WHERE SalesRep LIKE 'Alice%';
```
Result:  → trailing space detected.

### Step 3 – Flexible filter test

```sql
SELECT * 
FROM Sales 
WHERE LTRIM(RTRIM(SalesRep)) = 'Alice';
```
Returned correct rows, confirming whitespace issue.

## Attempted Batch Cleanup
Tried a dynamic script to trim all string columns across all tables:

```sql
UPDATE [Customers]
SET [CustomerID] = LTRIM(RTRIM([CustomerID]))
WHERE [CustomerID] IS NOT NULL;

UPDATE [Products]
SET [SKU] = LTRIM(RTRIM([SKU]))
WHERE [SKU] IS NOT NULL;

UPDATE [Sales]
SET [CustomerID] = LTRIM(RTRIM([CustomerID]))
WHERE [CustomerID] IS NOT NULL;
```

## Constraint Conflicts
### Errors occurred:
- `CustomerID` in Sales referencing `Customers`
- `SKU` in Sales referencing `Products`

### Lesson:
_Do not blindly trim primary/foreign key columns. SQL Server enforces referential integrity, so updates must be handled transactionally or skipped._

## Final Solution
Focus cleanup on descriptive/text fields only:
```sql
UPDATE Sales
SET SalesRep = LTRIM(RTRIM(SalesRep))
WHERE SalesRep IS NOT NULL;
```

## Verification:
Rows returned correctly after cleanup.

```sql
SELECT * FROM Sales WHERE SalesRep = 'Alice';
```

## This case demonstrates:
- **Diagnostic rigor:** -  Using `LEN`, `DATALENGTH`, and `ASCII` and  to uncover hidden characters.
- **Safe remediation:** - Applying `LTRIM/RTRIM`  only where appropriate.
- **Constraint awareness:** - Respecting relational integrity when cleaning data.
- **Business impact:** Restored reliable filtering and Power BI slicing by SalesRep.

## Next Steps
- Wrap cleanup into a stored procedure (`dbo.TrimSalesRep`).
- Schedule nightly trims via SQL Server Agent post-ETL.
- Extend hygiene checks to other descriptive fields - across `Customers`, `Products`, and `Orders`.
