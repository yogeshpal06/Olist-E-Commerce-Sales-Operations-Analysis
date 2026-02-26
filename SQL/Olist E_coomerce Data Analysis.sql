CREATE TABLE olist_customers (
	customer_id VARCHAR(50) PRIMARY KEY,
	customer_unique_id VARCHAR(50),
	customer_zip_code_prefix INT,
	customer_city VARCHAR(100),
	customer_state CHAR(2)
);

CREATE TABLE olist_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

CREATE TABLE olist_order_items (
	order_id VARCHAR(50),
	order_item_id INT,
	product_id VARCHAR(50),
	seller_id VARCHAR(50),
	shipping_limit_date TIMESTAMP,
	price DECIMAL(10,2),
	freight_value DECIMAL(10,2)
);

CREATE TABLE olist_products (
	product_id VARCHAR(50) PRIMARY KEY,
	product_category_name VARCHAR(100),
	product_name_lenght INT,
	product_description_lenght INT,
	product_photos_qty INT,
	product_weight_g INT,
	product_length_cm INT,
	product_height_cm INT,
	product_width_cm INT
);

CREATE TABLE olist_category_translation (
	product_category_name VARCHAR(100),
	product_category_name_english VARCHAR(100)
);

COPY olist_customers(customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
FROM 'E:\Portfolio Project\Data Analyst Project\P4- Brazil E-Comm Data\olist_customers_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_orders(order_id,customer_id,order_status,order_purchase_timestamp,order_approved_at,order_delivered_carrier_date,order_delivered_customer_date,order_estimated_delivery_date)
FROM 'E:\Portfolio Project\Data Analyst Project\P4- Brazil E-Comm Data\olist_orders_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_order_items(order_id,order_item_id,product_id,seller_id,shipping_limit_date,price,freight_value)
FROM 'E:\Portfolio Project\Data Analyst Project\P4- Brazil E-Comm Data\olist_order_items_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_products(product_id,product_category_name,product_name_lenght,product_description_lenght,product_photos_qty,product_weight_g,product_length_cm,product_height_cm,product_width_cm)
FROM 'E:\Portfolio Project\Data Analyst Project\P4- Brazil E-Comm Data\olist_products_dataset.csv'
DELIMITER ','
CSV HEADER;

COPY olist_category_translation(product_category_name,product_category_name_english)
FROM 'E:\Portfolio Project\Data Analyst Project\P4- Brazil E-Comm Data\product_category_name_translation.csv'
DELIMITER ','
CSV HEADER;

-- Data validation to check data load is successful or not

SELECT 'Customers' AS table_name, COUNT(*) AS record_count FROM olist_customers
UNION ALL
SELECT 'Orders',COUNT(*) FROM olist_orders
UNION ALL
SELECT 'Order_Items', COUNT(*) FROM olist_order_items
UNION ALL
SELECT 'Products', COUNT(*) FROM olist_products;

-- The Relationship Check (Foreign Key Test)

SELECT COUNT(DISTINCT o.order_id)
FROM olist_orders o
LEFT JOIN olist_order_items i ON o.order_id = i.order_id
WHERE i.order_id IS NULL;

-- The Data Range Validation

SELECT
	MIN(order_purchase_timestamp) AS earlist_order,
	MAX(order_purchase_timestamp) AS latest_order
FROM olist_orders;

-- Product Translation Test

SELECT
	p.product_category_name AS portuguese_name,
	t.product_category_name_english AS english_name
FROM olist_products p
LEFT JOIN olist_category_translation t ON p.product_category_name = t.product_category_name
LIMIT 10;

-- Extrracting Value (A) Revenue By Category.

SELECT
	t.product_category_name_english AS category,
	SUM(i.price) AS total_revenue,
	COUNT(i.order_id) AS total_units_sold
FROM olist_order_items i
JOIN olist_products p ON i.product_id = p.product_id
JOIN olist_category_translation t ON p.product_category_name = t.product_category_name
GROUP BY 1
ORDER BY total_revenue DESC
LIMIT 10;

-- (B) Customer Churn Query

SELECT
	CASE WHEN order_count > 1 THEN 'Repeat Customer' ELSE 'One-Time Customer' END AS customer_type,
	COUNT(*) AS customer_count
FROM (
	SELECT customer_unique_id, COUNT(order_id) AS order_count
	FROM olist_orders o
	JOIN olist_customers c ON o.customer_id = c.customer_id
	GROUP BY customer_unique_id
) subquery
GROUP BY 1;

-- PART 1 Revenue Growth
-- Finding Monthly Revenue

WITH monthly_revenue_list AS (
	SELECT
		DATE_TRUNC('month', order_purchase_timestamp) AS month_date,
		SUM(price) AS revenue,
		COUNT(o.order_id) AS order_count
	FROM olist_orders o
	JOIN olist_order_items i ON o.order_id = i.order_id
	WHERE order_status = 'delivered'
	GROUP BY 1
)
SELECT * FROM monthly_revenue_list
ORDER BY month_date;

-- Calculate growth by comparing current month to previous

WITH monthly_revenue_list AS (
	SELECT
		DATE_TRUNC('month', order_Purchase_timestamp) AS month_date,
		SUM(price) AS revenue
	FROM olist_orders o
	JOIN olist_order_items i ON o.order_id = i.order_id
	WHERE order_status = 'delivered'
	GROUP BY 1
)
SELECT
	month_date,revenue,
	-- to see last month
	LAG(revenue) OVER (ORDER BY month_date) AS previous_month_revenue,
	-- to calculate the % change
	ROUND(
		(revenue - LAG(revenue) OVER (ORDER BY month_date)) /
		LAG(revenue) OVER (ORDER BY month_date) * 100, 2) AS growth_pct
FROM monthly_revenue_list
ORDER BY month_date;

-- encountered oddly difference in october to december month growth revenue pct

SELECT 
	DATE(order_purchase_timestamp) AS exact_date,
	COUNT(o.order_id) AS daily_orders,
	SUM(price) AS daily_revenue
FROM olist_orders o
JOIN olist_order_items i ON o.order_id = i.order_id
WHERE order_purchase_timestamp BETWEEN '2016-09-01' AND '2016-12-31'
GROUP BY 1
ORDER BY 1;

-- PART 2 Customer Loyalty & segmentation

-- Count Orders Per Customer 

WITH customer_activity AS (
	SELECT
		c.customer_unique_id,
		Count(o.order_id) AS total_orders,
		SUM(i.price) AS total_spent
	FROM olist_customers c
	JOIN olist_orders o ON c.customer_id = o.customer_id
	JOIN olist_order_items i ON o.order_id = i.order_id
	GROUP BY 1
)
SELECT * FROM customer_activity
ORDER BY total_orders DESC
LIMIT 10;

-- Categorize customer into segments

WITH customer_activity AS (
	SELECT
		c.customer_unique_id,
		COUNT(o.order_id) AS total_orders,
		SUM(i.price) AS total_spent
	FROM olist_customers c
	JOIN olist_orders o ON c.customer_id = o.customer_id
	JOIN olist_order_items i ON o.order_id = i.order_id
	GROUP BY 1
)
SELECT
	CASE
		WHEN total_orders > 1 THEN 'Repeat Buyer'
		WHEN total_orders = 1 AND total_spent > 500 THEN 'High-Value One-Timer'
		ELSE 'One-Timer'
	END AS customer_segment,
	COUNT(*) AS count_of_customers,
	ROUND(AVG(total_spent),2) AS avg_segment_spend
FROM customer_activity
GROUP BY 1;

-- Part 3 Operational Efficiency

-- Delay delivery

WITH delivery_stats AS (
	SELECT
		order_id,customer_id,order_purchase_timestamp,
		order_delivered_customer_date,order_estimated_delivery_date,
		EXTRACT(DAY FROM (order_delivered_customer_date - order_estimated_delivery_date))
		AS delay_days
	FROM olist_orders
	WHERE order_status = 'delivered'
		AND order_delivered_customer_date IS NOT NULL
)
SELECT * FROM delivery_stats
WHERE delay_days > 0
ORDER BY delay_days DESC
LIMIT 10;

-- Average Delay By State
-- findings all state shows -ve delays means order delivered early

WITH delivery_gap AS (
	SELECT
		o.order_id,c.customer_state,
		EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date))
		AS delay_days
		FROM olist_orders o
		JOIN olist_customers c ON o.customer_id = c.customer_id
		WHERE o.order_status = 'delivered'
)
SELECT
	customer_state,
	ROUND(AVG(delay_days),2) AS avg_delay_performance,
	COUNT(order_id) AS total_orders
FROM delivery_gap
GROUP BY 1
ORDER BY avg_delay_performance DESC;

-- checking delay suffered by 'high-value One-timer'

WITH customer_delays AS (
	SELECT
		c.customer_unique_id,
		AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)))
		AS avg_delay
	FROM olist_orders o
	JOIN olist_customers c ON o.customer_id = c.customer_id
	WHERE o.order_status = 'delivered'
	GROUP BY 1	
)
SELECT
	CASE
		WHEN avg_delay > 0 THEN 'Delayed'
		WHEN avg_delay = 0 THEN 'On-Time'
		WHEN avg_delay < 0 THEN 'Early'
		ELSE 'Unknown'
	END AS delivery_experience,
	COUNT(*) AS customer_count
FROM customer_delays
GROUP BY 1;


-- Late Orders Breakdown

WITH late_orders AS (
	SELECT o.order_id,c.customer_state,
		EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date))
		AS days_late
	FROM olist_orders o
	JOIN olist_customers c ON o.customer_id = c.customer_id
	WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
)
SELECT
	customer_state,
	COUNT(*) AS total_late_orders,
	ROUND(AVG(days_late),2) AS avg_days_late
FROM late_orders
GROUP BY 1
ORDER BY avg_days_late DESC;

-- Delivery Performance by Month

SELECT
	DATE_TRUNC('month', order_purchase_timestamp) AS purchase_month,
	COUNT(order_id) AS total_orders,
	--Count how many of these were late
	SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END)
	AS late_order_count,
	--calculate late percentage
	ROUND(
		(SUM(CASE WHEN order_delivered_customer_date > order_estimated_delivery_date THEN 1 ELSE 0 END)::numeric /
		COUNT(order_id) * 100),2) AS late_percentage
FROM olist_orders
WHERE order_status = 'delivered'
GROUP BY 1
ORDER BY 1;


-- Part 4 product Analytics

-- freight to price ratio

WITH product_margins AS (
SELECT 
        t.product_category_name_english AS category,
        AVG(i.price) AS avg_price,
        AVG(i.freight_value) AS avg_freight
    FROM olist_order_items i
    JOIN olist_products p ON i.product_id = p.product_id
    JOIN olist_category_translation t ON p.product_category_name = t.product_category_name
    GROUP BY 1
)
SELECT 
    category,
    ROUND(avg_price::numeric, 2) AS price,
    ROUND(avg_freight::numeric, 2) AS shipping,
    ROUND((avg_freight / avg_price * 100)::numeric, 2) AS freight_ratio_pct
FROM product_margins
WHERE avg_price > 0
ORDER BY freight_ratio_pct DESC
LIMIT 10;

-- product weight vs. delay

SELECT 
    CASE 
        WHEN p.product_weight_g < 1000 THEN 'Light (<1kg)'
        WHEN p.product_weight_g BETWEEN 1000 AND 5000 THEN 'Medium (1-5kg)'
        ELSE 'Heavy (>5kg)'
    END AS weight_class,
    COUNT(o.order_id) AS total_orders,
    ROUND(AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date)))::numeric, 2) AS avg_delay
FROM olist_orders o
JOIN olist_order_items i ON o.order_id = i.order_id
JOIN olist_products p ON i.product_id = p.product_id
WHERE o.order_status = 'delivered'
GROUP BY 1
ORDER BY avg_delay DESC;

-- the star product (high revenue + low delay)

WITH category_perf AS (
    SELECT 
        t.product_category_name_english AS category,
        SUM(i.price) AS total_revenue,
        AVG(EXTRACT(DAY FROM (o.order_delivered_customer_date - o.order_estimated_delivery_date))) AS avg_delay
    FROM olist_orders o
    JOIN olist_order_items i ON o.order_id = i.order_id
    JOIN olist_products p ON i.product_id = p.product_id
    JOIN olist_category_translation t ON p.product_category_name = t.product_category_name
    WHERE o.order_status = 'delivered'
    GROUP BY 1
)
SELECT * FROM category_perf
WHERE avg_delay <= 0 -- Arrived on time or early
ORDER BY total_revenue DESC
LIMIT 10;





















