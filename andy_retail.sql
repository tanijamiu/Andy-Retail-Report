SELECT * FROM customers_clean;

SELECT * FROM employees_stagg;

SELECT * FROM stores_stagg;

SELECT * FROM sales_stagg;


-- Task 1
-- Rank top 3 product category for each region
WITH top_categories AS
(SELECT 
	region, category, 
	ROUND(SUM(sale_amount), 2) total_sale
FROM sales_stagg sa
JOIN stores_stagg st
	ON sa.store_id = st.store_id
GROUP BY region, category
),
all_top_categories AS
(
SELECT *,
RANK() OVER(PARTITION BY region ORDER BY total_sale DESC) sales_rank
FROM top_categories
)
SELECT *
FROM all_top_categories
WHERE sales_rank < 4;

-- Task 2
-- Employee performance and ranking
SELECT * FROM employees_stagg;
SELECT * FROM stores_stagg;
SELECT * FROM sales_stagg;

-- Total sales made by each employee
SELECT 
	`name`,
    ROUND(SUM(sale_amount), 2) total_sales    
FROM employees_stagg es
JOIN sales_stagg ss
	ON es.employee_id = ss.employee_id
GROUP BY `name`;

-- Qestion 1
-- Top 3 performing employees by store
WITH top_employees AS
(SELECT 
	store_name,
    `name`,
    ROUND(SUM(sale_amount), 2) total_sales
FROM employees_stagg es
JOIN 
	sales_stagg ss ON es.employee_id = ss.employee_id
JOIN
	stores_stagg st ON ss.store_id = st.store_id
GROUP BY store_name, `name`
),
all_top_employees AS
(
SELECT *,
RANK() OVER(PARTITION BY store_name ORDER BY total_sales DESC) sales_rank
FROM top_employees
)
SELECT *
FROM all_top_employees
WHERE sales_rank < 4;

-- Question 2
-- Employees responsible for the highest sales across all stores
WITH employees AS
(SELECT 
	store_name,
    `name`,
    sale_amount highest_sales
FROM employees_stagg es
JOIN 
	sales_stagg ss ON es.employee_id = ss.employee_id
JOIN
	stores_stagg st ON ss.store_id = st.store_id
),
top_employees AS
(
SELECT *,
RANK() OVER(PARTITION BY store_name ORDER BY highest_sales DESC) employee_rank
FROM employees
)
SELECT *
FROM top_employees
WHERE employee_rank = 1;

-- Task 3
SELECT * FROM employees_stagg;
SELECT * FROM stores_stagg;
SELECT * FROM sales_stagg;
SELECT * FROM customers_clean;

-- Question 1
-- Who are the top customers in terms of total purchase
SELECT *
FROM (
	SELECT 
		customer_name,
		ROUND(SUM(sale_amount), 2) total_purchase
	FROM sales_stagg ss
	JOIN customers_clean cc
		ON ss.customer_id = cc.customer_id
GROUP BY customer_name 
ORDER BY total_purchase DESC
LIMIT 5
) Top_customers;

-- Identify customers who have purchased products from multiple product categories

SELECT *
FROM (
SELECT 
    customer_name,
    category,
	COUNT(DISTINCT category) purchased_product
FROM sales_stagg ss
JOIN customers_clean cc ON ss.customer_id = cc.customer_id
GROUP BY customer_name, category
)purchased_products;

-- Question 2
SELECT 
	customer_name,
    COUNT(DISTINCT category) No_of_categories
FROM sales_stagg ss
JOIN customers_clean cc ON ss.customer_id = cc.customer_id
GROUP BY customer_name
HAVING No_of_categories > 1
ORDER BY No_of_categories DESC;

-- Task 4 Store Profitability
SELECT * FROM employees_stagg;
SELECT * FROM stores_stagg;
SELECT * FROM sales_stagg;

/* Write a query that calculates the profitability of each storeby subtracting the employees
 total salary from the total sales made in the store. Use window functionsto compare store profitability.
 */
WITH store_sales AS
(
SELECT 
	st.store_name,
    ROUND(SUM(sale_amount), 2) total_sales
FROM stores_stagg st 
JOIN sales_stagg ss
ON ss.store_id = st.store_id
GROUP BY store_name
ORDER BY store_name
),
store_salaries AS
(
SELECT 
	st.store_name,
    ROUND(SUM(salary), 2) total_salaries
FROM stores_stagg st
JOIN employees_stagg es
ON st.store_id = es.store_id
GROUP BY store_name
ORDER BY store_name
)
SELECT 
	stl.store_name,
    ROUND((total_sales - total_salaries), 2) profits
FROM store_sales sts
JOIN store_salaries stl
ON stl.store_name = sts.store_name
ORDER BY profits DESC
; 



-- Bonus Task
SELECT 
	customer_name,
    category,
    quantity,
    sale_amount,
    CASE
		WHEN sale_amount < 500 THEN 'Low'
        WHEN sale_amount BETWEEN 500 AND  2000 THEN 'Medium'
        ELSE 'High'
	END price_tag
FROM sales_stagg st
JOIN customers_clean cc
ON st.customer_id = cc.customer_id
;

