-- The project is Optimizing Online Sports Retail Revenue
-- Investigating the product information of an online sportswear company with the primary goal of developing plans to increase its income.
-- The handling involved a wide variety of data distributed over numerous tables, including information about pricing, discounts, revenue, ratings, reviews, product descriptions, and website traffic.
-- Data was loaded to Mysql using Python script and it tried to answer the following questions.

-- How do the price points of Nike and Adidas products differ?
SELECT brands_v2.brand, 
 ROUND(AVG(finance.listing_price), 2) as average_price,
 MIN(finance.listing_price) as min_price, 
 MAX(finance.listing_price) as max_price
FROM brands_v2
JOIN finance ON brands_v2.product_id = finance.product_id
WHERE brands_v2.brand IN ('Nike', 'Adidas')
GROUP BY brands_v2.brand;

-- The selling_price was used to get the price points and it was noted that Adidas had the highest average price, min and max price.

-- Is there a difference in the amount of discount offered between the brands?
SELECT brands_v2.brand,
 ROUND(AVG(finance.discount), 2) as average_discount,
 MIN(finance.discount) as min_discount,
 MAX(finance.discount) as max_discount
FROM brands_v2
JOIN finance ON brands_v2.product_id = finance.product_id
WHERE brands_v2.brand IN ('Nike', 'Adidas')
GROUP BY brands_v2.brand;
-- Average discount for Adidas was 0.33 while Nike had 0

-- Is there any correlation between revenue and reviews? And if so, how strong is it?
SELECT CORR(finance.revenue, reviews_v2.reviews) as correlation_coefficient
FROM finance
JOIN reviews_v2 ON finance.product_id = reviews_v2.product_id;

SELECT 
    (
        COUNT(*)*SUM(finance.revenue*reviews_v2.reviews) - SUM(finance.revenue)*SUM(reviews_v2.reviews)
    ) / (
        SQRT(
            (COUNT(*)*SUM(finance.revenue*finance.revenue) - SUM(finance.revenue)*SUM(finance.revenue)) *
            (COUNT(*)*SUM(reviews_v2.reviews*reviews_v2.reviews) - SUM(reviews_v2.reviews)*SUM(reviews_v2.reviews))
        )
    ) as correlation_coefficient
FROM 
    finance
JOIN 
    reviews_v2 ON finance.product_id = reviews_v2.product_id;
-- The correlation_coefficient was 0.66 meaning there moderate correlations between revenue and reviews

-- Does the length of a product’s description influence a product’s rating and reviews?
SELECT 
    (
        COUNT(*)*SUM(LENGTH(info_v2.description)*reviews_v2.rating) - SUM(LENGTH(info_v2.description))*SUM(reviews_v2.rating)
    ) / (
        SQRT(
            (COUNT(*)*SUM(LENGTH(info_v2.description)*LENGTH(info_v2.description)) - SUM(LENGTH(info_v2.description))*SUM(LENGTH(info_v2.description))) *
            (COUNT(*)*SUM(reviews_v2.rating*reviews_v2.rating) - SUM(reviews_v2.rating)*SUM(reviews_v2.rating))
        )
    ) as correlation_coefficient_rating,
    (
        COUNT(*)*SUM(LENGTH(info_v2.description)*reviews_v2.reviews) - SUM(LENGTH(info_v2.description))*SUM(reviews_v2.reviews)
    ) / (
        SQRT(
            (COUNT(*)*SUM(LENGTH(info_v2.description)*LENGTH(info_v2.description)) - SUM(LENGTH(info_v2.description))*SUM(LENGTH(info_v2.description))) *
            (COUNT(*)*SUM(reviews_v2.reviews*reviews_v2.reviews) - SUM(reviews_v2.reviews)*SUM(reviews_v2.reviews))
        )
    ) as correlation_coefficient_reviews
FROM 
    info_v2
JOIN 
    reviews_v2 ON info_v2.product_id = reviews_v2.product_id;
    
 -- correlation_coefficient_rating was 0.154 and correlation_coefficient_reviews was 0.16 meaning the length of a product’s description has no influence on rating and reviews.


-- Are there any trends or gaps in the volume of reviews by month?
-- '%Y-%m-01'), '%Y-%m-%d')  STR_TO_DATE(DATE_FORMAT
SELECT month(traffic_v3.last_visited) as month, COUNT(*) as review_count
FROM traffic_v3
JOIN reviews_v2 ON traffic_v3.product_id = reviews_v2.product_id
where last_visited IS NOT NULL
GROUP BY month
ORDER BY review_count desc;
-- March, February and January had the highest reviews counts, 330, 327 and 310 respectively.

-- How much of the company’s stock consists of footwear items? What is the average revenue generated by these products
SELECT 
    (SELECT COUNT(*) FROM info_v2 WHERE product_name LIKE '%shoes%') AS footwear_count,
    (SELECT COUNT(*) FROM info_v2) AS total_count,
    ((SELECT COUNT(*) FROM info_v2 WHERE product_name LIKE '%shoes%') * 100.0) / 
    (SELECT COUNT(*) FROM info_v2) AS footwear_percentage,
    AVG(revenue) AS average_revenue
FROM 
    info_v2
JOIN 
    finance ON info_v2.product_id = finance.product_id
WHERE 
    info_v2.product_name LIKE '%shoes%';

-- The total footwear count was 2259, a representation of 71.06% and average revenue of 4708.5


/*How does footwear’s average revenue differ from clothing products?*/
SELECT 
    COUNT(CASE WHEN description LIKE '%shoes%' THEN 1 END) AS footwear_count,
    COUNT(CASE WHEN description NOT LIKE '%shoes%' THEN 1 END) AS clothing_count,
    (COUNT(CASE WHEN description LIKE '%shoes%' THEN 1 END) * 100.0) / COUNT(*) AS footwear_percentage,
    AVG(CASE WHEN description LIKE '%shoes%' THEN revenue END) AS footwear_average_revenue,
    AVG(CASE WHEN description NOT LIKE '%shoes%' THEN revenue END) AS clothing_average_revenue
FROM 
    info_v2
JOIN 
    finance ON info_v2.product_id = finance.product_id;
  --  Footwear_avergae_revenue is higher compared to clothing_average_revenue (4672.58 and '2312.21)




