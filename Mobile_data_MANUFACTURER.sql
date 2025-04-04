--- MOBILE DATA MANUFACTURER

-- 1.	List all the states in which we have customers who have bought cellphones from 2005 till today.

 select State, IDCustomer,year(date) as Year_bought from DIM_LOCATION as L
inner join FACT_TRANSACTIONS as T
on L.IDLocation = T.IDLocation
where year(date) >= 2005
order by IDCustomer



-- 2.	What state in the US is buying the most 'Samsung' cell phones?

Select top 1 state, count(MANUFACTURER_name) as Samsung_sale from DIM_MODEL as A
inner join DIM_MANUFACTURER as B
on A.IDManufacturer = B.IDManufacturer
inner join FACT_TRANSACTIONS as C
on C.IDModel = A.IDModel
inner join DIM_LOCATION as D
on D.IDLocation = C.IDLocation
where MANUFACTURER_name = 'Samsung' and country = 'US'
group by State
order by Samsung_sale desc

 -- 3.	Show the number of transactions for each model per zip code per state.

 select Model_Name,ZipCode,State, COUNT(Quantity) as Number_transactions, A.IDModel from DIM_MODEL as A
 inner join FACT_TRANSACTIONS as B
 on A.IDModel = B.IDModel
 inner join DIM_LOCATION as C
 on C.IDLocation = B.IDLocation
 group by Model_Name,ZipCode,State, A.IDModel
 order by  Number_transactions

 -- 4.	Show the cheapest cellphone (Output should contain the price also)

 select top 1 * from DIM_MODEL as A
 inner join DIM_MANUFACTURER as B
 on A.IDManufacturer = B.IDManufacturer
 order by Unit_price

 --- 5.	Find out the average price for each model in the top5 manufacturers in terms of sales quantity and order by average price.

 Select top 5 sum(Quantity) as Top_5_manufacturer, avg(Unit_price) as avg_price, Manufacturer_Name 
 from DIM_MODEL as A
inner join DIM_MANUFACTURER as B
on A.IDManufacturer = B.IDManufacturer
inner join FACT_TRANSACTIONS as C
on C.IDModel = A.IDModel
group by  Manufacturer_Name
order by Top_5_manufacturer desc, avg_price

-- 6	List the names of the customers and the average amount spent in 2009, where the average is higher than 500

select Customer_Name ,avg(totalprice) as avg_spend, Year(date) as Year_ from DIM_CUSTOMER as A
inner join FACT_TRANSACTIONS as B
on A.IDCustomer = B.IDCustomer
where Year(date) = 2009
group by Customer_Name, Year(date)
having avg(totalprice) > 500


-- 7.	List if there is any model that was in the top 5 in terms of quantity, simultaneously in 2008, 2009 and 2010


With CTE1 as (Select top 5 A.IDModel, Model_Name, Year(date) as year_, sum(quantity) as QUANTITY_SUM

from DIM_MODEL as A
inner join FACT_TRANSACTIONS as B
on A.IDModel = B.IDModel
where year(date) = 2008
group by year(date), Model_Name, A.IDModel
order by QUANTITY_SUM desc),

CTE2 as (Select top 5 A.IDModel, Model_Name, Year(date) as year_, sum(quantity) as QUANTITY_SUM
from DIM_MODEL as A
inner join FACT_TRANSACTIONS as B
on A.IDModel = B.IDModel
where year(date) = 2009
group by year(date), Model_Name, A.IDModel 
order by QUANTITY_SUM desc),

CTE3 as (Select top 5 A.IDModel, Model_Name, Year(date) as year_,sum(quantity) as QUANTITY_SUM
from DIM_MODEL as A
inner join FACT_TRANSACTIONS as B
on A.IDModel = B.IDModel
where year(date) = 2010
group by year(date), Model_Name, A.IDModel 
order by QUANTITY_SUM desc)

Select IDModel,Model_Name from CTE1
intersect 
Select IDModel,Model_Name from CTE2
intersect  
Select IDModel,Model_Name from CTE3


-- 8.Show the manufacturer with the 2nd top sales in the year of 2009 and the manufacturer with the 2nd top sales
--in the year of 2010.

with Sale_CTE AS (select Manufacturer_Name, sum(totalprice) as Sales_, year(date) as Year_ from DIM_MODEL as A
inner join DIM_MANUFACTURER as B
on A.IDManufacturer = B.IDManufacturer
inner join FACT_TRANSACTIONS as C
on A.IDModel = C.IDModel
where year(date) in (2009, 2010)
group by Manufacturer_Name,year(date))


select * from (select *,
ROW_NUMBER() over(partition by year_ order by sales_ desc) as row_
from Sale_CTE) as T
where row_ = 2

-- 9.	Show the manufacturers that sold cellphones in 2010 but did not in 2009.

WITH CTE1 as (select Manufacturer_Name
from DIM_MANUFACTURER as A
inner join DIM_MODEL as B
on A.IDManufacturer = B.IDManufacturer
inner join FACT_TRANSACTIONS as C
on C.IDModel = B.IDModel
where year(date) = 2010
group by  Manufacturer_Name), 
CTE2 as (select Manufacturer_Name
from DIM_MANUFACTURER as A
inner join DIM_MODEL as B
on A.IDManufacturer = B.IDManufacturer
inner join FACT_TRANSACTIONS as C
on C.IDModel = B.IDModel
where year(date) = 2009
group by  Manufacturer_Name)

select * from CTE1
except 
select * from CTE2

select top 1 * from DIM_CUSTOMER
select top 1 * from DIM_DATE
select top 1 * from DIM_LOCATION
select top 1 * from DIM_MANUFACTURER
select top 1 * from DIM_MODEL
select top 1 * from FACT_TRANSACTIONS

-- 10.	Find top 10 customers and their average spend, average quantity by each year. 
-- Also find the percentage of change in their spend.



select  idcustomer ,YEAR(date)[year],AVG(TotalPrice)[Average_Amount],AVG(Quantity)[Avg_Quantity],
	 (AVG(TotalPrice)-LAG(AVG(TotalPrice),1) over(partition by idcustomer order by idcustomer))/LAG(AVG(TotalPrice),1) 
	 over(partition by idcustomer order by idcustomer)[YOY] from FACT_TRANSACTIONS
	 where IDCustomer in  (select top 20 idcustomer  from FACT_TRANSACTIONS group by IDCustomer order by sum(TotalPrice) desc )
	 group by idcustomer,YEAR(date)
	 order by IDCustomer


