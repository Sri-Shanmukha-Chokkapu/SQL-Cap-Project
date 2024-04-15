								###### SQL Capstone Project - Odin School #######

-- ****** Data Wrangling ******

-- Create Database
CREATE DATABASE capstone_project; 

-- Select Database
USE capstone_project; 

-- CREATE Table 
CREATE TABLE amazon (
	invoice_id VARCHAR(30) NOT NULL,
	branch VARCHAR(5) NOT NULL,
	city VARCHAR(30) NOT NULL,
	customer_type VARCHAR(30) NOT NULL,
	gender VARCHAR(10) NOT NULL,
	product_line VARCHAR(100) NOT NULL,
	unit_price DECIMAL(10,2) NOT NULL,
	quantity INT NOT NULL,
	VAT FLOAT(6) NOT NULL,
	total DECIMAL(10,2) NOT NULL,
	date DATE NOT NULL,
	time TIME NOT NULL,
	payment_method VARCHAR(50) NOT NULL,
	cogs DECIMAL(10,2) NOT NULL,
	gross_margin_percentage FLOAT(11) NOT NULL,
	gross_income DECIMAL(10,2) NOT NULL,
	rating FLOAT(2) NOT NULL
);
-- Used Table Data Import Wizard method to import Data from "Amazon.csv" file.
-- Encoding Format UTF-8 is used to import data 

-- Read Table Rows and Columns
SELECT * FROM amazon;

-- Total 1000 Rows and 17 Cols 
-- No Null Rows and Columns 


--  ******* Feature Engineering ******

/* An ENUM is a string object with a value chosen from a list of permitted values 
that are enumerated explicitly in the column specification at table creation time */

-- 1. Add a new column named "time_of_day" to give insight of sales in the Morning, Afternoon and Evening. 

ALTER TABLE amazon 
ADD time_of_day ENUM("Morning","Afternoon","Evening") AS ( 
	CASE WHEN TIME BETWEEN '05:00:00' AND '11:59:00' THEN "Morning" 
		WHEN TIME BETWEEN '12:00:00' AND '17:00:00' THEN "Afternoon" 
        ELSE "Evening" 
	END);  
    
-- 2. Add a new column named dayname that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). 

ALTER TABLE amazon 
ADD day_name ENUM("Sun","Mon","Tue", "Wed", "Thu", "Fri","Sat") AS (
	CASE WHEN WEEKDAY(date) = 1 THEN "Mon" 
		WHEN WEEKDAY(date) = 2 THEN "Tue"
        WHEN WEEKDAY(date) = 3 THEN "Wed"
        WHEN WEEKDAY(date) = 4 THEN "Thu"
        WHEN WEEKDAY(date) = 5 THEN "Fri"
        WHEN WEEKDAY(date) = 6 THEN "Sat"
        ELSE "Sun" 
	END);
     
/* 3.Add a new column named monthname that contains the extracted months of the year on which the given transaction 
took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit. */

ALTER TABLE amazon 
ADD month_name VARCHAR(12);

UPDATE amazon
SET month_name = MONTHNAME(date);

SET SQL_SAFE_UPDATES = 0;  #It has to be set OFF to execute above query without WHERE Clause
SHOW VARIABLES LIKE "sql_safe_updates"; -- To check whether it is ON or OFF 



--  ******* Business Questions To Answer ******

-- 1.What is the count of distinct cities in the dataset? 
SELECT COUNT(DISTINCT(city)) AS No_of_cities FROM amazon; 
-- @Inference ->> There are 3 different cities Yangon, Naypyitaw, Mandalay


-- ########################################

-- 2.For each branch, what is the corresponding city? 
SELECT DISTINCT branch, city FROM amazon;
-- @Inference ->> Yangon - A, Naypyitaw - C, Mandalay - B


-- ######################################## 

-- 3.What is the count of distinct product lines in the dataset? 
SELECT COUNT(DISTINCT(product_line)) AS Product_line_count  FROM amazon; 
/* -- @Inference ->> There are 6 product lines
Health and beauty
Electronic accessories
Home and lifestyle
Sports and travel
Food and beverages
Fashion accessories */ 


-- ########################################  

-- 4.Which payment method occurs most frequently? 
SELECT payment_method, COUNT(*) AS freq_count
FROM amazon 
GROUP BY payment_method;
/* -- @Insights ->> Both Ewallet and Cash were most frequently used methods.
But top first method is Ewallet.

Ewallet - 345
Cash - 344
Credit card - 311
 */ 
 
 
 -- ########################################  

-- 5.Which product line has the highest sales(assuming sales are measured by total quantity sold)?
SELECT product_line, SUM(quantity) AS total_sold
FROM amazon 
GROUP BY product_line
ORDER BY total_sold DESC 
LIMIT 1;
-- Inference: Based on the data, the "Electronic accessories" product line emerged as the top seller, with a total of **971 units sold**.


 -- ######################################## 
 
 -- 6.How much revenue is generated each month?
SELECT month_name, SUM(total) AS total_revenue
FROM amazon 
GROUP BY month_name;
/* -- @Inference ->>
January - 116292.11
March - 109455.74
February - 97219.58
*/ 


 -- ######################################## 
 
 -- 7.In which month did the cost of goods sold reach its peak?
SELECT month_name, SUM(cogs) AS total_cogs
FROM amazon 
GROUP BY month_name;
/* -- @Inference ->> Based on the date, the highest cost of goods sold (COGS) in "January month".
January - 110754.16
March - 104243.34
February - 92589.88
*/   


 -- ######################################## 
 
 -- 8.Which product line generated the highest revenue?
SELECT product_line, SUM(total) AS total_revenue
FROM amazon
GROUP BY product_line
ORDER BY total_revenue DESC
LIMIT 1;
/* -- @Inference ->> The Food and Beverages product line generated the highest revenue at $56,144.96.
*/ 

 -- ######################################## 
 
 -- 9.In which city was the highest revenue recorded?
SELECT city, SUM(total) AS total_revenue
FROM amazon 
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 1;
/* -- @Inference ->> The highest revenue recorded city is "Naypyitaw".*/  

 -- ######################################## 
 
 -- 10.Which product line incurred the highest Value Added Tax?
SELECT product_line, sum(VAT) AS high_VAT
FROM amazon
GROUP BY product_line 
ORDER BY high_VAT DESC 
LIMIT 1;
/* -- @Inference ->> The Food and beverages product line incurred the highest Value Added Tax*/

 -- ######################################## 
 
 -- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."?
SELECT product_line,
       SUM(quantity) AS total_sold,
       CASE
           WHEN SUM(quantity) > (SELECT AVG(quantity) FROM amazon) THEN 'Good'
           ELSE 'Bad'
       END AS sales_performance
FROM amazon
GROUP BY product_line;
/* -- @Inference ->> All the product lines are above average sales, which menas "Good" in sales performance*/

-- ######################################## 
 
-- 12.Identify the branch that exceeded the average number of products sold.?
SELECT branch,
       SUM(quantity) AS total_sold
FROM amazon
GROUP BY branch 
HAVING total_sold > (SELECT AVG(quantity) FROM amazon);
/* -- @Inference ->> All the Branches are exceeded the average number of products sold*/

-- ######################################## 
 
-- 13.Which product line is most frequently associated with each gender?
-- CTE (Common Table Expression) and Window function(Rank()) used to perform query
WITH ranked_products AS (
  SELECT gender, product_line, COUNT(invoice_id) AS total_purchases,
         RANK() OVER (PARTITION BY gender ORDER BY COUNT(invoice_id) DESC) AS product_rank
  FROM amazon
  GROUP BY gender, product_line
)
SELECT gender, product_line
FROM ranked_products
WHERE product_rank = 1; #Selecting only rank 1 product lines in both female and male.
/* -- @Inference ->>
Male	Health and beauty
Female	Fashion accessories */  


-- ######################################## 

-- 14.Calculate the average rating for each product line?
SELECT product_line, ROUND(AVG(rating),1) AS avg_rating
FROM amazon
GROUP BY product_line 
ORDER BY avg_rating DESC;
/* -- @Inference ->> The Food and beverages got the best rating among other product lines.
Food and beverages	7.1 <--------
Fashion accessories	7
Health and beauty	7
Electronic accessories	6.9 
Sports and travel	6.9
Home and lifestyle	6.8 */  


-- ########################################  
  
-- 15.Count the sales occurrences for each time of day on every weekday?
SELECT day_name,time_of_day,COUNT(time_of_day) AS Sales_Count
FROM amazon
GROUP BY day_name,time_of_day 
ORDER BY Sales_Count DESC;
/* -- @Inference ->> Most sales ocuuring in Afternoon's. */

-- ########################################  
  
-- 16.Identify the customer type contributing the highest revenue.?
SELECT customer_type, SUM(total) AS total_revenue
FROM amazon
GROUP BY customer_type 
ORDER BY total_revenue DESC
LIMIT 1;
/* -- @Inference ->> Prime Membership Customers are contributing the highest revenue.
Member	164223.81
Normal	158743.62
*/ 

-- ########################################  
  
-- 17.Determine the city with the highest VAT percentage.?
SELECT city, SUM(VAT) AS high_VAT
FROM amazon 
GROUP BY city 
ORDER BY high_VAT DESC 
LIMIT 1;
/* -- @Inference ->> Naypyitaw city has the highest VAT percentage.*/  

-- ########################################  
  
-- 18.Identify the customer type with the highest VAT payments?
SELECT customer_type, SUM(VAT) AS highest_VAT
FROM amazon 
GROUP BY customer_type 
ORDER BY highest_VAT DESC 
LIMIT 1;
/* -- @Inference ->> The highest VAT payments are done by "Member" Customer Typ.*/ 


-- ########################################  
  
-- 19.What is the count of distinct customer types in the dataset??
SELECT COUNT(DISTINCT(customer_type)) AS count_cus_type
FROM amazon;
/* -- @Inference ->> Memeber and Normal are the --2-- customer types in the data set.*/ 


-- ########################################  
  
-- 20.What is the count of distinct payment methods in the dataset?
SELECT COUNT(DISTINCT(payment_method)) AS count_payment_method
FROM amazon;
/* -- @Inference ->> Cash,Ewallet and Credit Card are the --3-- payment methods in the data set.*/ 

-- ########################################  
  
-- 21.Which customer type occurs most frequently??
SELECT customer_type, COUNT(customer_type) AS freq_count
FROM amazon 
GROUP BY customer_type 
ORDER BY freq_count DESC 
LIMIT 1;
/* -- @Inference ->> Member Customer type was occured most frequently.*/ 

-- ######################################## 

-- 22.Identify the customer type with the highest purchase frequency.?
SELECT customer_type, COUNT(invoice_id) AS freq_count
FROM amazon 
GROUP BY customer_type 
ORDER BY freq_count DESC 
LIMIT 1;
/* -- @Inference ->> Member Customer type has the highest purchase frequency.*/

-- ######################################## 

-- 23.Determine the predominant gender among customers.?
SELECT gender, COUNT(gender) AS gender_count
FROM amazon 
GROUP BY gender 
ORDER BY gender_count DESC
LIMIT 1;
/* -- @Inference ->> Females are the predominant gender among customers.*/ 

-- ######################################## 

-- 24.Examine the distribution of genders within each branch.?
SELECT branch, gender, COUNT(gender) AS gender_count
FROM amazon 
GROUP BY branch, gender 
ORDER BY branch;
/* -- @Inference ->> Gender distribution was balanced among all over branches*/ 

-- ######################################## 

-- 25.Identify the time of day when customers provide the most ratings?
SELECT time_of_day, COUNT(rating) AS ratings_count
FROM amazon 
GROUP BY time_of_day
ORDER BY ratings_count DESC;
/* -- @Inference ->> Most customers were giving ratings in the afternoon, which are 454 out of 1000.
And followed by evening (355), and morning (191.)*/ 

-- ######################################## 

-- 26.Determine the time of day with the highest customer ratings for each branch.?
SELECT branch,time_of_day, COUNT(rating) AS ratings_count
FROM amazon 
GROUP BY branch,time_of_day
ORDER BY ratings_count DESC, branch ASC 
LIMIT 3;
/* -- @Inference ->> Every branch was getting the highest customer ratings in the afternoon.*/

-- ######################################## 

-- 27.Identify the day of the week with the highest average ratings.?
SELECT day_name, ROUND(AVG(rating),3) AS avg_rating
FROM amazon 
GROUP BY day_name
ORDER BY avg_rating DESC;
/* -- @Inference ->> The day with the highest average ratings was Sunday.*/ 

-- ######################################## 

-- 28.Determine the day of the week with the highest average ratings for each branch.?
WITH branch_high_rating AS (
  SELECT
    Branch,
    day_name,
    AVG(rating) AS avg_rating,
    RANK() OVER (PARTITION BY Branch ORDER BY AVG(rating) DESC) AS rank_num
  FROM amazon
  GROUP BY Branch, day_name
)
SELECT Branch, day_name, avg_rating
FROM branch_high_rating
WHERE rank_num = 1;
/* -- @Inference ->>
For Branch A On Thursday got highest avg rating
For Branch B On Sunday got highest avg rating
For Branch C On Thursday got highest avg rating*/ 


--  ****** Analysis ******
/*

I provided an analysis based on the queries and inferences from my SQL output:

### Product Analysis

1. **Distinct Product Lines**: 
   - There are six distinct product lines in the dataset, ranging from health and beauty to fashion accessories.

2. **Product Line Performance**:
   - **Top Seller**: The "Electronic accessories" product line emerged as the top seller with 971 units sold.
   - **Highest Revenue**: The "Food and beverages" product line generated the highest revenue, amounting to $56,144.96.
   - **Highest VAT**: The "Food and beverages" product line incurred the highest Value Added Tax.

3. **Average Ratings**:
   - The "Food and beverages" product line received the highest average rating of 7.1 out of 10, indicating customer satisfaction.

### Sales Analysis

1. **Revenue Generation**:
   - Revenue was highest in January, followed by March and February, indicating seasonal variations in sales.

2. **Time of Sales**:
   - Afternoon was the time of day with the most sales occurrences.

### Customer Analysis

1. **Customer Type**:
   - **Revenue Contribution**: Member customers contributed the highest revenue to the business.
   - **Purchase Frequency**: Members also had the highest purchase frequency.
   - **Most Frequent Occurrence**: Member customer type occurred most frequently among customers.
   - **Highest VAT Payments**: Members also made the highest VAT payments.

2. **Gender Distribution**:
   - Females were the predominant gender among customers.

3. **Branch Analysis**:
   - **Ratings**: All branches received their highest average ratings in the afternoon.

### Conclusion:

- The dataset provides valuable insights into product performance, sales trends, and customer behavior. 
- Electronic accessories were the top-selling product line, while food and beverages generated the highest revenue.
- Prime Membership customers were the most profitable segment, contributing significantly to revenue and VAT payments.
- Afternoon was the peak time for sales occurrences, indicating potential opportunities for targeted marketing or promotions.
- The branch analysis highlights the importance of considering branch-specific factors in business strategies, such as customer ratings and sales trends.

By analyzing these aspects, businesses can refine their strategies, focusing on product lines and 
customer segments that offer the most potential for growth and profitability. Additionally, understanding sales trends 
and customer behavior can aid in optimizing marketing efforts and enhancing overall business performance. 

*/

