# Olist-Project-3
[Portfolio](https://justindrivera.carrd.co) project utilizing the Olist dataset from Kaggle

Olist E-Commerce Performance Dashboard
## Overview
This project analyzes real e-commerce transaction data from Olist, a Brazilian marketplace, to deliver insights on order volume, delivery performance, customer loyalty, and product-level revenue.

The goal was to simulate a real-world business intelligence scenario by transforming raw CSVs into a cleaned SQL model, then visualizing actionable insights in Power BI.

### Key Features
- Executive summary with interactive KPIs and page navigation

- Customer segmentation by repeat behavior and review score

- Delivery performance tracking and late shipment analysis

- Product-level revenue and satisfaction matrix

- Clean, minimalist Power BI design with custom theming

### Tools Used
- MySQL Workbench – Data cleaning, joins, and transformation

- Power BI – Visualization, DAX measures, dashboard interactivity

- DAX – Custom KPIs like % Repeat Customers and Avg Review Score

- Excel – Preliminary data wrangling and identifier cleanup

### Process Summary
- Imported raw Olist CSVs into MySQL, cleaned nulls, casted dates, and joined tables

- Created a master view (vw_full_orders) and exported clean data to CSV

- Loaded the CSV into Power BI, defined the star schema model

- Developed a centralized Measures Table for calculated KPIs

- Built report pages (Executive Summary, Orders, Delivery, Customers, Products)

- Applied styling, slicers, and navigation for a clean UX

- Published screenshots and prepared content for portfolio visibility

### Key Takeaways
- 93.61% of deliveries were on time

- Only 12.51% of customers were repeat buyers — retention is a key growth area

- Review scores were highest between May and September

- São Paulo had the highest concentration of order activity

- Average revenue per order was ~$120
