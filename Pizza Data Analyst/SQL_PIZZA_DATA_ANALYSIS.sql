/*
Note: Steps to Follow for SQL Projects with CSV Data

1. Create a Database:
   - Open your MySQL client or MySQL Workbench.
   - Execute the following SQL statement to create a new database:
     CREATE DATABASE database_name;

2. Create Tables:
   - For each CSV file, create a corresponding table in the database.
   - Define the table structure by specifying the column names and data types based on the CSV file's headers and data.
   - Example SQL statement to create a table:
     CREATE TABLE table_name (
       column1 DATA_TYPE,
       column2 DATA_TYPE,
       ...
     );

3. Import CSV Data into Tables:
   There are two methods to import CSV data into the created tables:

   Method 1: Using the Table Data Import Wizard (MySQL Workbench)
     - Right-click on the table in the MySQL Workbench interface.
     - Select "Table Data Import Wizard."
     - Follow the prompts to select the CSV file and configure the import settings.
     - Review the import preview and execute the import.

   Method 2: Using SQL Statements
     - Enable local file loading in MySQL by executing the following statement:
       SET GLOBAL local_infile = 1;
     - Use the LOAD DATA INFILE statement to import the CSV data into the table:
       LOAD DATA INFILE 'path/to/csv_file.csv'
       INTO TABLE table_name
       FIELDS TERMINATED BY ','
       ENCLOSED BY '"'
       LINES TERMINATED BY '\\n'
       IGNORE 1 ROWS;

       Note: Replace 'path/to/csv_file.csv' with the actual file path of the CSV file.
             Adjust the field and line terminators as needed based on the CSV file format.
             The 'IGNORE 1 ROWS' clause skips the header row if present.

4. Inspect Imported Data:
   - After importing the CSV data, inspect the imported records in the tables.
   - Use the SELECT statement to retrieve and verify the imported data:
     SELECT * FROM table_name LIMIT 10;

5. Data Analysis:
   - Once the data is imported, you can start analyzing it using SQL queries.
   - Write queries to retrieve insights, perform calculations, join tables, and aggregate data as needed.
   - Refer to the provided queries and examples for inspiration.
   - Continuously explore the data from different angles to uncover valuable insights.

6. Documenting and Enhancing Notes:
   - Document the steps you followed, any challenges you faced, and the solutions you implemented.
   - Enhance the notes with additional details, such as database schema diagrams, sample data, or explanations of specific queries.
   - Organize the notes in a way that makes it easy to understand and follow when revisiting the project in the future.

By following these steps and maintaining comprehensive notes, you'll have a structured approach to working with SQL projects involving CSV data. The notes will serve as a valuable reference, making it easier to understand and reproduce the project steps, as well as facilitating knowledge sharing and collaboration.
*/

create database pizzahut;

use pizzahut;

select * from pizzas;

select * from pizza_types;

create table orders
(
order_id int not null,
order_date date not null,
order_time time not null,
primary key(order_id)
);

select * from orders;


create table order_details
(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id)
);


set global local_infile = 1;

LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\order_details.csv'
INTO TABLE order_details
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from order_details;


-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;


-- Calculate the total revenue generated from piza sales.

select round(sum(order_details.quantity * pizzas.price),2) from order_details join pizzas
on pizzas.pizza_id = order_details.pizza_id;


-- Identify the highest-priced pizza.

select pizza_types.name,pizzas.price
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
order by pizzas.price desc limit 1;


select quantity,count(order_details_id)
from order_details group by quantity;



-- Identify the most common pizza size ordered

select pizzas.size, count(order_details.order_details_id) as order_count
from pizzas join order_details
on pizzas.pizza_id = order_details.pizza_id
group by pizzas.size order by order_count desc;


-- List the top 5 most ordered pizza type along with their quantities

select pizza_types.name,sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name
order by quantity desc limit 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered

select pizza_types.name,
sum(order_details.quantity) as quantity
from pizza_types join pizzas
on pizza_types.pizza_type_id = pizzas.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by quantity desc limit 5;


-- Determine the distribution of orders by hour of the day.a

select hour(order_time), count(order_id) as order_count from orders
group by hour(order_time);


-- Join the relevant table to find the category wise distribution of pizzas

select category,count(name) from pizza_types
group by category;


-- Group the orderes by date and calculate the average number of pizzas ordered per day

select round(avg(quantity),0) as avg_pizza_ordered_per_day from 
(select orders.order_date, sum(order_details.quantity) as quantity
from orders join order_details
on orders.order_id = order_details.order_id
group by orders.order_date) as order_quantity; 


-- Determine the top 3 most ordered pizza types based on revenue

select pizza_types.name,
sum(order_details.quantity * pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id = pizza_types.pizza_type_id
join order_details
on order_details.pizza_id = pizzas.pizza_id
group by pizza_types.name order by revenue
desc limit 3;


-- Identify the most popular pizza combinations

SELECT pt1.name AS pizza_type, pt2.name AS topping_type, SUM(od.quantity) AS total_quantity
FROM order_details od
JOIN pizzas p1 ON od.pizza_id = p1.pizza_id
JOIN pizza_types pt1 ON p1.pizza_type_id = pt1.pizza_type_id
JOIN pizzas p2 ON od.order_id = (SELECT order_id FROM order_details WHERE order_details_id = od.order_details_id) AND p2.pizza_id <> p1.pizza_id
JOIN pizza_types pt2 ON p2.pizza_type_id = pt2.pizza_type_id
GROUP BY pt1.name, pt2.name
ORDER BY total_quantity DESC
LIMIT 5;


-- Analyze the average order value (AOV) by hour of the day:

SELECT HOUR(o.order_time) AS hour_of_day, AVG(od.quantity * p.price) AS avg_order_value
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY HOUR(o.order_time)
ORDER BY avg_order_value DESC;

-- Calculate the percentage contribution of each pizza type of total revenue

SELECT pizza_types.category,
ROUND((SUM(order_details.quantity * pizzas.price) / 
       (SELECT SUM(order_details.quantity * pizzas.price) 
        FROM order_details
        JOIN pizzas ON pizzas.pizza_id = order_details.pizza_id)) * 100, 2) AS revenue
FROM pizza_types 
JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category 
ORDER BY revenue DESC;


-- Find the most profitable pizza categories

SELECT pt.category, SUM(od.quantity * p.price) AS total_revenue
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY total_revenue DESC;


-- Analyze the cumulative revenue generated over time

select order_date,
sum(revenue) over(order by order_date) as cum__revenue from
(select orders.order_date,
sum(order_details.quantity * pizzas.price) as revenue
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category

SELECT name, revenue FROM 
(SELECT category, name, revenue,
       RANK() OVER(PARTITION BY category ORDER BY revenue DESC) AS rn
FROM
    (SELECT pizza_types.category, pizza_types.name,
            SUM(order_details.quantity * pizzas.price) AS revenue
    FROM pizza_types 
    JOIN pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name) AS a) AS b
WHERE rn <= 3;


-- Identify the least popular pizza types

SELECT pt.name AS pizza_type, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
LEFT JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY total_quantity ASC
LIMIT 5;


-- Analyze the average order size (number of pizzas per order):

SELECT AVG(order_size) AS avg_order_size
FROM (
  SELECT order_id, COUNT(order_details_id) AS order_size
  FROM order_details
  GROUP BY order_id
) AS order_sizes;


-- Analyze the distribution of orders by day of the week

SELECT DAYNAME(order_date) AS day_of_week, COUNT(order_id) AS order_count
FROM orders
GROUP BY DAYNAME(order_date)
ORDER BY order_count DESC;


-- Find the most commonly ordered pizza size for each category

SELECT pt.category, p.size, COUNT(od.order_details_id) AS order_count
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category, p.size
ORDER BY pt.category, order_count DESC;


-- Identify the most popular pizza toppings

SELECT pt.name AS topping, SUM(od.quantity) AS total_quantity
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
WHERE pt.category = 'Classic'
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;


-- Identify orders with multiple pizza types

SELECT order_id, COUNT(DISTINCT pizza_type_id) AS num_pizza_types
FROM order_details od
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY order_id
HAVING COUNT(DISTINCT pizza_type_id) > 1
ORDER BY num_pizza_types DESC;


-- Identify the average order value (AOV) for orders with and without a specific pizza type

SELECT 
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM order_details od
            JOIN pizzas p ON od.pizza_id = p.pizza_id
            JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
            WHERE od.order_id = o.order_id AND pt.name = 'Pepperoni'
        ) THEN 'With Pepperoni'
        ELSE 'Without Pepperoni'
    END AS order_type,
    AVG(od.quantity * p.price) AS avg_order_value
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
GROUP BY order_type;


-- Find the most popular pizza types by revenue within each category

SELECT pt.category, pt.name AS pizza_type, SUM(od.quantity * p.price) AS total_revenue
FROM pizza_types pt
JOIN pizzas p ON pt.pizza_type_id = p.pizza_type_id
JOIN order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category, pt.name
ORDER BY pt.category, total_revenue DESC;


-- Identify the top customers based on the number of orders placed

SELECT order_id, COUNT(order_details_id) AS order_count
FROM order_details
GROUP BY order_id
ORDER BY order_count DESC
LIMIT 10;


-- Identify the most popular pizza types for each day of the week

SELECT DAYNAME(o.order_date) AS day_of_week, pt.name AS pizza_type, SUM(od.quantity) AS total_quantity
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY DAYNAME(o.order_date), pt.name
ORDER BY day_of_week, total_quantity DESC;


-- Identify the most popular pizza types for first-time customers

SELECT pt.name AS pizza_type, SUM(od.quantity) AS total_quantity
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN pizzas p ON od.pizza_id = p.pizza_id
JOIN pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
WHERE o.order_id NOT IN (
    SELECT order_id
    FROM orders
    GROUP BY order_id
    HAVING COUNT(DISTINCT order_date) > 1
)
GROUP BY pt.name
ORDER BY total_quantity DESC
LIMIT 5;



