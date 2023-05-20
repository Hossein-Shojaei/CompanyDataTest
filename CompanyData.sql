-- ايجاد جدول SaleTable
CREATE TABLE SaleTable (
    SalesID INT,
    OrderID INT,
    Customer VARCHAR(100),
    Product VARCHAR(100),
    SaleDate DATE,
    Quantity INT,
    UnitPrice DECIMAL(10, 2)
)

-- وارد کردن داده‌ها به جدول SaleTable
/* INSERT INTO SaleTable (SalesID, OrderID, Customer, Product, SaleDate, Quantity, UnitPrice)
VALUES (1, 1, 'C1', 'P1', '1', 2, 100)

INSERT INTO SaleTable (SalesID, OrderID, Customer, Product, SaleDate, Quantity, UnitPrice)
VALUES (2, 1, 'C1', 'P2', '1', 4, 150) */

-- وارد کردن ساير رکورد‌ها

--------------------------------------------------------------------------------------------------------------------------------------------------------------

-- ايجاد جدول SaleProfit
CREATE TABLE SaleProfit (
    Product VARCHAR(100),
    ProfitRatio DECIMAL(4, 2)
)
-- وارد کردن داده‌ها به جدول SaleProfit
/* INSERT INTO SaleProfit (Product, ProfitRatio)
VALUES ('P1', 0.05)

INSERT INTO SaleProfit (Product, ProfitRatio)
VALUES ('P2', 0.25)

INSERT INTO SaleProfit (Product, ProfitRatio)
VALUES ('P3', 0.10)

INSERT INTO SaleProfit (Product, ProfitRatio)
VALUES ('P4', 0.20)

INSERT INTO SaleProfit (Product, ProfitRatio)
VALUES ('P5', 0.10) */


--------------------------------------------------------------------------------------------------------------------------------------------------------------


-- ايجاد جدول OrganizationChart
CREATE TABLE OrganizationChart (
    Id INT,
    Name VARCHAR(100),
    Manager VARCHAR(100),
    ManagerId INT
)
-- وارد کردن داده‌ها به جدول OrganizationChart
/* INSERT INTO OrganizationChart (Id, Name, Manager, ManagerId)
VALUES (1, 'Ken', NULL, NULL)

INSERT INTO OrganizationChart (Id, Name, Manager, ManagerId)
VALUES (2, 'Hugo', NULL, NULL)

INSERT INTO OrganizationChart (Id, Name, Manager, ManagerId)
VALUES (3, 'James', 'Carol', 5) */

-- وارد کردن ساير رکورد‌ها


--------------------------------------------------------------------------------------------------------------------------------------------------------------


--- کل فروش شرکت
SELECT SUM(SaleAmount) AS TotalSales
FROM SaleTable
---تعداد متمايز مشترياني که از اين شرکت خريد داشته اند، چند تاست؟
SELECT COUNT(DISTINCT Customer) AS UniqueCustomers
FROM SaleTable

--------------------------------------------------------------------------------------------------------------------------------------------------------------

---اين شرکت از هر محصول چه مقدار فروخته است؟
SELECT Product, SUM(Quantity) AS TotalSales
FROM SaleTable
GROUP BY Product

--------------------------------------------------------------------------------------------------------------------------------------------------------------


---يک کوئري بنويسيد که در آن مشترياني نمايش داده شوند که حداقل يک فاکتور بيش از مبلغ 1500 دارند و به ازاي هر کدام از اين مشتريان، مبلغ خريد، تعداد فاکتور و تعداد آيتم خريداري شده نمايش داده شود.
SELECT Customer, SUM(SaleAmount) AS TotalAmount, COUNT(DISTINCT OrderID) AS TotalOrders, SUM(Quantity) AS TotalItems
FROM SaleTable
GROUP BY Customer
HAVING MIN(SaleAmount) > 1500

--------------------------------------------------------------------------------------------------------------------------------------------------------------


---مبلغ سود و درصد سود حاصل از فروش کل را محاسبه نماييد.
-- محاسبه مجموع مبلغ فروش کل
DECLARE @TotalSales DECIMAL(10,2)
SELECT @TotalSales = SUM(SaleAmount) FROM SaleTable

----------------------------------------------------------------------------

---محاسبه مجموع مقدار سود
DECLARE @TotalProfit DECIMAL(10,2)
SELECT @TotalProfit = SUM(Profit) FROM SaleProfit


----------------------------------------------------------------------------

-- محاسبه درصد سود
DECLARE @ProfitPercentage DECIMAL(5,2)
SET @ProfitPercentage = (@TotalProfit / @TotalSales) * 100

----------------------------------------------------------------------------

--نمايش مبلغ سود و درصد سود
SELECT @TotalProfit AS TotalProfit, @ProfitPercentage AS ProfitPercentage

--------------------------------------------------------------------------------------------------------------------------------------------------------------

---با فرض اينکه خريدهاي هر مشتري در هر روز فقط 1 بار شمرده شود، در مجموع چند مشتري از شرکت خريد داشته اند
SELECT COUNT(*) AS TotalCustomers
FROM (
    SELECT Customer
    FROM SaleTable
    GROUP BY Customer, Date
) AS Customers


--------------------------------------------------------------------------------------------------------------------------------------------------------------


---با استفاده از کوئري، در کنار نام هر کارشناس، لول آن کارشناس در چارت سازماني و بالاترين مدير مربوط به آن کارشناس در چارت سازماني را با استفاده از کوئري ثبت کنيد
--*  بالاترين مديران سازمان لول 1، زيردستان آنها لول 2 و به همين ترتيب تا پايين ترين لايه چارت ادامه مي يابد
--* بالاترين مديران سازمان کساني هستند که مدير بالادستي ندارند و در فيلد Manager عبارت Null درج شده است

WITH RecursiveChart AS (
    SELECT Id, name, Manager, ManagerId, 1 AS Level
    FROM ChartTable
    WHERE Manager IS NULL

    UNION ALL

    SELECT C.Id, C.name, C.Manager, C.ManagerId, RC.Level + 1
    FROM ChartTable C
    INNER JOIN RecursiveChart RC ON C.ManagerId = RC.Id
)
SELECT RC.name AS Employee, RC.Level AS Level, M.name AS Manager, M.Level AS ManagerLevel
FROM RecursiveChart RC
LEFT JOIN RecursiveChart M ON RC.ManagerId = M.Id
ORDER BY RC.Level

