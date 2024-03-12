/*                                             PROJECT 1         


1.Gsearch seems to be the biggest driver of our business. Could you pull monthly trends 
  for gsearch sessions and orders so that we can showcase the growth there?

*/
use mavenfuzzyfactory;
select year(website_sessions.created_at) as yr,
		month(website_sessions.created_at) as mo,
		count(website_sessions.website_session_id) as gsearch_sessions,
		count(orders.order_id) as gsearch_orders,
		count(orders.order_id)/count(website_sessions.website_session_id) as gsearch_ses_to_ord_conrt
from website_sessions left join orders

on website_sessions.website_session_id=orders.website_session_id
where utm_source="gsearch" and website_sessions.created_at<"2012-11-27"
group by year(website_sessions.created_at),month(website_sessions.created_at)
order by year(website_sessions.created_at),month(website_sessions.created_at) ;


/*                                                      
2. Next, it would be great to see a simillar monthly trend for Gsearch, but this
   time splitting out nonbrand and brand campaigns seperately. I am wondering if
   brand is picking up at all. If so, this is a good story to tell.

*/
select year(website_sessions.created_at) as yr,
		month(website_sessions.created_at) as mo,
		count(case when utm_campaign='brand' then website_sessions.website_session_id end) as gsearch_brand_sessions,
		count(case when utm_campaign = 'brand' then orders.order_id end) as gsearch_brand_orders,
		count(case when utm_campaign='nonbrand' then website_sessions.website_session_id end) as gsearch_nonbrand_sessions,
		count(case when utm_campaign = 'nonbrand' then orders.order_id end) as gsearch_nonbrand_orders
from website_sessions left join orders

on website_sessions.website_session_id=orders.website_session_id
where utm_source="gsearch" and website_sessions.created_at<"2012-11-27"
group by year(website_sessions.created_at),month(website_sessions.created_at)
order by year(website_sessions.created_at),month(website_sessions.created_at) ;


/*                                                      
3. While we're on Gsearch, could you dive into nonbrand, and pull monthly sessions
   and orders split by device type? I want to flex our analytical muscles a little 
   and show the board we really know our traffic sources.

*/
select year(website_sessions.created_at) as yr,
		month(website_sessions.created_at) as mo,
		count(case when device_type='mobile' then website_sessions.website_session_id end) as gsearch_nonbrand_mobile_sessions,
		count(case when device_type='mobile' then orders.order_id end) as gsearch_nonbrand_mobile_orders,
		count(case when device_type='desktop' then website_sessions.website_session_id end) as gsearch_nonbrand_desktop_sessions,
		count(case when device_type='desktop' then orders.order_id end) as gsearch_nonbrand_desktop_orders
from website_sessions left join orders

on website_sessions.website_session_id=orders.website_session_id
where utm_source="gsearch" and utm_campaign='nonbrand' and website_sessions.created_at<"2012-11-27"
group by year(website_sessions.created_at),month(website_sessions.created_at)
order by year(website_sessions.created_at),month(website_sessions.created_at) ;


/*                                                      
4. I'm worried that one of our more pessimistic board members may be concerned about
   the large % of traffic from Gsearch. Can you pull monthly trends for Gsearch,
   alongside monthly trends for each of our other channels?

*/        
select year(created_at),
		month(created_at),
        count(case when utm_source='gsearch' then website_session_id end) as gsearch_sessions,
		count(case when utm_source='bsearch' then website_session_id end) as bsearch_sessions,
		count(case when utm_source='socialbook' then website_session_id end) as socialbook_sessions,
		count(case when utm_source is null and http_referer is not null then website_session_id end) as organic_sessions,
        count(case when utm_source is null and http_referer is null then website_session_id end) as direct_sessions
        from website_sessions
        where created_at<"2012-11-27"
group by 1,2
order by 1,2 ;
        

/*                                                      
5. I'd like to tell the story of our website performace improvemensts over the course
   of the first 8 months. Could you pull sessions to order conversion rates, by month?	  

*/        
select year(website_sessions.created_at),
		month(website_sessions.created_at),
        count(website_sessions.website_session_id) as sessions,
        count(orders.order_id) as orders,
        count(orders.order_id) /count(website_sessions.website_session_id) as sesn_to_ord_conrt
from website_sessions 
left join orders
on website_sessions.website_session_id=orders.website_session_id 
where website_sessions.created_at<"2012-11-27" 
group by 1,2 
order by 1,2 ;

/*                                                      
6. For the gsearch lander_test, please estimate the revenue that test earned us(Hint:
   Look at the increase in CVR from the test(jun 19 - jul 28), and use nonbrand 
   sessions and revenue since then to calculate increment.

*/ 

select min(website_pageview_id)
from website_pageviews
where pageview_url='/lander-1' ;

create temporary table landing_pg_sesns
select 
	website_sessions.website_session_id,
	min(website_pageviews.website_pageview_id) as landing_id
from website_sessions inner join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where utm_source='gsearch' and website_sessions.created_at <"2012-07-28" and
utm_campaign='nonbrand' and   website_pageviews.website_pageview_id>=23504
group by 1  ; 
    
create temporary table landing_url
select landing_pg_sesns.website_session_id,
		website_pageviews.pageview_url as landing_url
from landing_pg_sesns left join website_pageviews
on  landing_pg_sesns.landing_id = website_pageviews.website_pageview_id
where website_pageviews.pageview_url in ('/home','/lander-1')   ;



select landing_url.landing_url,
		count(landing_url.website_session_id) as sessions,
        count(orders.order_id) as ords,
        count(orders.order_id)/count(landing_url.website_session_id) as sesn_to_ord_conrt

from landing_url 
left join orders
on landing_url.website_session_id = orders.website_session_id
group by 1 ;

-- /home session to order conversion rate= 0.0318
-- /lander-1 session to order conversion rate= 0.0406
-- so, conversion rate increment = 0.087

select max(website_sessions.website_session_id)
from website_sessions inner join website_pageviews
on website_sessions.website_session_id=website_pageviews.website_session_id
where website_sessions.created_at<'2012-11-27'
and website_pageviews.pageview_url='/home'
and utm_source='gsearch'
and utm_campaign='nonbrand' ;

-- 17145 last website session for '/home' landing page

select count(website_session_id)
from website_sessions 
where created_at<'2012-11-27'
and website_session_id>17145
and utm_source='gsearch'
and utm_campaign='nonbrand' ;

-- 22972 sessions since the test      
-- 0.087 x 22972 = 202 incremental orders since 7/29
-- so, nearly 50 orders per month increase 


/*                                                      
7. For the landing page test you analyzed previously, it would be great to show a
   full conversion funnel from each of the two pages to orders. You can use the same 
   time period you analyzed last time (jun 19 - jul 28).

*/

create  temporary table session_pages1

select sessions,
		max(home_pg) as home,
        max(lander_1_pg) as lander,
        max(product_pg) as products,	
		max(mrfuzzy_pg) as mrfuzzy,
        max(cart_pg) as cart,
        max(shipping_pg) as shipping,
        max(billing_pg) as billing,
		max(thankyou_pg) as thankyou

from(

		select website_sessions.website_session_id as sessions,
				website_pageviews.pageview_url as pages_visited,
				case when pageview_url='/home' then 1 else 0 end as home_pg,
				case when pageview_url='/lander-1' then 1 else 0 end as lander_1_pg,
				case when pageview_url='/products' then 1 else 0 end as product_pg,
				case when pageview_url='/the-original-mr-fuzzy' then 1 else 0 end as mrfuzzy_pg,
				case when pageview_url='/cart' then 1 else 0 end as cart_pg,
				case when pageview_url='/shipping' then 1 else 0 end as shipping_pg,
				case when pageview_url='/billing' then 1 else 0 end as billing_pg,
				case when pageview_url='/thank-you-for-your-order' then 1 else 0 end as thankyou_pg
				
		from website_sessions inner join website_pageviews 
		on website_sessions.website_session_id=website_pageviews.website_session_id
		where website_sessions.created_at between '2012-06-19' and '2012-07-28'
		and website_sessions.utm_source='gsearch' and utm_campaign='nonbrand'
		order by 1,website_sessions.created_at        
   ) as page_visited
   
group by 1 ;

select  	
			case when home=1 then 'home_pg' 
			 when lander=1 then 'custom_lander'
             else 'check logic'
             end as first_pg_visit,
             count(sessions) as sessions,
            count( case when products=1 then sessions end) as visited_products,
            count( case when mrfuzzy=1 then sessions end) as visited_mrfuzzy,
			count( case when cart=1 then sessions end) as visited_cart,
            count( case when shipping=1 then sessions end) as visited_shipping,
            count( case when billing=1 then sessions end) as visited_billing,
            count( case when thankyou=1 then sessions end) as visited_thankyou
            
            
            
            
from session_pages1
group by 1 ;

-- finally the click rates for overall conversion funnel

select first_pg_visit,
		visited_products/sessions as landpg_to_products_conrt,
        visited_mrfuzzy/visited_products as products_to_mrfuzzy_conrt,
        visited_cart/visited_mrfuzzy as visited_mrfuzzy_to_visited_cart,
        visited_shipping/visited_cart as visited_cart_to_visited_shipping,
        visited_billing/visited_shipping as visited_shipping_to_visited_billing,
		visited_thankyou/visited_billing as visited_billing_to_visited_thankyou

from
		(select  	
			case when home=1 then 'home_pg' 
			 when lander=1 then 'custom_lander'
             else 'check logic'
             end as first_pg_visit,
             count(sessions) as sessions,
            count( case when products=1 then sessions end) as visited_products,
            count( case when mrfuzzy=1 then sessions end) as visited_mrfuzzy,
			count( case when cart=1 then sessions end) as visited_cart,
            count( case when shipping=1 then sessions end) as visited_shipping,
            count( case when billing=1 then sessions end) as visited_billing,
            count( case when thankyou=1 then sessions end) as visited_thankyou
            
from session_pages1
group by 1) as conversion_funnel ;


/*                                                      
8. I'd love for you to quantify the impact of our billing test, as well. Please analyze
   the lift generated from the test (Sep10- Nov 10), in terms of revenue per billing
   page sessoins, and then pull the number of billing page sessions for the past
   month to understand monthly impact.

*/


select billing_url,
		count(billing_sessions) as billing_pg_sessions,
        sum(order_revenue)/count(billing_sessions) as revenue_per_billing_sessions
from(        
		select website_pageviews.website_session_id as billing_sessions,
				website_pageviews.pageview_url billing_url,
				orders.order_id as orders,
				orders.price_usd as order_revenue
		from website_pageviews left join orders
		on   website_pageviews.website_session_id=orders.website_session_id
		where website_pageviews.created_at between "2012-09-10" and "2012-11-10" 
		and website_pageviews.pageview_url in ('/billing','/billing-2')    
) as billing_sessions_detail
group by 1 ;



select count(website_session_id) as billing_sessions
				
		from website_pageviews 
		
		where website_pageviews.created_at between "2012-10-27" and "2012-11-27" 
		and website_pageviews.pageview_url in ('/billing','/billing-2') ;



