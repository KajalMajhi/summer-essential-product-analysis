--Product & Pricing analysis Question:-
--Which brand have the highest pricing power based on popularity ?
select brand, round(avg(average_price * popularity_rating)::numeric, 2) as pricing_power
from beauty_products
group by brand
order by pricing_power desc;

--Are organic products priced higher than non-organic ones?
select case when organic = 'Yes' then 'Organic'
        else 'Non-Organic'
		end as type,
     round(avg(average_price)::numeric, 2) as avg_price from beauty_products
group by organic;

--What are the most overpriced and underpriced products based on customer ratings?
select product_name, 
       category, 
	   average_price, 
	   popularity_rating,
	   case when average_price > (select avg(average_price) from beauty_products)
	          and popularity_rating < 3 then 'Over Priced'
			when average_price < (select avg(average_price) from beauty_products)
			   and popularity_rating > 4 then 'Under Priced'
	      else 'Fairly Priced'
		end as Price_analysis
from beauty_products;

--Identifying "Dead Stock"- Products that are unpopular & Overpriced
select 
     product_name, 
	 category, 
	 average_price, 
	 popularity_rating,
	 case when popularity_rating < 2 and 
	      average_price > (select avg(average_price) from beauty_products) then 'Dead Stock'
		  else 'Active Product'
		end as stock_status
from beauty_products;

--Customer & Market Behaviour Analysis Question:-
--What are the top-selling products in each region?
with rank_products_by_region as		
		(select 
		     region_usage, 
			 product_name, 
			 count(product_id) as sales_count,
			 rank() over(partition by region_usage order by count(product_id) desc) rank
		from beauty_products
		group by 1, 2)
select * from rank_products_by_region
where rank < 2;

--Are Expensive Beauty Products actually better? (Price vs. Rating)
select 
    case when bucket = 1 then 'Budget'
	     when bucket = 2 then 'Mid-Range'
	  else 'Luxury'	 
	end as price_category,
	round(avg(popularity_rating)::decimal, 2) as avg_rating
from 
   (select popularity_rating,
           width_bucket(average_price,(select min(average_price) from beauty_products),
		    (select max(average_price) from beauty_products), 3) as bucket
	from beauty_products) k
group by 1
order by 2 desc;

--What age group spends the most on personal care products?
select age_group, 
      round(avg(average_price)::decimal, 2) as avg_spending,
	  count(product_id) as total_purchases
from beauty_products
group by 1
order by 2 desc;

--Are waterproof products more popular than non-waterproof ones?
select waterproof, round(avg(popularity_rating)::decimal, 2) as avg_rating from beauty_products
group by 1;

-- Predicting Customer Loyalty Based on Product Choices
select 
   region_usage,
   category, 
   round(avg(
	         popularity_rating * 
			 case when usage_frequency = 'Daily' then 5
			      when usage_frequency = 'Weekly' then 3
				  when usage_frequency = 'Occasional' then 1
			  else 0
			end  
		   )::decimal, 2) as Loyalty_Score
from beauty_products
group by category, region_usage
order by 2 desc;

----Most Prefered ingredient.
select primary_ingredient as ingredient, 
       count(product_id) as total_products, 
	   round(avg(popularity_rating)::decimal, 2) as avg_rating
from beauty_products
group by 1
order by 3 desc;

--Business Strategy & Competitive Analysis Question:-
--Which beauty ingredient is the most preferred by cutomers?
select primary_ingredient, 
       count(product_id) as total_product,
	   round(avg(popularity_rating)::decimal, 2) as avg_rating
from beauty_products
group by 1
order by 3 desc;

--Which e-commerce platform sells the most popular products?
select online_availability, count(product_id) as total_product,
     round(avg(popularity_rating)::decimal, 2) as avg_product_rating
from beauty_products
group by 1
order by 2 desc;

--Which brands dominate specific product category?
select category, brand, count(product_id) as total_products,
  rank() over(partition by category order by count(product_id) desc) as category_rank
from beauty_products
group by 1, 2;

--Find The Best Time to Launch Seasonal Promotions 
select 
    region_usage, 
	avg(summer_essential_score) as avg_seasonal_demand,
	count(product_id) as total_product_sold
from beauty_products
group by region_usage
order by 2 desc;

--Should a Company invest in a new "Men's Beauty" Product Line?
select 
    gender, 
	count(product_id) as total_products,
	round(avg(popularity_rating)::numeric, 2) as avg_rating
from beauty_products
group by gender;









