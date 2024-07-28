-- A.Pizza Metrics

-- How many pizzas were ordered?
SELECT count(*) as ordered_pizza FROM pizza_runner.customer_orders;

-- How many unique customer orders were made?
select count(distinct(order_id)) from customer_orders

-- How many successful orders were delivered by each runner?
select runner_id,count(*) as succesful_orders from runner_orders_cleaned
where cancellation is null
group by runner_id

-- How many of each type of pizza was delivered?
select pizza_name,count(c.pizza_id) as total_pizza from customer_orders c
join pizza_names p on c.pizza_id=p.pizza_id
join runner_orders_cleaned r on c.order_id=r.order_id
where r.cancellation is null
group by pizza_name

-- How many Vegetarian and Meatlovers were ordered by each customer?
select c.customer_id,pizza_name,count(c.order_id) as total_orders from customer_orders c
join pizza_names p on c.pizza_id=p.pizza_id
group by c.customer_id,p.pizza_name

-- What was the maximum number of pizzas delivered in a single order?
with order_ranks as(select c.order_id,count(c.customer_id) as total_order,row_number() over(order by count(c.customer_id) desc) as ranks
 from customer_orders c
join runner_orders r on c.order_id=r.order_id
where r.distance is not null
group by c.order_id)
select * from order_ranks where ranks=1

-- For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id,sum(case when (nullif(exclusions, '') is not null 
or nullif(extras, '') is not null) then 1 else 0 end) as changed_,sum(case when (nullif(exclusions, '') is  null 
or nullif(extras, '') is  null) then 1 else 0 end) as unchanged  from customer_orders c
join runner_orders r on c.order_id=r.order_id
where r.distance is not null
group by c.customer_id

-- How many pizzas were delivered that had both exclusions and extras?

select count(*) from customer_orders_cleaned c
join runner_orders_cleaned r on c.order_id=r.order_id
where  extras is not null and exclusions is not null and cancellation is null

-- What was the total volume of pizzas ordered for each hour of the day?
select hour(order_time) as each_hour,count(order_id) as total from customer_orders_cleaned
group by each_hour

-- What was the volume of orders for each day of the week?
select dayname(order_time) as days,count(order_id) as total from customer_orders_cleaned
group by days