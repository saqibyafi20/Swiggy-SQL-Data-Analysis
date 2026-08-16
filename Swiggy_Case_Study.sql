SELECT * FROM swiggy_data

-- Data Cleaning and Validation
-- 1: NULL Check:

SELECT SUM(CASE WHEN State IS NULL THEN 1 ELSE 0 END) AS State_Null,
	SUM(CASE WHEN City IS NULL THEN 1 ELSE 0 END) AS City_Null,
	SUM(CASE WHEN Order_Date IS NULL THEN 1 ELSE 0 END) AS Date_Null,
	SUM(CASE WHEN Restaurant_Name IS NULL THEN 1 ELSE 0 END) AS Restuarant_Null,
	SUM(CASE WHEN Location IS NULL THEN 1 ELSE 0 END) AS Location_Null,
	SUM(CASE WHEN Category IS NULL THEN 1 ELSE 0 END) AS Category_Null,
	SUM(CASE WHEN Dish_Name IS NULL THEN 1 ELSE 0 END) AS DishName_Null,
	SUM(CASE WHEN Price_INR IS NULL THEN 1 ELSE 0 END) AS Price_INR_Null,
	SUM(CASE WHEN Rating IS NULL THEN 1 ELSE 0 END) AS Rating_Null,
	SUM(CASE WHEN Rating_Count IS NULL THEN 1 ELSE 0 END) AS RatingCount_Null
FROM swiggy_data

-- Blank or Empty Strings:

SELECT *
FROM swiggy_data
WHERE
State= '' OR City= '' OR Restaurant_Name= '' OR Location= '' OR Category= '' OR Dish_Name= ''

-- Duplicate Detection:

SELECT
State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating,
Rating_Count, COUNT(*) AS CNT
FROM 
swiggy_data
GROUP BY
State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating,
Rating_Count
HAVING COUNT(*) > 1

-- Removing Duplicates: 

WITH CTE AS(
SELECT *, ROW_NUMBER() OVER(PARTITION BY 
	State, City, Order_Date, Restaurant_Name, Location, Category, Dish_Name, Price_INR, Rating,
	Rating_Count
ORDER BY (SELECT NULL)
) AS RN 
FROM swiggy_data
)
DELETE FROM CTE WHERE RN>1

-- STAR SCHEMA
-- Creating Dimension Tables:
-- 1: Dim_Date Table

CREATE TABLE DIM_DATE(
Date_ID INT IDENTITY(1,1) PRIMARY KEY,
Full_Date DATE,
Year INT,
Month INT,
Month_Name VARCHAR(10),
Quarter INT,
Day INT,
Week INT
)

SELECT * FROM DIM_DATE

-- 2: Dim_Location Table

CREATE TABLE DIM_LOCATION(
Location_ID INT IDENTITY(1,1) PRIMARY KEY,
State VARCHAR(100),
City VARCHAR(100),
Location VARCHAR(200)
)

SELECT * FROM DIM_LOCATION

-- 3: Dim_Restaurant Table

CREATE TABLE DIM_RESTAURANT(
Restaurant_ID INT IDENTITY(1,1) PRIMARY KEY,
Restaurant_Name VARCHAR(50)
)

SELECT * FROM DIM_RESTAURANT

-- 4: Dim_Category Table

CREATE TABLE DIM_CATEGORY(
Category_ID INT IDENTITY(1,1) PRIMARY KEY,
Category VARCHAR(100)
)

SELECT * FROM DIM_CATEGORY

-- 5: Dim_Dish Table

CREATE TABLE DIM_DISH(
Dish_ID INT IDENTITY(1,1) PRIMARY KEY,
Dish_Name VARCHAR(200)
)

SELECT * FROM DIM_DISH

-- Create Fact Table:

CREATE TABLE FACT_SWIGGY_ORDERS(
Order_ID INT IDENTITY(1,1) PRIMARY KEY,
Date_ID INT,
Price_INR DECIMAL(10,2),
Rating DECIMAL(4,2),
Rating_Count INT,

Location_ID INT,
Restaurant_ID INT,
Category_ID INT,
Dish_ID INT

FOREIGN KEY (Date_ID) REFERENCES DIM_DATE(Date_ID),
FOREIGN KEY (Location_ID) REFERENCES DIM_LOCATION(Location_ID),
FOREIGN KEY (Restaurant_ID) REFERENCES DIM_RESTAURANT(Restaurant_ID),
FOREIGN KEY (Category_ID) REFERENCES DIM_CATEGORY(Category_ID),
FOREIGN KEY (Dish_ID) REFERENCES DIM_DISH(Dish_ID)
)

SELECT * FROM FACT_SWIGGY_ORDERS

-- Insert Data Into Tables : 
-- DIM_DATE

INSERT INTO DIM_DATE (Full_Date, Year, Month, Month_Name, Quarter, Day, Week)
SELECT DISTINCT
	Order_Date,
	YEAR(Order_Date),
	MONTH(Order_Date),
	DATENAME(MONTH,Order_Date),
	DATEPART(QUARTER,Order_Date),
	DAY(Order_date),
	DATEPART(WEEK,Order_Date)
FROM swiggy_data
WHERE Order_Date IS NOT NULL 

-- Dim_Locaiton

INSERT INTO DIM_LOCATION (State, City, Location)
SELECT DISTINCT
	State,
	City,
	Location
FROM swiggy_data

-- Dim_Restaurant

INSERT INTO DIM_RESTAURANT(Restaurant_Name)
SELECT DISTINCT
	Restaurant_Name
FROM swiggy_data

-- Dim_Category

INSERT INTO DIM_CATEGORY(Category)
SELECT DISTINCT
	Category
FROM swiggy_data


-- Dim_Dish

INSERT INTO DIM_DISH(Dish_Name)
SELECT DISTINCT
	Dish_Name
FROM swiggy_data

-- Fact Table 

INSERT INTO FACT_SWIGGY_ORDERS(
	Date_ID,
	Price_INR,
	Rating,
	Rating_COUNT,

	Location_ID,
	Restaurant_ID,
	Category_ID,
	Dish_ID
	)
SELECT 
	dd.Date_ID,
	s.Price_INR,
	s.Rating,
	s.Rating_Count,
	dl.Location_ID,
	dr.Restaurant_ID,
	dc.Category_ID,
	dsh.Dish_ID
FROM 
swiggy_data s

JOIN DIM_DATE dd
ON dd.Full_Date = s.Order_Date

JOIN DIM_LOCATION dl
ON dl.State = s.State
AND dl.City = s.City
AND dl.Location = s.Location

JOIN DIM_RESTAURANT dr
ON dr.Restaurant_Name = s.Restaurant_Name

JOIN DIM_CATEGORY dc
ON dc.Category = s.Category

JOIN DIM_DISH dsh
ON dsh.Dish_Name = s.Dish_Name

SELECT * FROM FACT_SWIGGY_ORDERS

-- Join The Tables 

SELECT *  FROM FACT_SWIGGY_ORDERS f
JOIN DIM_DATE d ON d.Date_ID = f.Date_ID
JOIN DIM_LOCATION l ON l.Location_ID = f.Location_ID
JOIN DIM_RESTAURANT r ON r.Restaurant_ID = f.Restaurant_ID
JOIN DIM_CATEGORY c ON c.Category_ID = f.Category_ID
JOIN DIM_DISH ds ON ds.Dish_ID = f.Dish_ID

-- -- -- -- KPI's -- -- -- -- 

SELECT * FROM FACT_SWIGGY_ORDERS

-- 1: Total Orders :

SELECT COUNT(*) AS Total_oreders
FROM FACT_SWIGGY_ORDERS

-- 2: Total Revenue(INR Million) :

SELECT 
FORMAT(SUM(CONVERT(FLOAT,Price_INR))/1000000 ,'N2') + ' ' + 'INR Million'
AS Total_Revenue
FROM FACT_SWIGGY_ORDERS

-- 3: Average Dish Price

SELECT 
FORMAT(AVG(CONVERT(Float,Price_INR)) ,'N2') + ' ' + 'INR'
AS Average_Price_Dish
FROM FACT_SWIGGY_ORDERS

-- 4: Average Rating :

SELECT 
FORMAT(AVG(CONVERT(Float,Rating)) ,'N2') + ' ' + 'INR'
AS Average_Rating
FROM FACT_SWIGGY_ORDERS


-- Deep-Dive Business Analysis :
-- Date Based Analysis
-- 1: Monthly Order Trends 

SELECT
d.Month,
d.Month_Name,
COUNT(*) AS Monthly_Total_Orders
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_DATE d ON d.Date_ID = f.Date_ID
GROUP BY 
d.Month,
d.Month_Name 
ORDER BY COUNT(*) DESC

-- 2: Quarterly Order Trends

SELECT
d.Year,
d.Quarter,
COUNT(*) AS Quarterly_Total_Orders
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_DATE d ON d.Date_ID = f.Date_ID
GROUP BY 
d.Year,
d.Quarter
ORDER BY COUNT(*) DESC

-- 3: Yearly Order Trends

SELECT 
d.Year,
COUNT (*) AS Yearly_Total_Orders
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_DATE d ON d.Date_ID = f.Date_ID
GROUP BY d.Year
ORDER BY COUNT (*) DESC

-- 4: Orders By Day Of Week (Mon-Sun)

Select
DATENAME(WEEKDAY, d.Full_Date) AS Day_Name,
COUNT(*) AS Day_Based_Orders_Trends
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_DATE d ON d.Date_ID = f.Date_ID
GROUP BY 
DATENAME(WEEKDAY, d.Full_Date) , DATEPART(WEEKDAY, d.Full_Date)


-- Location Based Analysis
-- Top 10 Cities By Order Volume

SELECT TOP 10 
l.City,
COUNT(*) AS Top_10_Cities
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_LOCATION l ON l.Location_ID = f.Location_ID
GROUP BY 
l.City
ORDER BY COUNT(*) DESC


-- Revenue Contribution By States

SELECT 
l.State,
SUM(Price_INR) AS State_Revenue_Contribution
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_LOCATION l ON l.Location_ID = f.Location_ID
GROUP BY 
l.State
ORDER BY SUM(Price_INR) DESC

-- Top 10 Restaurants By Orders

SELECT TOP 10
r.Restaurant_Name,
COUNT(*) AS Top_10_Restaurant
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_RESTAURANT r ON r.Restaurant_ID = f.Restaurant_ID
GROUP BY 
r.Restaurant_Name
ORDER BY COUNT(*) DESC

-- Top categories By Order Volume

SELECT 
c.Category,
COUNT(*) AS Top_10_Category
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_CATEGORY c ON c.Category_ID = f.Category_ID
GROUP BY 
c.Category
ORDER BY COUNT(*) DESC


-- Most Ordered Dish

SELECT 
ds.Dish_Name,
COUNT(*) AS Most_Ordered_Dish
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_DISH ds ON ds.Dish_ID = f.Dish_ID
GROUP BY 
ds.Dish_Name
ORDER BY COUNT(*) DESC


-- Cuisine Performance (Orders + Avg Rating)

SELECT
c.Category,
COUNT(*) AS Total_Orders,
AVG(Rating) AS Average_Rating
FROM FACT_SWIGGY_ORDERS f
JOIN DIM_CATEGORY c ON c.Category_ID = f.Category_ID
GROUP BY c.Category 
ORDER BY COUNT(*), AVG(Rating) DESC


-- Customer Spending Insights 

SELECT
	CASE
		WHEN (Price_INR) < 100 THEN 'Under 100'
		WHEN (Price_INR) BETWEEN 100 AND 199 THEN '100-199'
		WHEN (Price_INR) BETWEEN 200 AND 299 THEN '200-299'
		WHEN (Price_INR) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END AS Price_Range,
	COUNT(*) AS Total_Orders
FROM FACT_SWIGGY_ORDERS
GROUP BY 
CASE
		WHEN (Price_INR) < 100 THEN 'Under 100'
		WHEN (Price_INR) BETWEEN 100 AND 199 THEN '100-199'
		WHEN (Price_INR) BETWEEN 200 AND 299 THEN '200-299'
		WHEN (Price_INR) BETWEEN 300 AND 499 THEN '300-499'
		ELSE '500+'
	END
ORDER BY Total_Orders DESC


-- Rating-Count Distribution (1-5)

SELECT
Rating,
COUNT(*) AS Rating_Count
FROM FACT_SWIGGY_ORDERS
GROUP BY Rating
ORDER BY COUNT(*) DESC













