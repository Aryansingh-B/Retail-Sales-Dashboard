USE retail_db;

-- ─────────────────────────────────────────────────────────────────
-- Q1  Total Revenue, Profit, Orders, and AOV (KPI Cards)
-- ─────────────────────────────────────────────────────────────────
SELECT
    COUNT(DISTINCT order_id)        AS total_orders,
    ROUND(SUM(revenue), 2)          AS total_revenue,
    ROUND(SUM(profit), 2)           AS total_profit,
    ROUND(AVG(revenue), 2)          AS avg_order_value,
    ROUND(SUM(profit)/SUM(revenue)*100, 2) AS profit_margin_pct
FROM vw_sales_fact;


-- ─────────────────────────────────────────────────────────────────
-- Q2  Monthly Revenue Trend (Line Chart)
-- ─────────────────────────────────────────────────────────────────
SELECT
    order_year,
    order_month,
    month_name,
    ROUND(SUM(revenue), 2) AS monthly_revenue,
    ROUND(SUM(profit), 2)  AS monthly_profit,
    COUNT(DISTINCT order_id) AS order_count
FROM vw_sales_fact
GROUP BY order_year, order_month, month_name
ORDER BY order_year, order_month;


-- ─────────────────────────────────────────────────────────────────
-- Q3  Revenue by Category  (Bar / Donut Chart)
-- ─────────────────────────────────────────────────────────────────
SELECT
    category_name,
    ROUND(SUM(revenue), 2)                                      AS category_revenue,
    ROUND(SUM(revenue) / (SELECT SUM(revenue) FROM vw_sales_fact) * 100, 2) AS revenue_pct
FROM vw_sales_fact
GROUP BY category_name
ORDER BY category_revenue DESC;


-- ─────────────────────────────────────────────────────────────────
-- Q4  Top 10 Best-Selling Products by Revenue
-- ─────────────────────────────────────────────────────────────────
SELECT
    product_name,
    category_name,
    SUM(quantity)          AS units_sold,
    ROUND(SUM(revenue), 2) AS total_revenue,
    ROUND(SUM(profit), 2)  AS total_profit
FROM vw_sales_fact
GROUP BY product_name, category_name
ORDER BY total_revenue DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────────
-- Q5  Region-wise Revenue  (Map / Bar Chart)
-- ─────────────────────────────────────────────────────────────────
SELECT
    region,
    COUNT(DISTINCT customer_id)  AS customers,
    COUNT(DISTINCT order_id)     AS orders,
    ROUND(SUM(revenue), 2)       AS revenue,
    ROUND(SUM(profit), 2)        AS profit
FROM vw_sales_fact
GROUP BY region
ORDER BY revenue DESC;


-- ─────────────────────────────────────────────────────────────────
-- Q6  State-wise Revenue (Drill-through)
-- ─────────────────────────────────────────────────────────────────
SELECT
    region,
    state,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2)  AS profit,
    COUNT(DISTINCT order_id) AS orders
FROM vw_sales_fact
GROUP BY region, state
ORDER BY revenue DESC;


-- ─────────────────────────────────────────────────────────────────
-- Q7  Year-over-Year Revenue Growth
-- ─────────────────────────────────────────────────────────────────
SELECT
    order_year,
    ROUND(SUM(revenue), 2) AS annual_revenue,
    ROUND(SUM(profit), 2)  AS annual_profit,
    ROUND(
        (SUM(revenue) - LAG(SUM(revenue)) OVER (ORDER BY order_year)) /
        LAG(SUM(revenue)) OVER (ORDER BY order_year) * 100, 2
    ) AS yoy_growth_pct
FROM vw_sales_fact
GROUP BY order_year
ORDER BY order_year;


-- ─────────────────────────────────────────────────────────────────
-- Q8  Top 10 Customers by Revenue (High-Value Customers)
-- ─────────────────────────────────────────────────────────────────
SELECT
    customer_id,
    customer_name,
    region,
    COUNT(DISTINCT order_id)  AS total_orders,
    ROUND(SUM(revenue), 2)    AS lifetime_value,
    ROUND(AVG(revenue), 2)    AS avg_order_value
FROM vw_sales_fact
GROUP BY customer_id, customer_name, region
ORDER BY lifetime_value DESC
LIMIT 10;


-- ─────────────────────────────────────────────────────────────────
-- Q9  Ship Mode Preference & Average Shipping Time
-- ─────────────────────────────────────────────────────────────────
SELECT
    o.ship_mode,
    COUNT(o.order_id)                              AS total_orders,
    ROUND(AVG(DATEDIFF(o.ship_date, o.order_date)), 1) AS avg_ship_days,
    ROUND(SUM(s.revenue), 2)                       AS revenue
FROM orders o
JOIN vw_sales_fact s ON o.order_id = s.order_id
GROUP BY o.ship_mode
ORDER BY total_orders DESC;


-- ─────────────────────────────────────────────────────────────────
-- Q10  Payment Mode Distribution
-- ─────────────────────────────────────────────────────────────────
SELECT
    payment_mode,
    COUNT(DISTINCT order_id)           AS orders,
    ROUND(SUM(revenue), 2)             AS revenue,
    ROUND(COUNT(DISTINCT order_id) /
        (SELECT COUNT(*) FROM orders) * 100, 2) AS pct_orders
FROM vw_sales_fact
GROUP BY payment_mode
ORDER BY orders DESC;


-- ─────────────────────────────────────────────────────────────────
-- Q11  Quarterly Revenue Breakdown
-- ─────────────────────────────────────────────────────────────────
SELECT
    order_year,
    CONCAT('Q', quarter) AS quarter_label,
    ROUND(SUM(revenue), 2)         AS revenue,
    ROUND(SUM(profit), 2)          AS profit,
    COUNT(DISTINCT order_id)       AS orders
FROM vw_sales_fact
GROUP BY order_year, quarter
ORDER BY order_year, quarter;


-- ─────────────────────────────────────────────────────────────────
-- Q12  Return Rate by Category
-- ─────────────────────────────────────────────────────────────────
SELECT
    cat.category_name,
    COUNT(DISTINCT r.return_id)   AS total_returns,
    COUNT(DISTINCT oi.item_id)    AS total_items_sold,
    ROUND(COUNT(DISTINCT r.return_id) /
          COUNT(DISTINCT oi.item_id) * 100, 2) AS return_rate_pct
FROM order_items oi
JOIN products p   ON oi.product_id  = p.product_id
JOIN categories cat ON p.category_id = cat.category_id
LEFT JOIN returns r ON oi.order_id = r.order_id
                    AND oi.product_id = r.product_id
GROUP BY cat.category_name
ORDER BY return_rate_pct DESC;


-- ─────────────────────────────────────────────────────────────────
-- Q13  Most Common Return Reasons
-- ─────────────────────────────────────────────────────────────────
SELECT
    reason,
    COUNT(*) AS return_count,
    ROUND(COUNT(*) / (SELECT COUNT(*) FROM returns) * 100, 2) AS pct
FROM returns
GROUP BY reason
ORDER BY return_count DESC;


-- ─────────────────────────────────────────────────────────────────
-- Q14  Products with Highest Profit Margin
-- ─────────────────────────────────────────────────────────────────
SELECT
    product_name,
    category_name,
    ROUND(SUM(revenue), 2)  AS revenue,
    ROUND(SUM(profit), 2)   AS profit,
    ROUND(SUM(profit) / SUM(revenue) * 100, 2) AS margin_pct
FROM vw_sales_fact
GROUP BY product_name, category_name
HAVING SUM(revenue) > 1000     -- filter noise
ORDER BY margin_pct DESC
LIMIT 15;


-- ─────────────────────────────────────────────────────────────────
-- Q15  Customer Segmentation: New vs Returning
-- ─────────────────────────────────────────────────────────────────
SELECT
    CASE WHEN order_count = 1 THEN 'New Customer'
         WHEN order_count BETWEEN 2 AND 4 THEN 'Occasional'
         ELSE 'Loyal Customer' END AS segment,
    COUNT(*)                       AS customer_count,
    ROUND(AVG(total_revenue), 2)   AS avg_revenue
FROM (
    SELECT
        customer_id,
        COUNT(DISTINCT order_id)  AS order_count,
        SUM(revenue)              AS total_revenue
    FROM vw_sales_fact
    GROUP BY customer_id
) sub
GROUP BY segment;


-- ─────────────────────────────────────────────────────────────────
-- Q16  Revenue by Discount Tier
-- ─────────────────────────────────────────────────────────────────
SELECT
    CASE
        WHEN discount = 0           THEN 'No Discount'
        WHEN discount <= 0.10       THEN 'Low (1-10%)'
        WHEN discount <= 0.20       THEN 'Medium (11-20%)'
        ELSE 'High (>20%)'
    END AS discount_tier,
    COUNT(*)               AS line_items,
    ROUND(SUM(revenue), 2) AS revenue,
    ROUND(SUM(profit), 2)  AS profit
FROM vw_sales_fact
GROUP BY discount_tier
ORDER BY revenue DESC;


-- ─────────────────────────────────────────────────────────────────
-- Q17  Heatmap: Day of Week × Revenue
-- ─────────────────────────────────────────────────────────────────
SELECT
    DAYNAME(order_date)  AS day_of_week,
    DAYOFWEEK(order_date) AS day_num,
    ROUND(SUM(revenue), 2) AS revenue,
    COUNT(DISTINCT order_id) AS orders
FROM vw_sales_fact
GROUP BY day_of_week, day_num
ORDER BY day_num;
