use supply_db ;
 
 /* ------------------
 
Question : Golf related products

List all products in categories related to golf. Display the Product_Id, Product_Name in the output. Sort the output in the order of product id.
Hint: You can identify a Golf category by the name of the category that contains golf.

*/

SELECT product_id,
       product_name
FROM   product_info AS PI
       LEFT JOIN category AS C
              ON PI.category_id = C.id
WHERE  name LIKE '%golf%'
ORDER  BY product_id; 

-- **********************************************************************************************************************************

/*
Question : Most sold golf products

Find the top 10 most sold products (based on sales) in categories related to golf. Display the Product_Name and Sales column in the output. Sort the output in the descending order of sales.
Hint: You can identify a Golf category by the name of the category that contains golf.

HINT:
Use orders, ordered_items, product_info, and category tables from the Supply chain dataset.
*/

Select product_name, sum(sales) as sales
from ordered_items as oi
left join product_info as pi
on oi.Item_Id = pi.Product_Id
left join category as c
on pi.Category_Id = c.Id
where c.name like'%golf%'
group by Product_Name
order by Sales desc
limit 10;

-- **********************************************************************************************************************************

/*
Question: Segment wise orders

Find the number of orders by each customer segment for orders. Sort the result from the highest to the lowest 
number of orders.The output table should have the following information:
-Customer_segment
-Orders


*/

SELECT CI.segment,
       Count(O.order_id) AS orders
FROM   orders AS O
       LEFT JOIN customer_info AS CI
              ON O.order_id = CI.id
GROUP  BY segment
ORDER  BY orders DESC; 

-- **********************************************************************************************************************************
/*
Question : Percentage of order split

Description: Find the percentage of split of orders by each customer segment for orders that took six days 
to ship (based on Real_Shipping_Days). Sort the result from the highest to the lowest percentage of split orders,
rounding off to one decimal place. The output table should have the following information:
-Customer_segment
-Percentage_order_split

HINT:
Use the orders and customer_info tables from the Supply chain dataset.

*/


with order_segment as
(Select 
ci.segment as customer_segment, count(o.order_id) as orders
from orders as o
left join  customer_info as ci
on o.Customer_Id = ci.Id
where Real_Shipping_Days = 6
group by 1
)
Select a.customer_segment, 
round(a.orders/sum(b.orders)*100,1) as Percentage_order_split
from order_segment AS a
JOIN
order_segment AS b
GROUP BY customer_segment
ORDER BY Percentage_order_split DESC;

-- **********************************************************************************************************************************
