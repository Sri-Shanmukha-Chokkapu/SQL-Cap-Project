# Sales Data Analysis - Capstone Project

## Purpose

The primary objective of this capstone project is to delve into the sales data of Amazon and extract valuable insights to comprehend the various factors influencing the sales performance across different branches.

## Dataset Overview

The dataset comprises sales transactions from three distinct branches of Amazon located in Mandalay, Yangon, and Naypyitaw. It contains 17 columns and 1000 rows, encompassing various attributes such as invoice details, branch information, customer demographics, product details, sales metrics, and more.

### Columns Overview

| Column Name             | Description                                             | Data Type   |
|-------------------------|---------------------------------------------------------|-------------|
| invoice_id              | Invoice of the sales made                               | VARCHAR(30) |
| branch                  | Branch at which sales were made                         | VARCHAR(5)  |
| city                    | The location of the branch                              | VARCHAR(30) |
| customer_type           | The type of the customer                                | VARCHAR(30) |
| gender                  | Gender of the customer making purchase                  | VARCHAR(10) |
| product_line            | Product line of the product sold                         | VARCHAR(100)|
| unit_price              | The price of each product                               | DECIMAL(10, 2) |
| quantity                | The amount of the product sold                          | INT         |
| VAT                     | The amount of tax on the purchase                       | FLOAT(6, 4) |
| total                   | The total cost of the purchase                          | DECIMAL(10, 2) |
| date                    | The date on which the purchase was made                 | DATE        |
| time                    | The time at which the purchase was made                 | TIMESTAMP   |
| payment_method          | The total amount paid                                   | DECIMAL(10, 2) |
| cogs                    | Cost Of Goods sold                                      | DECIMAL(10, 2) |
| gross_margin_percentage | Gross margin percentage                                 | FLOAT(11, 9) |
| gross_income            | Gross Income                                            | DECIMAL(10, 2) |
| rating                  | Rating                                                  | FLOAT(2, 1) |

## Analysis Goals

### Product Analysis
- Analyze product lines to identify top-performing and underperforming categories.

### Sales Analysis
- Investigate sales trends to evaluate the effectiveness of sales strategies and suggest improvements.

### Customer Analysis
- Uncover customer segments, purchase patterns, and segment profitability.

## Approach

### Data Wrangling
- Detection and handling of NULL values.
- Database creation and table insertion.

### Feature Engineering
- Creation of new columns:
  - 'timeofday' to analyze sales patterns throughout the day.
  - 'dayname' to identify busiest days of the week for each branch.
  - 'monthname' to determine peak sales months.

### Exploratory Data Analysis (EDA)
- Addressing key business questions to extract meaningful insights from the data.

## Business Questions

1. **Geographical Analysis**
   - Count of distinct cities and corresponding branches.
   - City-wise revenue analysis.
   - Highest revenue city.

2. **Product Analysis**
   - Distinct product lines count.
   - Highest selling product line.
   - Product line revenue analysis.
   - VAT analysis for product lines.

3. **Customer Analysis**
   - Customer type analysis.
   - VAT analysis for customer types.
   - Gender distribution analysis.
   - Customer ratings analysis.

4. **Sales Analysis**
   - Payment method analysis.
   - Sales trend analysis by month.
   - COGS analysis by month.
   - Sales trend analysis by time of day and day of the week.
   - Branch analysis based on average products sold.

## Conclusion

By meticulously analyzing the provided sales data, we aim to derive actionable insights to optimize sales strategies, enhance customer experiences, and ultimately drive revenue growth for Amazon across its various branches.
