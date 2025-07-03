CREATE DATABASE IF NOT EXISTS google_apps;

USE google_apps;

CREATE TABLE `appdata` (
  `app_id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `app_name` varchar(225),
  `category` varchar(150),
  `rating` DECIMAL(2,1),
  `reviews` int,
  `size` DECIMAL(7,4),
  `installs` int,
  `price` DECIMAL(5,2),
  `content_rating` varchar(150),
  `last_updated` date,
  `android_ver` varchar(100),
  PRIMARY KEY (`app_id`)
);


-- most popular categories

select category, count(app_id) as number_of_apps, sum(installs) as sum_installs, avg(installs) as avg_installs from google_apps.appdata group by category order by avg(installs) desc, sum(installs) desc;
select category, count(app_id) as number_of_apps, sum(installs) as sum_installs, avg(installs) as average_installs from google_apps.appdata group by category order by count(app_id) asc;
select category, count(app_id) as number_of_apps, avg(rating) as avg_rating, avg(installs) as average_installs from google_apps.appdata group by category order by avg_rating desc;


-- analysis on paid/free apps

SELECT
  CASE
    WHEN price = 0 THEN 'Free'
    ELSE 'Paid'
  END AS app_type,
  COUNT(*) AS total_apps,
  ROUND(AVG(rating), 2) AS avg_rating,
  ROUND(AVG(installs)) AS avg_installs,
  ROUND(STD(rating), 2) AS rating_stddev
FROM google_apps.appdata
WHERE rating IS NOT NULL AND installs IS NOT NULL
GROUP BY app_type
ORDER BY app_type;


select app_name, rating, price from google_apps.appdata where price > 0 and reviews > 10000 order by rating desc;


-- rating within category

SELECT 
    app_name, 
    category, 
    rating, 
    ROUND(AVG(rating) OVER (PARTITION BY category), 2) AS avg_category_rating,
    DENSE_RANK() OVER (ORDER BY rating DESC) AS `Rank`
FROM google_apps.appdata;


-- installs within category 

SELECT
  app_name,
  category,
  installs,
  rating,
  price,
  (SELECT AVG(installs) FROM google_apps.appdata where category = 'communication'),
  (SELECT AVG(rating) FROM google_apps.appdata where category = 'communication'),
  RANK() OVER (PARTITION BY category ORDER BY installs DESC) AS rating_rank
FROM google_apps.appdata where category = 'communication' and installs > (SELECT AVG(installs) FROM google_apps.appdata);


-- installs related to reviews

select app_name, reviews, installs, (select avg(installs) from google_apps.appdata) as average_installs from google_apps.appdata order by reviews desc;


-- android versions

select app_name, installs, rating, android_ver from google_apps.appdata order by installs desc, rating desc limit 100;


-- last updated

select last_updated, avg(installs), avg(rating) from google_apps.appdata group by last_updated;


-- size

select size, avg(installs), avg(rating) from google_apps.appdata group by size order by size;

SELECT value_group,
       AVG(installs) AS avg_installs,
       AVG(rating) AS avg_rating
FROM (
    SELECT
        *,
        CASE
            WHEN size BETWEEN 0 AND 5 THEN '1_5'
			WHEN size BETWEEN 6 AND 10 THEN '6_10'
			WHEN size BETWEEN 11 AND 15 THEN '11_15'
			WHEN size BETWEEN 16 AND 20 THEN '16_20'
			WHEN size BETWEEN 21 AND 25 THEN '21_25'
			WHEN size BETWEEN 26 AND 30 THEN '26_30'
			WHEN size BETWEEN 31 AND 35 THEN '31_35'
			WHEN size BETWEEN 36 AND 40 THEN '36_40'
			WHEN size BETWEEN 41 AND 45 THEN '41_45'
			WHEN size BETWEEN 46 AND 50 THEN '46_50'
			WHEN size BETWEEN 51 AND 55 THEN '51_55'
			WHEN size BETWEEN 56 AND 60 THEN '56_60'
			WHEN size BETWEEN 61 AND 65 THEN '61_65'
			WHEN size BETWEEN 66 AND 70 THEN '66_70'
			WHEN size BETWEEN 71 AND 75 THEN '71_75'
			WHEN size BETWEEN 76 AND 80 THEN '76_80'
			WHEN size BETWEEN 81 AND 85 THEN '81_85'
			WHEN size BETWEEN 86 AND 90 THEN '86_90'
			WHEN size BETWEEN 91 AND 95 THEN '91_95'
			WHEN size BETWEEN 96 AND 100 THEN '96_100'
			ELSE 'Uncategorized'
        END AS value_group
    FROM google_apps.appdata
) AS derived_table
GROUP BY value_group
ORDER BY value_group;
        

