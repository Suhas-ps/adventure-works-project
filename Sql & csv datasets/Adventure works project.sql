
#-------------------------------PROJECT BY GROUP 3----------------------------#
#----------------Adventure Works Project-------------#

Create database if not exists Adventure_Works;
use Adventure_works;
Show tables;
Select * from dimproduct;

#--------------Question-0-----------------------#
/*---------Q0. Union of Fact Internet sales and Fact internet sales new-------------*/

CREATE TABLE Unionfactsales AS
SELECT * FROM fact_internet_sales
UNION ALL
SELECT * FROM fact_internet_sales_new;
Select  * from unionfactsales;

#--------------Question-1-----------------------#
/*---------1.Lookup the productname from the Product sheet to Sales sheet.-------------*/

Select * from dimproduct;
Alter table Unionfactsales add column ProductName varchar(100);

update Unionfactsales s
 join dimProduct p on s.ProductKey = p.ProductKey
 set s.ProductName = p.EnglishProductName;
    
#--------------Question-2-----------------------#
/*---------@2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.--------*/

Select * from dimcustomer;
Select * from dimproduct;
Select * from unionfactsales;

ALTER TABLE dimcustomer 
ADD INDEX idx_customerkey (CustomerKey);

ALTER TABLE unionfactsales 
ADD INDEX idx_customerkey (CustomerKey),
ADD INDEX idx_productkey (ProductKey);

ALTER TABLE dimproduct 
ADD INDEX idx_productkey (ProductKey);

ALTER TABLE dimcustomer
ADD COLUMN CustomerFullName VARCHAR(200);

UPDATE dimcustomer
SET CustomerFullName = CONCAT_WS(' ', FirstName, MiddleName, LastName);

ALTER TABLE unionfactsales
ADD COLUMN CustomerFullName VARCHAR(200),
ADD COLUMN UnitPrice_1 DECIMAL(10,2);

UPDATE unionfactsales AS s
JOIN dimcustomer AS c ON s.CustomerKey = c.CustomerKey
SET s.CustomerFullName = c.CustomerFullName;

UPDATE unionfactsales AS s
JOIN dimproduct AS p ON s.ProductKey = p.ProductKey
SET s.UnitPrice_1 = p.`Unit Price`;


#--------------------Question-3-----------------------#
/*-----3.calcuate the following fields from the Orderdatekey field 
      ( First Create a Date Field from Orderdatekey) 

A.Year
B.Monthno 
C.Monthfullname 
D.Quarter(Q1,Q2,Q3,Q4) 
E. YearMonth ( YYYY-MMM) 
F. Weekdayno 
G.Weekdayname 
H.FinancialMOnth 
I. Financial Quarter 
-------------------------------------------------------------------*/
Select  * from unionfactsales;
Select  * from dimdate;
ALTER TABLE UnionFactSales
ADD COLUMN OrderDate_1 DATE;


UPDATE UnionFactSales
SET OrderDate_1 = STR_TO_DATE(OrderDateKey, '%Y%m%d');

ALTER TABLE UnionFactSales
ADD COLUMN Year INT,
ADD COLUMN MonthNo INT,
ADD COLUMN MonthFullName VARCHAR(20),
ADD COLUMN Quarter VARCHAR(5),
ADD COLUMN YearMonth VARCHAR(10),
ADD COLUMN WeekdayNo INT,
ADD COLUMN WeekdayName VARCHAR(20),
ADD COLUMN FinancialMonth VARCHAR(10),
ADD COLUMN FinancialQuarter VARCHAR(5);

#-------------------A.Year---------------------#

UPDATE UnionFactSales
SET Year = YEAR(OrderDate_1);

#-----------------B.Monthno ---------------------#

UPDATE UnionFactSales
SET MonthNo = MONTH(OrderDate_1);

#------------C.Monthfullname------------------#

update unionfactsales
set monthfullname = monthname(orderdate_1);

#------------D.Quarter(Q1,Q2,Q3,Q4)--------------#

update unionfactsales
set quarter = concat('Q', Quarter(orderDate_1));

#-------------E.YearMonth ( YYYY-MMM)--------------#

UPDATE UnionFactSales
SET YearMonth = DATE_FORMAT(OrderDate_1, '%Y-%b');

#------------------F.Weekdayno-----------------------#

UPDATE UnionFactSales
SET WeekdayNo = DAYOFWEEK(OrderDate_1) - 1;

#------------------G.Weekdayname---------------------#

UPDATE UnionFactSales
SET WeekdayName = DAYNAME(OrderDate_1);

#-----------------H.FinancialMOnth---------------------#

UPDATE UnionFactSales
SET FinancialMonth = CASE
    WHEN MONTH(OrderDate_1) >= 4 THEN MONTH(OrderDate_1) - 3
    ELSE MONTH(OrderDate_1) + 9
END; 

#-----------------I. Financial Quarter----------------------#

UPDATE UnionFactSales
SET FinancialQuarter = CASE
    WHEN MONTH(OrderDate_1) BETWEEN 4 AND 6 THEN 'Q1'
    WHEN MONTH(OrderDate_1) BETWEEN 7 AND 9 THEN 'Q2'
    WHEN MONTH(OrderDate_1) BETWEEN 10 AND 12 THEN 'Q3'
    ELSE 'Q4'
END;

#--------------Question-4-----------------------#
#----------4.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)-------------------#

Select  * from unionfactsales;

ALTER TABLE unionfactsales 
ADD COLUMN SalesAmount_1 DECIMAL(15,2);

UPDATE unionfactsales
SET SalesAmount_1 = (UnitPrice_1 * OrderQuantity) * (1 - DiscountAmount);

#--------------Question-5-----------------------#
#--------5.Calculate the Productioncost uning the columns(unit cost ,order quantity)-----------#

select * from dimproduct;

ALTER TABLE unionfactsales 
ADD COLUMN ProductionCost DECIMAL(15,2);

UPDATE UnionFactSales
SET ProductionCost = TotalProductCost;

 UPDATE unionfactsales
SET TotalProductCost = ProductStandardCost
WHERE TotalProductCost IS NULL;

#--------------Question-6-----------------------#
#--------------------------6.Calculate the profit--------------------------#

Select  * from unionfactsales;

ALTER TABLE unionfactsales 
ADD COLUMN Profit DECIMAL(15,2);

UPDATE unionfactsales
SET Profit = SalesAmount - ProductionCost;
#-------------------------Question-8-----------------------#
#----------8.Create table to show yearwise Sales-----#

SELECT 
    YEAR(OrderDate_1) AS Year,
    ROUND(SUM(SalesAmount), 2) AS `Sum of SalesAmount`
FROM unionfactsales
WHERE OrderDate_1 IS NOT NULL
GROUP BY YEAR(OrderDate_1)
ORDER BY Year;

#-------------------------Question-9-----------------------#
#---------------9.Create table to show Monthwise sales----------------#

SELECT 
    YEAR(OrderDate_1) AS Year,
    MONTH(OrderDate_1) AS Month,
    ROUND(SUM(SalesAmount), 2) AS TotalSales
FROM unionfactsales
WHERE OrderDate_1 IS NOT NULL
GROUP BY YEAR(OrderDate_1), MONTH(OrderDate_1)
ORDER BY Year, Month;

#-------------------------Question-10-----------------------#
#-----------------10.Create a table to show Quarterwise sales------------------------#

SELECT 
    CONCAT('Q', QUARTER(OrderDate_1)) AS Quarter,
    ROUND(SUM(SalesAmount), 2) AS TotalSales
FROM unionfactsales
WHERE OrderDate_1 IS NOT NULL
GROUP BY CONCAT('Q', QUARTER(OrderDate_1))
ORDER BY Quarter;