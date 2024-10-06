--Basic:
--1.Retrieve the total number of orders placed.
select count(*) from orders;
--2.Calculate the total revenue generated from pizza sales.
select sum(quantity*pizza_price) from 
order_details join pizzas 
on order_details.pizza_id = pizzas.pizza_id

;


--3.Identify the highest-priced pizza.
select max(pizza_price) from pizzas;



--Identify the most common pizza size ordered.
select pizza_size,count(pizza_size) 
from pizzas
group by 1
order by 2 desc;



--List the top 5 most ordered pizza types along with their quantities.
select pizzas.pizza_type,sum(order_details.quantity) from 
pizzas join order_details 
on pizzas.pizza_id = order_details.pizza_id
group by 1
limit 5
;


Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.pizza_category,sum(order_details.quantity) as total_quantity from order_details
join pizzas on order_details.pizza_id = pizzas.pizza_id
join pizza_types on pizzas.pizza_type = pizza_types.pizza_type_id
group by 1
order by 2 desc ;

select * from pizza_types;
--select * from pizzas;
select * from order_details;
--Determine the distribution of orders by hour of the day.
select extract(hour from order_time),count(distinct order_id) 
from orders
group by 1;


--Join relevant tables to find the category-wise distribution of pizzas.
select pizza_types.pizza_category,count(distinct orders.order_id) from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type
join order_details on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by 1
order by 2 desc;


--select * from order_details
--select * from pizza_types;

--Group the orders by date and calculate the average number of pizzas ordered per day.

with total_orders_per_day as(
select order_date,sum(order_details.quantity) as total_orders from 
orders join order_details on orders.order_id = order_details.order_id
group by 1
)

select order_date,round(avg(total_orders) ,2) as average_orders_per_day
from total_orders_per_day
group by 1;

--Determine the top 3 most ordered pizza types based on revenue.
select pizzas.pizza_type,sum(pizzas.pizza_price * order_details.quantity ) 
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type
join order_details on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by 1
order by 2 desc
limit 3;



Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.pizza_category,concat(round( sum(pizzas.pizza_price * order_details.quantity) /(select sum(pizzas.pizza_price * order_details.quantity)  as total_revenue from 
pizzas join order_details on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizzas.pizza_type = pizza_types.pizza_type_id ) * 100,2),'%')
from pizza_types
join pizzas on pizza_types.pizza_type_id = pizzas.pizza_type
join order_details on order_details.pizza_id = pizzas.pizza_id
join orders on orders.order_id = order_details.order_id
group by 1
order by 2 desc;






--select * from pizza_types;
--Analyze the cumulative revenue generated over time.
with cte as (
select order_date as Date, cast(sum(quantity*pizza_price) as decimal(10,2)) as Revenue
from order_details 
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date
-- order by [Revenue] desc
)
select Date, Revenue, sum(Revenue) over (order by date) as Cumulative_Sum
from cte 
group by date, Revenue

--Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select pizza_type,cast(sum(quantity*pizza_price) as decimal(10,2)) as Revenue
from order_details 
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by pizza_type
limit 3;
