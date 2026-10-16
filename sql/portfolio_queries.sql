-- Automotive Product, Inventory & Sales Analysis Using MySQL
-- Synthetic practice dataset; MySQL 8+
-- Eligible sales = Completed/Shipped orders and Fulfilled order lines
-- Q40 return rate uses all order lines irrespective of parent order status.

-- Q01: Product Count By Category
SELECT
    C.Category_ID,
    C.Category_Name,
    COUNT(P.Product_ID) AS Product_Count
FROM Categories C
LEFT JOIN Products P
    ON P.Category_ID = C.Category_ID
GROUP BY
    C.Category_ID,
    C.Category_Name
ORDER BY Product_Count DESC;
-- Q02: Product With Category And Supplier Details
SELECT 
    P.Product_Name, C.Category_Name, S.Supplier_Name, S.Country
FROM
    Products P
        LEFT JOIN
    Categories C ON C.Category_ID = P.Category_ID
        LEFT JOIN
    Suppliers S ON S.Supplier_ID = P.Supplier_ID
ORDER BY C.Category_Name , S.Supplier_Name , S.Country;
-- Q03: Total Inventory Per Product.
SELECT 
    P.Product_ID,
    P.Product_Name,
    COALESCE(SUM(I.On_Hand_Qty), 0) AS Total_On_Hand_Qty,
    COALESCE(SUM(I.Reserved_Qty), 0) AS Total_Reserved_Qty
FROM
    Products P
        LEFT JOIN
    Inventory I ON P.Product_ID = I.Product_ID
GROUP BY P.Product_ID , P.Product_Name
ORDER BY Total_on_Hand_qty DESC , P.Product_Name;
-- Q04: Top 20 Products By Fulfilled Sales Value
SELECT 
    P.Product_ID,
    P.Product_Name,
    ROUND(SUM(Quantity * Unit_Sale_Price * (1 - discount_pct)),
            2) AS Sales_Value_After_Discount
FROM
    order_lines OL
        INNER JOIN
    Products P ON P.Product_ID = OL.Product_ID
		INNER JOIN
	Orders O ON O.Order_ID=OL.Order_ID
WHERE
    O.Order_Status IN ('Completed', 'Shipped') And OL.Line_Status = 'Fulfilled'
GROUP BY P.Product_ID , P.Product_Name
ORDER BY Sales_Value_After_Discount DESC , P.Product_Name
LIMIT 20;
-- Q05: Return Rate By Category
SELECT 
    C.Category_Id,
    C.Category_Name,
    COUNT(OL.Line_Status) AS Total_Order_Lines,
    COUNT(CASE
        WHEN OL.Line_Status = 'Returned' THEN 1
    END) AS Returned_Order_Lines,
    ROUND(100 * COUNT(CASE
                WHEN OL.Line_Status = 'Returned' THEN 1
            END) / COUNT(OL.Line_Status),
            2) AS Return_Rate
FROM
    Products P
        INNER JOIN
    Categories C ON C.Category_Id = P.Category_Id
        INNER JOIN
    Order_Lines OL ON OL.Product_Id = P.Product_Id
GROUP BY C.Category_Id , C.Category_Name
ORDER BY Return_Rate DESC;
-- Q06: Supplier Ranked By Active-Product List Price Value
SELECT 
    S.Supplier_ID,
    S.Supplier_Name,
    SUM(P.List_Price) AS Combined_List_Price_Value
FROM
    Suppliers S
        INNER JOIN
    Products P ON P.Supplier_ID = S.Supplier_ID
WHERE
    P.Active_Flag = 'Y'
GROUP BY S.Supplier_ID , S.Supplier_Name
ORDER BY Combined_List_Price_Value DESC , S.Supplier_Name;
-- Q07: Products Priced Above Category Average
SELECT 
    P.Product_Name, P.Category_ID, P.List_Price
FROM
    Products P
WHERE
    P.List_Price > (SELECT 
            AVG(P2.List_Price)
        FROM
            Products P2
        WHERE
            P.Category_ID = P2.Category_ID)
ORDER BY P.Category_ID , P.List_Price DESC;
-- Q08: Monthly Revenue And Previous Month Comparision
WITH Monthlyrevenue AS (
Select DATE_FORMAT(O.Order_Date, '%Y-%m') As Sales_Month, 
SUM(OL.Quantity * OL.Unit_Sale_Price * (1 - OL.Discount_pct)) As Revenue 
From Orders O
Inner Join Order_Lines OL 
On O.Order_ID=OL.Order_ID
Where O.Order_Status IN ('Completed', 'Shipped') And OL.Line_Status = 'Fulfilled'
Group By Sales_Month)
Select Sales_Month, 
ROUND(Revenue, 2) As Revenue,
ROUND(LAG(Revenue) OVER (Order By Sales_Month), 2) As Previous_Month_Revenue
From Monthlyrevenue
Order By Sales_Month;
-- Q09: Top 3 Products By Fulfilled Sales Within Each Category
With Productsales AS (
Select P.Product_ID, P.Product_Name, P.Category_ID,
SUM(OL.Quantity * OL.Unit_Sale_Price * (1 - OL.Discount_Pct)) As Fulfilled_Sales_Value,
Dense_Rank() Over (Partition By P.Category_ID Order By SUM(OL.Quantity * OL.Unit_Sale_Price * (1 - OL.Discount_Pct)) DESC) As Sales_Rank
From Products P
Inner Join Order_Lines OL On OL.Product_ID=P.Product_ID
Inner Join Orders O On O.Order_ID=OL.Order_ID
Where O.Order_Status In ('Completed', 'Shipped') And OL.Line_Status='Fulfilled'
Group By P.Product_ID, P.Product_Name, P.Category_ID)
Select Product_ID, Product_Name, Category_ID, 
ROUND(Fulfilled_Sales_Value, 2) As Fulfilled_Sales_Value, Sales_Rank
From Productsales
Where Sales_Rank <=3
Order By Category_ID, Sales_Rank;
-- Q10: Running Total Of Monthly Fulfilled Sales
With Monthlysales AS (
Select DATE_FORMAT(O.Order_Date, '%Y-%m') As Sales_Month,
SUM(OL.Quantity * OL.Unit_Sale_Price * (1 - OL.Discount_Pct)) As Monthly_Sales_Value 
From Orders O
Inner Join Order_Lines OL On O.Order_ID=OL.Order_ID
Where O.Order_Status In ('Completed', 'Shipped') And OL.Line_Status= 'Fulfilled'
Group By Sales_Month)
Select Sales_Month, 
ROUND(Monthly_Sales_Value, 2) As Monthly_Sales_Value, 
ROUND(SUM(Monthly_Sales_Value) OVER(Order By Sales_Month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW), 2) As Running_Total_Sales
From Monthlysales
Order By Sales_Month;
-- Q11: Category Share Of Fulfilled Sales
WITH CategorySales AS (
Select C.Category_ID, C.Category_Name,
SUM(OL.Quantity * OL.Unit_Sale_Price * (1 - Discount_Pct)) As Category_Sales_Value From Products P
Inner Join Categories C On C.Category_ID=P.Category_ID
Inner Join Order_Lines OL On OL.Product_ID=P.Product_ID
Inner Join Orders O On O.Order_ID=OL.Order_ID
Where O.Order_Status IN ('Completed', 'Shipped') And OL.Line_Status = 'Fulfilled'
Group By C.Category_ID, C.Category_Name),
Overallsales AS (
Select SUM(Category_Sales_Value) As Total_Sales_Value
From CategorySales)
Select
CS.Category_ID, CS.Category_Name,
ROUND(CS.Category_Sales_Value, 2) As Category_Sales_Value,
ROUND(OS.Total_Sales_Value, 2) As Total_Sales_Value,
ROUND(CS.Category_Sales_Value / NULLIF(OS.Total_Sales_Value, 0) * 100, 2) As Sales_Share_Percentage
From Categorysales CS
Cross Join Overallsales OS
Order By Sales_Share_Percentage DESC;
-- Q12: Most Expensive Active Product Per Supplier
WITH SupplierProductRank AS (
Select S.Supplier_ID, S.Supplier_Name, P.Product_ID, P.Product_Name, P.List_Price,
ROW_NUMBER() OVER(Partition By S.Supplier_ID Order By P.List_Price DESC, P.Product_ID) As Price_Rank 
From Suppliers S
Inner Join Products P On P.Supplier_ID=S.Supplier_ID
Where P.Active_Flag = 'Y' AND P.List_Price IS NOT NULL)
Select Supplier_ID, Supplier_Name, Product_ID, Product_Name, List_Price, Price_Rank
From SupplierProductRank
Where Price_Rank = 1
Order By List_Price DESC;
