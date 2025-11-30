
CREATE TABLE Customers (
    CustomerID NVARCHAR(10) PRIMARY KEY,
    CustomerName NVARCHAR(100) NOT NULL,
    Address NVARCHAR(255),
    ZipCode NVARCHAR(20),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    LoyaltyPoints INT
);

CREATE TABLE Products (
    SKU NVARCHAR(20) PRIMARY KEY,
    ProductName NVARCHAR(100) NOT NULL,
    ProductDescription NVARCHAR(255),
    ProductCategory NVARCHAR(50),
    Weight NVARCHAR(20),
    Color NVARCHAR(20),
    Size NVARCHAR(20),
    Rating DECIMAL(3,1),
    Stock INT
);

CREATE TABLE Sales (
    OrderID INT PRIMARY KEY,
    CustomerID NVARCHAR(10) NOT NULL,
    SKU NVARCHAR(20) NOT NULL,
    GrossProductPrice DECIMAL(10,2),
    TaxPerProduct DECIMAL(10,2),
    QuantityPurchased INT,
    GrossRevenue DECIMAL(10,2),
    TotalTax DECIMAL(10,2),
    NetRevenue DECIMAL(10,2),
    CountryID INT,
    SalesRep NVARCHAR(50),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (SKU) REFERENCES Products(SKU)
);

CREATE TABLE Sales_Staging (
    OrderID INT,
    CustomerName NVARCHAR(100),
    ProductName NVARCHAR(100),
    ProductDescription NVARCHAR(255),
    GrossProductPrice DECIMAL(10,2),
    TaxPerProduct DECIMAL(10,2),
    QuantityPurchased INT,
    GrossRevenue DECIMAL(10,2),
    TotalTax DECIMAL(10,2),
    NetRevenue DECIMAL(10,2),
    ProductCategory NVARCHAR(50),
    SKU NVARCHAR(20),
    Weight NVARCHAR(20),
    Color NVARCHAR(20),
    Size NVARCHAR(20),
    Rating DECIMAL(3,1),
    Stock INT,
    CountryID INT,
    SalesRep NVARCHAR(50),
    CustomerID NVARCHAR(10),
    Address NVARCHAR(255),
    ZipCode NVARCHAR(20),
    Phone NVARCHAR(20),
    Email NVARCHAR(100),
    LoyaltyPoints INT
);


BULK INSERT Sales_Staging
FROM 'C:\Users\edtid\Downloads\Sales.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2, -- skip header row
    FIELDTERMINATOR = ',', -- comma separated
    ROWTERMINATOR = '\n',
    TABLOCK
);


INSERT INTO Customers (CustomerID, CustomerName, Address, ZipCode, Phone, Email, LoyaltyPoints)
SELECT DISTINCT CustomerID, CustomerName, Address, ZipCode, Phone, Email, LoyaltyPoints
FROM Sales_Staging;



INSERT INTO Products (SKU, ProductName, ProductDescription, ProductCategory, Weight, Color, Size, Rating, Stock)
SELECT DISTINCT SKU, ProductName, ProductDescription, ProductCategory, Weight, Color, Size, Rating, Stock
FROM Sales_Staging;


INSERT INTO Sales (OrderID, CustomerID, SKU, GrossProductPrice, TaxPerProduct, QuantityPurchased,
                   GrossRevenue, TotalTax, NetRevenue, CountryID, SalesRep)
SELECT OrderID, CustomerID, SKU, GrossProductPrice, TaxPerProduct, QuantityPurchased,
       GrossRevenue, TotalTax, NetRevenue, CountryID, SalesRep
FROM Sales_Staging;


SELECT COUNT(*) AS CustomersCount FROM Customers;
SELECT COUNT(*) AS ProductsCount FROM Products;
SELECT COUNT(*) AS SalesCount FROM Sales;

-- Customers
-- PK already exists, so skip adding it again
-- Unique Email
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'UQ_Customers_Email'
)
ALTER TABLE Customers
ADD CONSTRAINT UQ_Customers_Email UNIQUE (Email);

-- Loyalty Points >= 0
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Customers_LoyaltyPoints'
)
ALTER TABLE Customers
ADD CONSTRAINT CK_Customers_LoyaltyPoints CHECK (LoyaltyPoints >= 0);

-- Rating between 0 and 5
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Products_Rating'
)
ALTER TABLE Products
ADD CONSTRAINT CK_Products_Rating CHECK (Rating BETWEEN 0 AND 5);

-- Index on ProductCategory
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'IX_Products_Category'
)
CREATE INDEX IX_Products_Category ON Products(ProductCategory);

-- Primary Key on OrderID (only if not already defined)

-- Primary Key on OrderID
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE type = 'PK'
      AND parent_object_id = OBJECT_ID('Sales')
)
ALTER TABLE Sales
ADD CONSTRAINT PK_Sales PRIMARY KEY (OrderID);

-- Foreign Key to Customers
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Sales_Customers'
)
ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);

-- Foreign Key to Products
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Sales_Products'
)
ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Products FOREIGN KEY (SKU) REFERENCES Products(SKU);

-- Quantity > 0
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Sales_Quantity'
)
ALTER TABLE Sales
ADD CONSTRAINT CK_Sales_Quantity CHECK (QuantityPurchased > 0);

-- Indexes for joins
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'IX_Sales_CustomerID'
)
CREATE INDEX IX_Sales_CustomerID ON Sales(CustomerID);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'IX_Sales_SKU'
)
CREATE INDEX IX_Sales_SKU ON Sales(SKU);

/* ============================
   Customers Table
   ============================ */
-- Unique Email
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'UQ_Customers_Email'
)
ALTER TABLE Customers
ADD CONSTRAINT UQ_Customers_Email UNIQUE (Email);

-- Loyalty Points >= 0
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Customers_LoyaltyPoints'
)
ALTER TABLE Customers
ADD CONSTRAINT CK_Customers_LoyaltyPoints CHECK (LoyaltyPoints >= 0);


/* ============================
   Products Table
   ============================ */
-- Rating between 0 and 5
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Products_Rating'
)
ALTER TABLE Products
ADD CONSTRAINT CK_Products_Rating CHECK (Rating BETWEEN 0 AND 5);

-- Index on ProductCategory
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'IX_Products_Category'
)
CREATE INDEX IX_Products_Category ON Products(ProductCategory);


/* ============================
   Sales Table
   ============================ */
-- Primary Key on OrderID
IF NOT EXISTS (
    SELECT 1
    FROM sys.key_constraints
    WHERE type = 'PK'
      AND parent_object_id = OBJECT_ID('Sales')
)
ALTER TABLE Sales
ADD CONSTRAINT PK_Sales PRIMARY KEY (OrderID);

-- Foreign Key to Customers
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Sales_Customers'
)
ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Customers FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID);

-- Foreign Key to Products
IF NOT EXISTS (
    SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Sales_Products'
)
ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Products FOREIGN KEY (SKU) REFERENCES Products(SKU);

-- Quantity > 0
IF NOT EXISTS (
    SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Sales_Quantity'
)
ALTER TABLE Sales
ADD CONSTRAINT CK_Sales_Quantity CHECK (QuantityPurchased > 0);

-- Indexes for joins
IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'IX_Sales_CustomerID'
)
CREATE INDEX IX_Sales_CustomerID ON Sales(CustomerID);

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes WHERE name = 'IX_Sales_SKU'
)
CREATE INDEX IX_Sales_SKU ON Sales(SKU);

-- Constraints
SELECT name, type_desc, parent_object_id
FROM sys.objects
WHERE type_desc LIKE '%CONSTRAINT%'
AND parent_object_id IN (
    OBJECT_ID('Customers'),
    OBJECT_ID('Products'),
    OBJECT_ID('Sales')
);

-- Indexes
SELECT name, object_id
FROM sys.indexes
WHERE object_id IN (
    OBJECT_ID('Customers'),
    OBJECT_ID('Products'),
    OBJECT_ID('Sales')
);

CREATE TABLE Suppliers (
    SupplierID INT IDENTITY PRIMARY KEY,
    SupplierName NVARCHAR(100) UNIQUE
);

CREATE TABLE Purchases (
    PurchaseID INT PRIMARY KEY,
    SupplierID INT NOT NULL,
    OrderID INT NOT NULL,
    LastVisited DATE,
    ReturnStatus NVARCHAR(20),
    WarrantyMonths INT,
    PurchaseDate DATE,
    ReturnPolicyDays INT,
    Feedback NVARCHAR(50),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID),
    FOREIGN KEY (OrderID) REFERENCES Sales(OrderID)
);

CREATE TABLE Countries (
    CountryID INT PRIMARY KEY,
    Country NVARCHAR(50) UNIQUE,
    ExchangeID INT
);

BULK INSERT Countries
FROM 'C:\Users\edtid\Downloads\Countries.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2, -- skip header row
    FIELDTERMINATOR = ',', -- comma separated
    ROWTERMINATOR = '\n',
    TABLOCK
);

SELECT * FROM Countries;

ALTER TABLE Sales
ADD CONSTRAINT FK_Sales_Countries FOREIGN KEY (CountryID) REFERENCES Countries(CountryID);



/* ============================
   Step 1: Purchases Staging
   ============================ */
IF OBJECT_ID('Purchases_Staging', 'U') IS NOT NULL
    DROP TABLE Purchases_Staging;

CREATE TABLE Purchases_Staging (
    PurchaseID INT,
    Supplier NVARCHAR(100),
    LastVisited DATE,
    ReturnStatus NVARCHAR(20),
    WarrantyMonths INT,
    PurchaseDate DATE,
    ReturnPolicyDays INT,
    Feedback NVARCHAR(50),
    OrderID INT
);

-- Bulk insert Purchases.csv
BULK INSERT Purchases_Staging
FROM 'C:\Users\edtid\Downloads\Purchases.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    TABLOCK
);


/* ============================
   Step 2: Normalized Tables
   ============================ */
IF OBJECT_ID('Suppliers', 'U') IS NULL
BEGIN
    CREATE TABLE Suppliers (
        SupplierID INT IDENTITY PRIMARY KEY,
        SupplierName NVARCHAR(100) UNIQUE
    );
END;

IF OBJECT_ID('Purchases', 'U') IS NULL
BEGIN
    CREATE TABLE Purchases (
        PurchaseID INT PRIMARY KEY,
        SupplierID INT NOT NULL,
        OrderID INT NOT NULL,
        LastVisited DATE,
        ReturnStatus NVARCHAR(20),
        WarrantyMonths INT,
        PurchaseDate DATE,
        ReturnPolicyDays INT,
        Feedback NVARCHAR(50)
    );
END;


/* ============================
   Step 3: Populate Normalized Tables
   ============================ */
-- Insert unique suppliers
INSERT INTO Suppliers (SupplierName)
SELECT DISTINCT Supplier
FROM Purchases_Staging
WHERE Supplier NOT IN (SELECT SupplierName FROM Suppliers);

-- Insert purchases with SupplierID lookup
INSERT INTO Purchases (PurchaseID, SupplierID, OrderID, LastVisited, ReturnStatus,
                       WarrantyMonths, PurchaseDate, ReturnPolicyDays, Feedback)
SELECT ps.PurchaseID, s.SupplierID, ps.OrderID, ps.LastVisited, ps.ReturnStatus,
       ps.WarrantyMonths, ps.PurchaseDate, ps.ReturnPolicyDays, ps.Feedback
FROM Purchases_Staging ps
JOIN Suppliers s ON ps.Supplier = s.SupplierName;


/* ============================
   Step 4: Constraints & Indexes
   ============================ */
-- Foreign Keys
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Purchases_Suppliers')
ALTER TABLE Purchases
ADD CONSTRAINT FK_Purchases_Suppliers FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID);

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Purchases_Sales')
ALTER TABLE Purchases
ADD CONSTRAINT FK_Purchases_Sales FOREIGN KEY (OrderID) REFERENCES Sales(OrderID);

-- Business Rules
IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Purchases_Warranty')
ALTER TABLE Purchases
ADD CONSTRAINT CK_Purchases_Warranty CHECK (WarrantyMonths > 0);

IF NOT EXISTS (SELECT 1 FROM sys.check_constraints WHERE name = 'CK_Purchases_ReturnPolicy')
ALTER TABLE Purchases
ADD CONSTRAINT CK_Purchases_ReturnPolicy CHECK (ReturnPolicyDays BETWEEN 0 AND 60);

-- Indexes
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Purchases_SupplierID')
CREATE INDEX IX_Purchases_SupplierID ON Purchases(SupplierID);

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Purchases_OrderID')
CREATE INDEX IX_Purchases_OrderID ON Purchases(OrderID);

/* ============================
   1. Check Table Row Counts
   ============================ */
SELECT 'Countries' AS TableName, COUNT(*) AS TotalRows FROM Countries
UNION ALL
SELECT 'Suppliers', COUNT(*) FROM Suppliers
UNION ALL
SELECT 'Purchases', COUNT(*) FROM Purchases
UNION ALL
SELECT 'Sales', COUNT(*) FROM Sales
UNION ALL
SELECT 'Customers', COUNT(*) FROM Customers
UNION ALL
SELECT 'Products', COUNT(*) FROM Products;


/* ============================
   2. Check Constraints
   ============================ */
SELECT parent.name AS TableName, obj.name AS ConstraintName, obj.type_desc
FROM sys.objects obj
JOIN sys.tables parent ON obj.parent_object_id = parent.object_id
WHERE obj.type_desc LIKE '%CONSTRAINT%'
AND parent.name IN ('Purchases','Sales','Customers','Products');


/* ============================
   3. Check Indexes
   ============================ */
SELECT t.name AS TableName, i.name AS IndexName, i.type_desc
FROM sys.indexes i
JOIN sys.tables t ON i.object_id = t.object_id
WHERE t.name IN ('Purchases','Sales','Customers','Products')
AND i.name IS NOT NULL;


/* ============================
   4. Check Foreign Keys
   ============================ */
SELECT fk.name AS FKName, tp.name AS ParentTable, tr.name AS RefTable
FROM sys.foreign_keys fk
JOIN sys.tables tp ON fk.parent_object_id = tp.object_id
JOIN sys.tables tr ON fk.referenced_object_id = tr.object_id
WHERE tp.name IN ('Purchases','Sales');


