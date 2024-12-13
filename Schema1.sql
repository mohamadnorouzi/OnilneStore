--------- Create Tables : -----------------------------------------------------
-- جدول مشتریان

CREATE TABLE Customers
(
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    -- شناسه یکتا برای هر مشتری
    FullName NVARCHAR(100) NOT NULL,
    -- نام و نام خانوادگی مشتری
    Email NVARCHAR(100) NOT NULL UNIQUE,
    -- آدرس ایمیل مشتری، باید یکتا باشد
    Phone NVARCHAR(15),
    -- شماره تلفن مشتری
    Address NVARCHAR(255),
    -- آدرس مشتری
    RegistrationDate DATETIME DEFAULT GETDATE()
    -- تاریخ ثبت نام مشتری
);
-- جدول محصولات
CREATE TABLE Products
(
    ProductID INT PRIMARY KEY IDENTITY(1,1),
    -- شناسه یکتا برای هر محصول
    ProductName NVARCHAR(100) NOT NULL,
    -- نام محصول
    Price DECIMAL(10, 2) NOT NULL,
    -- قیمت محصول
    Stock INT NOT NULL DEFAULT 0,
    -- تعداد موجودی محصول
    Category NVARCHAR(50)
    -- دسته‌بندی محصول
);
-- جدول سفارشات
CREATE TABLE Orders
(
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    -- شناسه یکتا برای هر سفارش
    CustomerID INT NOT NULL,
    -- شناسه مشتری که سفارش داده است
    OrderDate DATETIME DEFAULT GETDATE(),
    -- تاریخ ثبت سفارش
    TotalAmount DECIMAL(10, 2),
    -- مجموع مبلغ سفارش
    Status NVARCHAR(50) DEFAULT 'Pending',
    -- وضعیت سفارش (پیش‌فرض: در انتظار)
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
    -- ارتباط با جدول مشتریان
);
-- جدول جزئیات سفارش
CREATE TABLE OrderDetails
(
    OrderDetailID INT PRIMARY KEY IDENTITY(1,1),
    -- شناسه یکتا برای هر ردیف جزئیات سفارش
    OrderID INT NOT NULL,
    -- شناسه سفارش که به آن تعلق دارد
    ProductID INT NOT NULL,
    -- شناسه محصول سفارش داده‌شده
    Quantity INT NOT NULL,
    -- تعداد محصول در سفارش
    Price DECIMAL(10, 2) NOT NULL,
    -- قیمت هر محصول در سفارش
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    -- ارتباط با جدول سفارشات
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
    -- ارتباط با جدول محصولات
);
CREATE TABLE Logs
(
    LogID INT PRIMARY KEY IDENTITY(1,1),
    TableName NVARCHAR(255) NOT NULL,
    ActionType NVARCHAR(50) NOT NULL,
    ActionDate DATETIME NOT NULL,
    ChangedData NVARCHAR(MAX) NOT NULL
);
---- CREATE VIEW OrderSummary : --------------
CREATE VIEW OrderSummary
AS
    SELECT
        o.OrderID,
        c.FullName AS CustomerName,
        p.ProductName,
        od.Quantity,
        p.Price AS ProductPrice,
        (od.Quantity * p.Price) AS TotalPrice,
        o.Status
    FROM
        Orders o
        INNER JOIN Customers c ON o.CustomerID = c.CustomerID
        INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
        INNER JOIN Products p ON od.ProductID = p.ProductID;
----------------------------------------------------------------------------------------------
----Create Stored Procedure For OrderDetalis : ---------------
CREATE PROCEDURE GetOrderDetails
    @OrderID INT
AS
BEGIN
    SELECT
        o.OrderID,
        c.FullName AS CustomerName,
        p.ProductName,
        od.Quantity,
        p.Price AS ProductPrice,
        (od.Quantity * p.Price) AS TotalPrice,
        o.Status
    FROM
        Orders o
        INNER JOIN Customers c ON o.CustomerID = c.CustomerID
        INNER JOIN OrderDetails od ON o.OrderID = od.OrderID
        INNER JOIN Products p ON od.ProductID = p.ProductID
    WHERE 
        o.OrderID = @OrderID;
END;
--------- Create Stored Procedure For InsertNewOrder : -------------------
CREATE PROCEDURE InsertNewOrder
    @CustomerID INT,
    @Status NVARCHAR(50),
    @OrderDate DATE
AS
BEGIN
    INSERT INTO Orders
        (CustomerID, Status, OrderDate)
    VALUES
        (@CustomerID, @Status, @OrderDate);
END;
-------- Create Stored Procedure For InsertOrderDetails : -----------------------------
CREATE PROCEDURE InsertOrderDetails
    @OrderID INT,
    @ProductID INT,
    @Quantity INT
AS
BEGIN
    INSERT INTO OrderDetails
        (OrderID, ProductID, Quantity)
    VALUES
        (@OrderID, @ProductID, @Quantity);
END;
---------------------------------------------------------------------------------------------------------
-------------- CREATE TRIGGER For UpdateProductInventory : --------------------
CREATE TRIGGER trg_UpdateProductInventory
ON Orders
AFTER INSERT
AS
BEGIN
    UPDATE Products
    SET Stock = Stock - (SELECT OrderID
    FROM Inserted)
    WHERE ProductID = (SELECT ProductID
    FROM Inserted);
END;
------------------ CREATE TRIGGER For LogChangesOnProducts : ---------------------
CREATE TRIGGER trg_LogChangesOnProducts
ON Products
FOR INSERT, UPDATE, DELETE
AS
BEGIN
    INSERT INTO Logs
        (TableName, ActionType, ActionDate, ChangedData)
    SELECT
        'Products',
        CASE 
            WHEN UPDATE(ProductName) THEN 'Update' 
            ELSE 'Insert' 
        END,
        GETDATE(),
        CAST(INSERTED.ProductName AS NVARCHAR(MAX))
    -- Adjust the column name if needed
    FROM INSERTED;
END;
