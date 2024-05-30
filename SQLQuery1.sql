--create a table
create database df_orders(
[order_id] int primary key,
[order_date] date,
[ship_mode] varchar(20),
[segment] varchar(20),
[country] varchar(20),
[city] varchar(20),
[state] varchar(20),
[postal_code] varchar(20),
[region] varchar(20),
[category] varchar (20),
[sub_category] varchar (20),
[product_id] varchar (50),
[quantity] int,
[discount] decimal(7,2),
[sale_price] decimal(7,2),
[profit] decimal (7,2)
)

--find top 10 highest revenue generating product
select top 10 product_id,sum(sale_price) as sales
from df_orders
group by product_id
order by sales desc
-- find top 5 highest selling product in each region

with cte as (
select region,product_id ,sum(sale_price) as sales
from df_orders
group by region,product_id)
select * from(
select * ,
row_number() over (partition by region order by sales desc) as rn
from cte) A
where rn<=5
-- find month over month growth comparison for 2022 and 2023 sales eg:jan 2022 vs jan 2023
with cte as(
select  year(order_date) as order_year,month(order_date)
as order_month,sum(sale_price) as sales
from df_orders
group by year(order_date),month(order_date)
--order by year(order_date),month(order_date)
)
select order_month
,sum(case when order_year=2022 then sales else 0 end)
,sum(case when order_year=2023 then sales else 0 end)
from cte
group by order_month
order by order_month

-- for each category which month had highest sales
with CTE as(
select category ,month(order_date) as months ,year(order_date) as years,sum(sale_price) as sales
from df_orders
group by category,month(order_date),year(order_date)
--order by sales desc
)
select * from(
select *,
row_number() over( partition by  category order by sales desc) as rn
from cte) as a
where rn=1

-- which sub category had highest growth by profile in 2023 compare to 2022
with cte as(
select  sub_category,year(order_date) as order_year,
sum(profit) as profit 
from df_orders
group by sub_category,year(order_date)
--order by profit desc
),
cte2 as(
select sub_category ,
sum(case when order_year=2022 then profit else 0 end) as profit_2022
, sum(case when order_year=2023 then profit else 0 end) as profit_2023
from cte
group by sub_category
)
select top 1 * ,(profit_2023-profit_2022)*100/profit_2022
from cte2
order by (profit_2023-profit_2022)*100/profit_2022 desc