--Find top 20 cities with the highest number of rental properties.
--Frequently used set of cities to reduce repeation

GO
CREATE VIEW top20_cities AS
	Select Top 20 city
	From(
		Select distinct city, count(city)rental_props
		From cleanedData
		Group By city
		)As subquery
	Order By rental_props Desc;

Select *
From top20_cities


--1. What is the average rental price of apartments
-- based on how many bedrooms in some of the major cities in Ontario?
--Arrange the result such that avg rent for each type of room is shown in seperate
--column

GO
CREATE VIEW Avg_Renatl_Price_BY_Room_Top20 AS
Select city, [1] as avg_rent_1R, [1 + Den] as avg_rent_1DR, [2] as avg_rent_2R, [2 + Den] as avg_rent_2DR, [3] as avg_rent_3R, [3 + Den] as avg_rent_3DR
From
	(
		Select city, bedrooms, price
		From cleanedData
		Where city in (-- Get top 20 cities.
						Select *
						From top20_cities
							)
	) bq
Pivot
	(
		avg(price)
		for bedrooms in ([1], [1 + Den], [2], [2 + Den], [3], [3 + Den])
	)
	as result;



--2. Most small families would be looking for apartment of 550-650 sqf in size. 
--   Identify the top 5 most affordable cities in Ontario.

select city, avg_price, no_of_apartments
from (
select city, round(avg(price),2), count(1) as no_of_apartments
, rank() over(order by price ) as rn
from cleanedData
where city in (-- Get top 20 cities.
						Select *
						From top20_cities
							)
and size between 550 and 650
group by city )



--3. What size of an apartment can I expect with a monthly rent of 1500 to 2500 CAD in
--   TOP 20 major cities of Ontario?

GO
CREATE VIEW Avg_Size_1500_2500_Top20 AS
	Select city, Round(avg(size),2) avg_size
	From cleanedData 
	where city in (
					-- Get top 20 cities.
					Select *
					From top20_cities
					)
	and price between 1500 and 2500
	group by city
	order by avg_size;



--4. What are the most expensive rentals in top 20 cities of Otario? 
--   Display the ad, title, city, suburb, cost, size.

GO
CREATE VIEW Max_Rental_Top20 AS
	with cte as
		(select city, max(price) max_price, min(price) min_price
		 from cleanedData
		 where city in (
						-- Get top 20 cities.
						Select *
						From top20_cities
						)
		  group by city)
	Select cd.title, cd.city, cd.price, cd.size, cd.url
	From cleanedData cd
	join cte on cte.city=cd.city and cte.max_price=cd.price
	Where cd.size IS Not Null
	order by cd.city,cd.price;



--5. What is the average rental price in Ontario in different cities?
--   Categorize the result based on size 450-550, 550-700 and over 700.

GO
CREATE VIEW Avg_RentalPrice_Size_Top20 AS
	with cte1 as(
	select cd.*
	, case when size between 400 and 550 then '450-550'
	when size between 550 and 700 then '450-550'
	when size > 700 then '>700'
	end as area_category
	from cleanedData cd
	where city in (
					-- Get top 20 cities.
						Select *
						From top20_cities
					)
	and size is not null ),
	cte2 as
	(select city
	, case when area_category = '450-550' then avg(price) end as avg_price_upto550
	, case when area_category = '450-550' then avg(price) end as avg_price_upto700
	, case when area_category = '>700' then avg(price) end as avg_price_over700
	from cte1
	group by city,area_category)
	select city
	, max(avg_price_upto550) as avg_price_upto_550
	, max(avg_price_upto700) as avg_price_upto_700
	, max(avg_price_over700) as avg_price_over_700
	from cte2
	group by city
	order by city;
