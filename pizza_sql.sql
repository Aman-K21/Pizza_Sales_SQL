create database pizzahut;

show databases;

use pizzahut;

select * from pizzas;

create table orders (
order_id int not null,
order_date date not null,
order_time time not null,
primary key (order_id));

create table orders_details (
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key (order_id));



-- Basic Questions

-- Q1. Retrieve the total number of orders placed.
SELECT 
    COUNT(order_id)
FROM
    orders;


-- Q2. Calculate the total revenue generated from pizza sales.
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS total_revenue
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id;



-- Q3. Identify the higest-priced pizza.
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizzas
        JOIN
    pizza_types ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;




-- Q4. Identify the most common pizza size ordered.
select pizzas.size, count(orders_details.order_details_id)
from pizzas join orders_details
on pizzas.pizza_id = orders_details.pizza_id
group by pizzas.size;




-- Q5. List the 5 most ordered pizza types along with their quantities.
select pizza_types.name, sum(orders_details.quantity)
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by sum(orders_details.quantity) desc
limit 5;





-- Intermediate Question

-- Q1. join the necessary tables to find the total quantity of each pizza category ordered.
select pizza_types.category, sum(orders_details.quantity)
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join pizza_types
on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by sum(orders_details.quantity) desc;




-- Q2. Determine the distribution oof orders by hour of the day.
SELECT
HOUR (order_time) AS hour, COUNT(order_id) AS order_count
FROM
orders
GROUP BY HOUR (order_time);




-- Q3.join relevant tables to find the category-wise distribution of pizzas.
select category, count(category) from pizza_types
group by category;




-- Q4. Group the orders by date and calculate the average number of pizzas ordered per day.
select round(avg(quantity),0) as avg_pizza_order_per_day from
(select sum(orders_details.quantity) as quantity, date(order_date) from orders
join orders_details 
on orders.order_id = orders_details.order_id 
group by date(order_date)) as order_quantity;




-- Q5. Determine the top 3 most ordered pizza types based on revenue.
SELECT pizza_types.name, ROUND(SUM(orders_details.quantity * pizzas.price),2) AS revenue
FROM orders_details
JOIN pizzas 
ON pizzas.pizza_id = orders_details.pizza_id
join pizza_types
on pizzas.pizza_type_id = pizza_types.pizza_type_id
group by pizza_types.name
order by revenue desc
limit 3;



-- Advanced Question

-- Q1. Calculate the percentage contribution of each pizza type to total revenue.
select pizza_types.category,
round (sum(orders_details.quantity * pizzas.price) / (SELECT
ROUND (SUM(orders_details.quantity * pizzas.price),2) AS total_sales
FROM orders_details
JOIN pizzas 
ON pizzas.pizza_id = orders_details.pizza_id) *100,2) as revenue
from pizza_types 
join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category 
order by revenue desc;



-- Q2. Analyze the cumulative revenue generated over time.
select order_date,
sum(revenue) over(order by order_date) as cum_revenue
from 
(select orders.order_date,
sum(orders_details. quantity * pizzas.price) as revenue
from orders_details join pizzas
on orders_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = orders_details.order_id
group by orders.order_date) as sales;




-- Q3. Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select name, revenue from
(select category, name, revenue,
rank() over (partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name,
sum((orders_details.quantity) * pizzas.price) as revenue
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join orders_details
on orders_details.pizza_id = pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn <= 3;