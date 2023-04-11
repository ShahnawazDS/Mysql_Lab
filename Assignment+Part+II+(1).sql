use supply_db;

/*  Question: Month-wise NIKE sales

	Description:
		Find the combined month-wise sales and quantities sold for all the Nike products. 
        The months should be formatted as ‘YYYY-MM’ (for example, ‘2019-01’ for January 2019). 
        Sort the output based on the month column (from the oldest to newest). The output should have following columns :
			-Month
			-Quantities_sold
			-Sales
		HINT:
			Use orders, ordered_items, and product_info tables from the Supply chain dataset.
*/		

SELECT Date_format(order_date, "%y-%m") AS month,
       Sum(quantity)                    AS Quantities_sold,
       Sum(sales)                       AS sales
FROM   orders AS O
       LEFT JOIN ordered_items AS OI
              ON O.order_id = OI.order_id
       LEFT JOIN product_info AS PI
              ON PI.product_id = OI.item_id
WHERE  Lower(product_name) LIKE '%nike%'
GROUP  BY month
ORDER  BY month; 

-- **********************************************************************************************************************************
/*

Question : Costliest products

Description: What are the top five costliest products in the catalogue? Provide the following information/details:
-Product_Id
-Product_Name
-Category_Name
-Department_Name
-Product_Price

Sort the result in the descending order of the Product_Price.

HINT:
Use product_info, category, and department tables from the Supply chain dataset.


*/

SELECT product_id,
       PI.product_name,
       C.name AS Category_Name,
       D.name AS Department_Name,
       PI.product_price
FROM   product_info AS PI
       LEFT JOIN category AS C
              ON PI.category_id = C.id
       LEFT JOIN department AS D
              ON PI.department_id = D.id
ORDER  BY product_price DESC
LIMIT  5;

-- **********************************************************************************************************************************

/*

Question : Cash customers

Description: Identify the top 10 most ordered items based on sales from all the ‘CASH’ type orders. 
Provide the Product Name, Sales, and Distinct Order count for these items. Sort the table in descending
 order of Order counts and for the cases where the order count is the same, sort based on sales (highest to
 lowest) within that group.
 
HINT: Use orders, ordered_items, and product_info tables from the Supply chain dataset.


*/

WITH cash_order AS
(
       SELECT *
       FROM   orders
       WHERE  type = 'cash')
SELECT    pi.product_name,
          Sum(oi.sales)               AS sales,
          Count(DISTINCT co.order_id) AS order_count
FROM      cash_order                  AS co
LEFT JOIN ordered_items               AS oi
ON        co.order_id = oi.order_id
LEFT JOIN product_info AS pi
ON        oi.item_id=pi.product_id
GROUP BY  Product_Name
ORDER BY  order_count DESC,
          sales DESC limit 10 ;

-- **********************************************************************************************************************************
/*
Question : Customers from texas

Obtain all the details from the Orders table (all columns) for customer orders in the state of Texas (TX),
whose street address contains the word ‘Plaza’ but not the word ‘Mountain’. The output should be sorted by the Order_Id.

HINT: Use orders and customer_info tables from the Supply chain dataset.

*/

SELECT *
FROM   orders AS o
       LEFT JOIN customer_info AS ci
              ON ci.id = o.customer_id
WHERE  state = 'TX'
       AND street LIKE '%Plaza%'
       AND street NOT LIKE '%Mountain%'
ORDER  BY order_id; 

-- **********************************************************************************************************************************
/*
 
Question: Home office

For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging to
“Apparel” or “Outdoors” departments. Compute the total count of such orders. The final output should contain the 
following columns:
-Order_Count

*/
SELECT Count(o.order_id) AS order_count
FROM   orders AS o
       LEFT JOIN customer_info AS ci
              ON ci.id = o.customer_id
       LEFT JOIN ordered_items AS oi
              ON o.order_id = oi.order_id
       LEFT JOIN product_info AS pi
              ON oi.item_id = pi.product_id
       LEFT JOIN department AS d
              ON pi.department_id = d.id
WHERE  segment = 'Home office'
       AND d.NAME = 'Apparel'
        OR d.NAME = 'Outdoors';

-- **********************************************************************************************************************************
/*

Question : Within state ranking
 
For all the orders of the customers belonging to “Home Office” Segment and have ordered items belonging
to “Apparel” or “Outdoors” departments. Compute the count of orders for all combinations of Order_State and Order_City. 
Rank each Order_City within each Order State based on the descending order of their order count (use dense_rank). 
The states should be ordered alphabetically, and Order_Cities within each state should be ordered based on their rank. 
If there is a clash in the city ranking, in such cases, it must be ordered alphabetically based on the city name. 
The final output should contain the following columns:
-Order_State
-Order_City
-Order_Count
-City_rank

HINT: Use orders, ordered_items, product_info, customer_info, and department tables from the Supply chain dataset.

*/

WITH home_office_orders
     AS (SELECT o.order_id,
                o.customer_id
         FROM   orders AS o
                LEFT JOIN customer_info AS ci
                       ON ci.id = o.customer_id
                LEFT JOIN ordered_items AS oi
                       ON o.order_id = oi.order_id
                LEFT JOIN product_info AS pi
                       ON oi.item_id = pi.product_id
                LEFT JOIN department AS d
                       ON pi.department_id = d.id
         WHERE  segment = 'Home office'
                AND d.NAME = 'Apparel'
                 OR d.NAME = 'Outdoors')
SELECT state                                 AS Order_State,
       city                                  AS Order_City,
       Count(ho.order_id)                    AS Order_Count,
       Dense_rank()
         OVER (
           partition BY state
           ORDER BY Count(ho.order_id) DESC) AS City_rank
FROM   home_office_orders AS ho
       LEFT JOIN customer_info AS ci
              ON ho.customer_id = ci.id
GROUP  BY order_state,
          order_city
ORDER  BY order_state,
          city_rank,
          order_city; 

-- **********************************************************************************************************************************
/*
Question : Underestimated orders

Rank (using row_number so that irrespective of the duplicates, so you obtain a unique ranking) the 
shipping mode for each year, based on the number of orders when the shipping days were underestimated 
(i.e., Scheduled_Shipping_Days < Real_Shipping_Days). The shipping mode with the highest orders that meet 
the required criteria should appear first. Consider only ‘COMPLETE’ and ‘CLOSED’ orders and those belonging to 
the customer segment: ‘Consumer’. The final output should contain the following columns:
-Shipping_Mode,
-Shipping_Underestimated_Order_Count,
-Shipping_Mode_Rank

HINT: Use orders and customer_info tables from the Supply chain dataset.


*/

-- **********************************************************************************************************************************


SELECT shipping_mode,
       Count(o.order_id)                  AS Shipping_Underestimated_Order_Count
       ,
       Row_number()
         OVER(
           partition BY Year(order_date)
           ORDER BY Count(order_id) DESC) AS Shipping_Mode_Rank
FROM   orders AS o
       LEFT JOIN customer_info AS ci
              ON ci.id = o.customer_id
WHERE  scheduled_shipping_days < real_shipping_days
       AND ( order_status = 'COMPLETE'
              OR order_status = 'CLOSED' )
       AND segment = 'consumer'
GROUP  BY shipping_mode,
          Year(order_date); 
          
/************************************************************************************************************************************************
In question 6 there should also be asked to put year column in final output.
************************************************************************************************************************************************/


