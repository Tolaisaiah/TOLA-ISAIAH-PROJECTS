USE ECOMMERCE;
/* Q1. TOTAL SALES BY EMPLOYEE: WRITE A QUERY TO CALCULATE THE TOTAL SALES(IN DOLLARS) MADE BY EACH EMPLOYEE, 
CONSIDERING THE QUANTITY AND UNIT PRICE OF PRODUCT SOLD*/
-- SOLUTION
SELECT 
    e.EmployeeID,
    CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    SUM(od.Quantity * od.UnitPrice) AS TotalSales
FROM 
    Employees e
JOIN 
    Orders o ON e.EmployeeID = o.EmployeeID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName
ORDER BY 
    TotalSales DESC;
    
    -- Q2 Top 5 Customers by Sales:
   -- Identify the top 5 customers who have generated the most revenue. Show the customer’s name and the total amount they’ve spent.
   -- SOLUTION:
   SELECT 
    c.CustomerName,
    SUM(od.UnitPrice * od.Quantity) AS TotalSpent
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
GROUP BY 
    c.customername
ORDER BY 
    TotalSpent DESC
LIMIT 5;

-- Q3 Monthly Sales Trend:
   -- Write a query to display the total sales amount for each month in the year 1997.
   -- SOLUTION
   SELECT 
    MONTH(o.OrderDate) AS Month,
    SUM(od.UnitPrice * od.Quantity) AS TotalSales
FROM 
    Orders o
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
WHERE 
    YEAR(o.OrderDate) = 1997
GROUP BY 
    MONTH(o.OrderDate)
ORDER BY 
    Month;
    
-- Q4 Order Fulfilment Time:
   -- Calculate the average time (in days) taken to fulfil an order for each employee. 
   -- Assuming shipping takes 3 or 5 days respectively depending on if the item was ordered in 1996 or 1997.
   -- SOLUTION
   SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    AVG(
        CASE 
            WHEN YEAR(o.OrderDate) = 1996 THEN 3
            WHEN YEAR(o.OrderDate) = 1997 THEN 5
            ELSE NULL
        END
    ) AS AvgFulfilmentDays
FROM 
    Orders o
JOIN 
    Employees e ON o.EmployeeID = e.EmployeeID
WHERE 
    YEAR(o.OrderDate) IN (1996, 1997)
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName
ORDER BY 
    AvgFulfilmentDays;
    
    -- Q5 Products by Category with No Sales:
   -- List the customers operating in London and total sales for each. 
   -- SOLUTION
   SELECT 
    c.CustomerID,
    c.CUSTOMERName,
    SUM(od.UnitPrice * od.Quantity) AS TotalSales
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
WHERE 
    c.City = 'London'
GROUP BY 
    c.CustomerID, c.CUSTOMERName
ORDER BY 
    TotalSales DESC;
    
    -- Q6 Customers with Multiple Orders on the Same Date:
   -- Write a query to find customers who have placed more than one order on the same date.
   -- SOLUTION
   SELECT 
    o.CustomerID,
    c.CustomerName,
    o.OrderDate,
    COUNT(*) AS OrderCount
FROM 
    Orders o
JOIN 
    Customers c ON o.CustomerID = c.CustomerID
GROUP BY 
    o.CustomerID, o.OrderDate, c.CUSTOMERName
HAVING 
    COUNT(*) > 1
ORDER BY 
    o.OrderDate, OrderCount DESC;
    
    -- Q7 Average Discount per Product:
   -- Calculate the average discount given per product across all orders. Round to 2 decimal places.
   -- SOLUTION
   SELECT 
    p.ProductName,
    ROUND(AVG(od.Discount), 2) AS AvgDiscount
FROM 
    OrderDetails od
JOIN 
    Products p ON od.ProductID = p.ProductID
GROUP BY 
    p.ProductName
ORDER BY 
    AvgDiscount DESC;
    
    
-- Q8 . Products Ordered by Each Customer:
   -- For each customer, list the products they have ordered along with the total quantity of each product ordered.
   -- SOLUTION
   SELECT 
    c.CustomerID,
    c.CustomerName,
    p.ProductName,
    SUM(od.Quantity) AS TotalQuantityOrdered
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
GROUP BY 
    c.CustomerID, c.CUSTOMERName, p.ProductName
ORDER BY 
    c.CustomerID, TotalQuantityOrdered DESC;
    
    -- Q9 Employee Sales Ranking:
   -- Rank employees based on their total sales. Show the employeename, total sales, and their rank.
   -- SOLUTION
   SELECT 
    e.EmployeeID,
        CONCAT(e.FirstName, ' ', e.LastName) AS EmployeeName,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalSales,
    RANK() OVER (ORDER BY SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) DESC) AS SalesRank
FROM 
    Employees e
JOIN 
    Orders o ON e.EmployeeID = o.EmployeeID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
GROUP BY 
    e.EmployeeID, e.FirstName, e.LastName
ORDER BY 
    SalesRank;
    
    -- Q10 . Sales by Country and Category:
    -- Write a query to display the total sales amount for each product category, grouped by country.
    -- SOLUTION
    SELECT 
    c.Country,
    cat.CategoryName,
    ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalSales
FROM 
    Customers c
JOIN 
    Orders o ON c.CustomerID = o.CustomerID
JOIN 
    OrderDetails od ON o.OrderID = od.OrderID
JOIN 
    Products p ON od.ProductID = p.ProductID
JOIN 
    Categories cat ON p.CategoryID = cat.CategoryID
GROUP BY 
    c.Country, cat.CategoryName
ORDER BY 
    c.Country, TotalSales DESC;
    
    -- Q11 Year-over-Year Sales Growth:
    -- Calculate the percentage growth in sales from one year to the next for each product.
-- SOLUTION
WITH ProductSalesByYear AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        YEAR(o.OrderDate) AS SalesYear,
        ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalSales
    FROM 
        OrderDetails od
    JOIN 
        Orders o ON od.OrderID = o.OrderID
    JOIN 
        Products p ON od.ProductID = p.ProductID
    GROUP BY 
        p.ProductID, p.ProductName, YEAR(o.OrderDate)
),
YoYGrowth AS (
    SELECT 
        curr.ProductID,
        curr.ProductName,
        curr.SalesYear,
        curr.TotalSales,
        prev.TotalSales AS PreviousYearSales,
        ROUND(
            CASE 
                WHEN prev.TotalSales = 0 OR prev.TotalSales IS NULL THEN NULL
                ELSE ((curr.TotalSales - prev.TotalSales) / prev.TotalSales) * 100
            END, 2
        ) AS YoYGrowthPercent
    FROM 
        ProductSalesByYear curr
    LEFT JOIN 
        ProductSalesByYear prev 
        ON curr.ProductID = prev.ProductID AND curr.SalesYear = prev.SalesYear + 1
)
SELECT * FROM YoYGrowth
ORDER BY ProductID, SalesYear;

-- Q12 Order Quantity Percentile:
    -- Calculate the percentile rank of each order based on the total quantity of products in the order. 
    -- SOLUTION
    WITH OrderQuantities AS (
    SELECT 
        od.OrderID,
        SUM(od.Quantity) AS TotalQuantity
    FROM 
        OrderDetails od
    GROUP BY 
        od.OrderID
),
RankedOrders AS (
    SELECT 
        OrderID,
        TotalQuantity,
        PERCENT_RANK() OVER (ORDER BY TotalQuantity) * 100 AS PercentileRank
    FROM 
        OrderQuantities
)
SELECT 
    OrderID,
    TotalQuantity,
    ROUND(PercentileRank, 2) AS PercentileRank
FROM 
    RankedOrders
ORDER BY 
    PercentileRank DESC;
    
    -- Q13 Products Never Reordered:
    -- Identify products that have been sold but have never been reordered (ordered only once). 
    -- SOLUTION
    SELECT 
    p.ProductID,
    p.ProductName
FROM 
    Products p
JOIN 
    OrderDetails od ON p.ProductID = od.ProductID
GROUP BY 
    p.ProductID, p.ProductName
HAVING 
    COUNT(DISTINCT od.OrderID) = 1;
    
    -- Q14 Most Valuable Product by Revenue:
    -- Write a query to find the product that has generated the most revenue in each category.
    -- SOLUTION
    WITH ProductRevenue AS (
    SELECT 
        p.ProductID,
        p.ProductName,
        c.CategoryID,
        c.CategoryName,
        ROUND(SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)), 2) AS TotalRevenue
    FROM 
        OrderDetails od
    JOIN 
        Products p ON od.ProductID = p.ProductID
    JOIN 
        Categories c ON p.CategoryID = c.CategoryID
    GROUP BY 
        p.ProductID, p.ProductName, c.CategoryID, c.CategoryName
),
RankedProducts AS (
    SELECT 
        *,
        RANK() OVER (PARTITION BY CategoryID ORDER BY TotalRevenue DESC) AS RevenueRank
    FROM 
        ProductRevenue
)
SELECT 
    ProductID,
    ProductName,
    CategoryName,
    TotalRevenue
FROM 
    RankedProducts
WHERE 
    RevenueRank = 1
ORDER BY 
    CategoryName;
    
    -- Q15 Complex Order Details:
	-- Identify orders where the total price of all items exceeds $100 and contains at least one product with a discount of 5% or more.
    -- SOLUTION
    WITH OrderTotals AS (
    SELECT 
        od.OrderID,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalOrderValue,
        MAX(od.Discount) AS MaxDiscount
    FROM 
        OrderDetails od
    GROUP BY 
        od.OrderID
)
SELECT 
    o.OrderID,
    ROUND(ot.TotalOrderValue, 2) AS TotalOrderValue,
    ot.MaxDiscount
FROM 
    Orders o
JOIN 
    OrderTotals ot ON o.OrderID = ot.OrderID
WHERE 
    ot.TotalOrderValue > 100
    AND ot.MaxDiscount >= 0.05
ORDER BY 
    ot.TotalOrderValue DESC;











   



   


   


    