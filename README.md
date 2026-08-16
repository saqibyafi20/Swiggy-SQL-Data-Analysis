# Swiggy Sales Analysis — SQL Case Study

## 📌 Project Overview

An end-to-end SQL Server project analyzing Swiggy food delivery data.<br>

The project covers:<br>

- Data cleaning and validation<br>
- Duplicate detection and removal<br>
- Data normalization and structuring<br>
- Star Schema creation<br>
- Fact and Dimension tables<br>
- KPI development<br>
- Business analysis using SQL<br>

The project follows the requirements provided for the Swiggy Sales Analysis case study.

## 🗂️ Data Model

### Dimension Tables
- DIM_DATE<br>
- DIM_LOCATION<br>
- DIM_RESTAURANT<br>
- DIM_CATEGORY<br>
- DIM_DISH

### Fact Table
- FACT_SWIGGY_ORDERS

The Star Schema separates descriptive information into dimension tables and measurable data into the central fact table. 

## 📊 Analysis Performed

- Total Orders<br>
- Total Revenue<br>
- Average Dish Price<br>
- Average Rating<br>
- Monthly and quarterly trends<br>
- Year-wise analysis<br>
- Top cities and states<br>
- Top restaurants<br>
- Category and dish analysis<br>
- Customer spending analysis<br>
- Rating analysis 

## 🛠️ Tools Used

- Microsoft SQL Server<br>
- SQL Server Management Studio (SSMS)<br>
- SQL

## 📁 Project Structure

text<br>
Swiggy-SQL-Data-Analysis/<br>
│
├── Dataset/<br>
│   └── Swiggy_Dataset.csv<br>
│
├── SQL/<br>
│   └── Swiggy_Case_Study.sql<br>
│
├── Screenshots/<br>
│
├── Business Requirements.docx<br>
│
└── README.md
## Key SQL Concepts
Joins<br>
GROUP BY & HAVING<br>
Aggregate Functions<br>
CASE<br>
CTEs<br>
ROW_NUMBER()<br>
Window Functions<br>
Date Functions
