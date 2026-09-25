-- =========================================================
-- Budgeting App Review Analysis: SQL queries
-- Database: data/processed/reviews.db, table: reviews
-- =========================================================


-- Q1: Overview per app (reviews, average rating, % 1-star and 5-star)
SELECT app_name,
       COUNT(*) AS reviews,
       ROUND(AVG(score), 2) AS avg_rating,
       ROUND(100.0 * SUM(CASE WHEN score = 1 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_1_star,
       ROUND(100.0 * SUM(CASE WHEN score = 5 THEN 1 ELSE 0 END) / COUNT(*), 1) AS pct_5_star
FROM reviews
GROUP BY app_name
ORDER BY avg_rating DESC;


-- Q1: Monthly rating trend with a 3-month rolling average
WITH monthly AS (
    SELECT app_name, month,
           COUNT(*) AS reviews,
           AVG(score) AS avg_rating
    FROM reviews
    GROUP BY app_name, month
)
SELECT app_name, month, reviews,
       ROUND(avg_rating, 2) AS avg_rating,
       ROUND(AVG(avg_rating) OVER (
           PARTITION BY app_name
           ORDER BY month
           ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
       ), 2) AS rolling_3m
FROM monthly
ORDER BY app_name, month;


-- Q2: Paid vs free/freemium apps
SELECT CASE WHEN app_name IN ('YNAB', 'Monarch Money') THEN 'Paid'
            ELSE 'Free / freemium' END AS pricing_model,
       COUNT(*) AS reviews,
       ROUND(AVG(score), 2) AS avg_rating
FROM reviews
GROUP BY pricing_model;


-- Q6: Reviews, rating, and Mint mentions by app and Mint shutdown period
SELECT app_name, mint_period,
       COUNT(*) AS reviews,
       ROUND(AVG(score), 2) AS avg_rating,
       ROUND(100.0 * SUM(mentions_mint) / COUNT(*), 1) AS pct_mention_mint
FROM reviews
GROUP BY app_name, mint_period
ORDER BY app_name, mint_period;


-- Q7: Ratings of reviews mentioning Mint vs not, per app
SELECT app_name,
       CASE WHEN mentions_mint = 1 THEN 'Mentions Mint' ELSE 'No mention' END AS group_name,
       COUNT(*) AS reviews,
       ROUND(AVG(score), 2) AS avg_rating
FROM reviews
GROUP BY app_name, group_name
ORDER BY app_name, group_name;