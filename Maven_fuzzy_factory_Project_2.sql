 /*                                             PROJECT 2         
1.First,I'd like to show our volume growth.Can you pull overall session and order volume,
trended by quarter for the life of the business? Since the most recent quarter is incomplete,
you can decide how to handle it.

*/                                    
select year(website_sessions.created_at) as yr,
		quarter(website_sessions.created_at) quatr,
		count(website_sessions.website_session_id) as sessions,
		count(orders.order_id) as orders
 from website_sessions left join orders
 on website_sessions.website_session_id=orders.website_session_id
 group by 1,2
 order by 1,2   ;
 
 /*                                                      
2. Next,let's showcase all of our efficiency impovements. I would love to show quarterly
   figures since we launched, for session_to_order conversion rate, revenue per order, and 
   revenue per sesssion.

*/
select 	year(website_sessions.created_at) as yr,
		quarter(website_sessions.created_at) quatr,
	
		count(orders.order_id)/count(website_sessions.website_session_id) as sessions_to_orders_conrt,
        sum(orders.price_usd)/count(orders.order_id) as revenue_per_order,
        sum(orders.price_usd)/count(website_sessions.website_session_id) as revenue_per_session

from website_sessions left join orders
on website_sessions.website_session_id=orders.website_session_id       
group by 1,2   ;     

 /*                                                      
3.I'd like to show how we've grown specific channels. Could you pull a quaterly view of orders
  from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and 
  direct type-in?

*/
 select year(website_sessions.created_at) as yr,
		quarter(website_sessions.created_at) as quatr,
        count(case when website_sessions.utm_source='gsearch' and website_sessions.utm_campaign='nonbrand' then orders.order_id end ) as gsearch_nonbrand_orders,
		count(case when website_sessions.utm_source='bsearch' and website_sessions.utm_campaign='nonbrand' then orders.order_id end ) as bsearch_nonbrand_orders,
		count(case when  website_sessions.utm_campaign='brand' then orders.order_id end) as brand_orders,
		count(case when website_sessions.utm_source is null and http_referer is not null then orders.order_id end) as organic_orders,
		count(case when website_sessions.utm_source is null and http_referer is  null then orders.order_id end) as direct_typein_orders

 from website_sessions inner join orders
 on website_sessions.website_session_id=orders.website_session_id
 group by 1,2
 order by 1,2 ;

  /*                                                      
4. Next, let's show the overall session-to-order conversion rate trends for those same channels
   by quarter. Please also make a note of any periods where we made major improvements or 
   optimaztions.

*/
 
 select year(website_sessions.created_at) as yr,
		quarter(website_sessions.created_at) as quatr,
        count(case when website_sessions.utm_source='gsearch' and website_sessions.utm_campaign='nonbrand' then orders.order_id end )
        /count(case when website_sessions.utm_source='gsearch' and website_sessions.utm_campaign='nonbrand' then website_sessions.website_session_id end )as gsearch_nonbrand_sesn_to_order_conrt,
		count(case when website_sessions.utm_source='bsearch' and website_sessions.utm_campaign='nonbrand' then orders.order_id end )
        /count(case when website_sessions.utm_source='bsearch' and website_sessions.utm_campaign='nonbrand' then website_sessions.website_session_id end )as bsearch_nonbrand_sesn_to_order_conrt,
		count(case when  website_sessions.utm_campaign='brand' then orders.order_id end)
        /count(case when  website_sessions.utm_campaign='brand' then website_sessions.website_session_id end)as brand_sesn_to_orders_conrt,
		count(case when website_sessions.utm_source is null and http_referer is not null then orders.order_id end)
        /count(case when website_sessions.utm_source is null and http_referer is not null then website_sessions.website_session_id end)as organic_sesn_to_orders_conrt,
		count(case when website_sessions.utm_source is null and http_referer is  null then orders.order_id end)
        /count(case when website_sessions.utm_source is null and http_referer is  null then website_sessions.website_session_id end)as direct_typein_sesn_to_orders_conrt

 from website_sessions left join orders
 on website_sessions.website_session_id=orders.website_session_id
 group by 1,2
 order by 1,2  ;
 
  /*                                                      
5. We've come a long way since the days of selling a single product.Let's pull monthly 
   trending for revenue and margin by product, along with total sales and revenue. Note
   anything you notice about seasonality. 
*/
select  year(created_at) as yr,
		month(created_at) as mo,
		sum(case when product_id=1 then  price_usd end) as revenue_prodct_1,
        sum(case when product_id=1 then price_usd-cogs_usd end) as margin_product_1,
        sum(case when product_id=2 then price_usd end) as revenue_prodct_2,
        sum(case when product_id=2 then price_usd-cogs_usd end)  as margin_product_2,
        sum(case when product_id=3 then price_usd end) as revenue_prodct_3,
        sum(case when product_id=3 then price_usd-cogs_usd end) as margin_product_3,
        sum(case when product_id=4 then price_usd end) as revenue_prodct_4,
        sum(case when product_id=4 then price_usd-cogs_usd end) as margin_product_4,
        sum(price_usd) as total_revenue,
        sum(price_usd-cogs_usd) as total_sales
        
 from order_items
 group by 1,2
 order by 1,2  ;
 

  /*                                                      
6. Let's dive deeper into the impact of introducing new products. Please pull monthly sessions
   to the /products page, and show how the % of those sessions clicking through another page
   has changed over time, along with a view of how conversion from /products to placing an
   order has improved.


*/

create temporary table lander_pg
select
		website_sessions.website_session_id as sessions,
		min(website_pageviews.website_pageview_id) as min_pgvw
from website_sessions inner join website_pageviews
on website_sessions.website_session_id= website_pageviews.website_session_id     
group by 1 ; 

create temporary table pg_count_per_sesn
select  year(website_pageviews.created_at) as yr,
		month(website_pageviews.created_at) as mo,
		lander_pg.sessions as sessions,
        count(website_pageviews.pageview_url) as pgs_per_sesn
        
from lander_pg inner join website_pageviews 
on lander_pg.sessions=website_pageviews.website_session_id
and website_pageviews.website_pageview_id > lander_pg.min_pgvw        
group by 1,2,3 ;

select max(pgs_per_sesn) from pg_count_per_sesn;

select yr,
	   mo,
       count(sessions) as pd_sessions,
       count(case when pgs_per_sesn>1 then sessions end) as after_product_sessions,
       count(case when pgs_per_sesn>1 then sessions end)/count(sessions) as click_through_rate,
       count(case when pgs_per_sesn=6 then sessions end) as orders,
       count(case when pgs_per_sesn=6 then sessions end)/ count(sessions) as produc_to_order_clrt

from pg_count_per_sesn
group by 1,2 ;

  /*                                                      
7.we made our 4th product available as a primary product on December 05,2014 (it was
  previously only a cross-sell item). Could you please pull sales data since then, and
  how well each product cross-sells from one another?

*/

create temporary table overall_orders
select orders.order_id as orders,
		orders.primary_product_id as primary_product,
        order_items.product_id as x_sold
from orders left join order_items
on orders.order_id= order_items.order_id
and order_items.is_primary_item=0  
where orders.created_at >'2014-12-05' ;     
        
 select 
		primary_product,
        count(orders),
        count(case when x_sold=1 then orders end) as x_sold_pdt1,
        count(case when x_sold=2 then orders end) as x_sold_pdt2,
        count(case when x_sold=3 then orders end) as x_sold_pdt3,
        count(case when x_sold=4 then orders end) as x_sold_pdt4,
		count(case when x_sold=1 then orders end)/count(orders) as x_sold_pdt1_rt, 
        count(case when x_sold=1 then orders end)/count(orders) as x_sold_pdt2_rt,
        count(case when x_sold=1 then orders end)/count(orders) as x_sold_pdt3_rt,
        count(case when x_sold=1 then orders end)/count(orders) as x_sold_pdt4_rt
 
 
 
 from overall_orders
 group by 1
 order by 1;