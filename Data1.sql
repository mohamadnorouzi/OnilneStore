----------Insert Into Tables : ----------------------------------------------------------
INSERT INTO Customers
    (FullName, Email, Phone, Address)
VALUES
    ('John Doe', 'johndoe@example.com', '1234567890', '123 Main Street, Tehran, Iran');
INSERT INTO Customers
    (FullName, Email, Phone, Address)
VALUES
    ('Jane Smith', 'janesmith@example.com', '0987654321', '456 Elm Street, Mashhad, Iran');

INSERT INTO Products
    (ProductName, Price, Stock, Category)
VALUES
    ('LED TV', 500.00, 10, 'Electronics');
INSERT INTO Products
    (ProductName, Price, Stock, Category)
VALUES
    ('Side-by-Side Refrigerator', 1200.00, 5, 'Electronics');
INSERT INTO Products
    (ProductName, Price, Stock, Category)
VALUES
    ('Smartphone', 800.00, 15, 'Electronics');

INSERT INTO Orders
    (CustomerID, TotalAmount, Status)
VALUES
    (1, 1000.00, 'Completed');
INSERT INTO Orders
    (CustomerID, TotalAmount, Status)
VALUES
    (2, 500.00, 'Pending');

INSERT INTO OrderDetails
    (OrderID, ProductID, Quantity, Price)
VALUES
    (1, 1, 1, 500.00);
-- Order 1, Product 1, Quantity 1
INSERT INTO OrderDetails
    (OrderID, ProductID, Quantity, Price)
VALUES
    (1, 3, 2, 1600.00);
-- Order 1, Product 3, Quantity 2
----------- Create Indexes : ----------------------
CREATE INDEX idx_OrderDate_ProductID 
ON Orders (OrderDate, TotalAmount);

CREATE INDEX idx_ProductName_Stock 
ON Products (ProductName, Stock);

CREATE INDEX idx_ActionDate_ActionType 
ON Logs (ActionDate, ActionType);
----------------------------------------------------------------------------------