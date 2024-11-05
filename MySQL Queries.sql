-- Walmart Project Queries - MySQL

SELECT * FROM walmart;

-- DROP TABLE walmart;

-- DROP TABLE walmart;

-- Count total records
SELECT COUNT(*) FROM walmart;

-- Count payment methods and number of transactions by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments
FROM walmart
GROUP BY payment_method;

-- Count distinct branches
SELECT COUNT(DISTINCT branch) FROM walmart;

-- Find the minimum quantity sold
SELECT MIN(quantity) FROM walmart;

-- Business Problem Q1: Find different payment methods, number of transactions, and quantity sold by payment method
SELECT 
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Project Question #2: Identify the highest-rated category in each branch
-- Display the branch, category, and avg rating
SELECT branch, category, avg_rating
FROM (
    SELECT 
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE rank = 1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
with cte as (
select branch, count(invoice_id) as no_of_transactions,
Dense_rank() over (partition by branch order by count(invoice_id) desc) as Rank
from walmart 
group by 1
order by 2 desc 
)
select branch,no_of_transactions from cte 
where Rank=1 

-- Q4: Calculate the total quantity of items sold per payment method
SELECT 
    payment_method,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
SELECT 
    city,
    category,
    MIN(rating) AS min_rating,
    MAX(rating) AS max_rating,
    AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q6: Calculate the total profit for each category
SELECT 
    category,
    SUM(unit_price * profit_margin) AS total_profit
FROM walmart
GROUP BY category
ORDER BY total_profit DESC;

-- Q7: Determine the most common payment method for each branch
WITH cte AS (
    SELECT 
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT branch, payment_method AS preferred_payment_method
FROM cte
WHERE rank = 1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
SELECT
    branch,
    CASE 
        WHEN HOUR(TIME(time)) < 12 THEN 'Morning'
        WHEN HOUR(TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift,
    COUNT(*) AS num_invoices
FROM walmart
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)
with revenue_2022 as (
select branch,sum(total) as total_revenue from walmart
where extract(year from to_date(date,'DD/MM/YY'))=2022 
group by 1 
),
revenue_2023 as (
select branch,sum(total) as total_revenue from walmart
where extract(year from to_date(date,'DD/MM/YY'))=2023 
group by 1 
)

select r_2022.branch,r_2022.total_revenue as last_year_revenue,r_2023.total_revenue as current_year_revenue,
(((r_2022.total_revenue - r_2023.total_revenue)/r_2022.total_revenue)*100) as revenue_decrease_ratio
from revenue_2022 as r_2022 inner join revenue_2023 as r_2023 on r_2022.branch = r_2023.branch where 
r_2022.total_revenue > r_2023.total_revenue
order by 4 desc
limit 5
