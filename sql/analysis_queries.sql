-- =========================================================
-- Budgeting App Review Analysis: SQL queries
-- Database: data/processed/reviews.db
-- Tables: reviews (one row per review)
--         review_categories (predicted category and confidence per review, joined on reviewId)
-- =========================================================


-- =========================================================
-- Ratings and the Mint shutdown (notebook 03_eda)
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


-- =========================================================
-- Classifier output check (notebook 04_classification)
-- =========================================================

-- Predicted categories per app (checks the join between the two tables)
SELECT r.app_name, c.category, COUNT(*) AS reviews
FROM reviews r
JOIN review_categories c ON r.reviewId = c.reviewId
GROUP BY r.app_name, c.category
ORDER BY r.app_name, reviews DESC;


-- =========================================================
-- Complaint analysis (notebook 05_analysis)
-- =========================================================

-- Q3: Share of each complaint category within each app's complaints
-- (Praise and Other are excluded, so percentages are out of complaints only)
WITH complaints AS (
    SELECT r.app_name, c.category
    FROM reviews r
    JOIN review_categories c ON r.reviewId = c.reviewId
    WHERE c.category NOT IN ('Praise', 'Other / off-topic')
)
SELECT app_name, category,
       COUNT(*) AS reviews,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY app_name), 1) AS pct
FROM complaints
GROUP BY app_name, category
ORDER BY app_name, pct DESC;


-- Q3 robustness check: same as above, using only predictions with confidence of at least 0.5
WITH complaints AS (
    SELECT r.app_name, c.category
    FROM reviews r
    JOIN review_categories c ON r.reviewId = c.reviewId
    WHERE c.category NOT IN ('Praise', 'Other / off-topic')
      AND c.confidence >= 0.5
)
SELECT app_name, category,
       COUNT(*) AS reviews,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY app_name), 1) AS pct
FROM complaints
GROUP BY app_name, category
ORDER BY app_name, pct DESC;


-- Q4: Average rating for each category (which complaints come with the lowest ratings)
SELECT c.category,
       COUNT(*) AS reviews,
       ROUND(AVG(r.score), 2) AS avg_rating
FROM reviews r
JOIN review_categories c ON r.reviewId = c.reviewId
GROUP BY c.category
ORDER BY avg_rating;


-- Q5: Share of complaints by category per quarter (which complaints are growing or shrinking)
WITH quarterly AS (
    SELECT substr(r.month, 1, 4) || '-Q' || ((CAST(substr(r.month, 6, 2) AS INTEGER) + 2) / 3) AS quarter,
           c.category
    FROM reviews r
    JOIN review_categories c ON r.reviewId = c.reviewId
    WHERE c.category NOT IN ('Praise', 'Other / off-topic')
)
SELECT quarter, category,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY quarter), 1) AS pct
FROM quarterly
GROUP BY quarter, category
ORDER BY quarter;


-- Rating drops: category shares for Rocket Money and YNAB, early 2025 vs 2026
-- (includes Praise, so a falling Praise share shows up next to the rising complaints)
WITH periods AS (
    SELECT r.app_name, c.category,
           CASE WHEN r.month BETWEEN '2025-01' AND '2025-06' THEN 'a_early_2025'
                WHEN r.month >= '2026-01' THEN 'b_2026' END AS period
    FROM reviews r
    JOIN review_categories c ON r.reviewId = c.reviewId
    WHERE r.app_name IN ('Rocket Money', 'YNAB')
)
SELECT app_name, category, period,
       ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (PARTITION BY app_name, period), 1) AS pct_of_reviews
FROM periods
WHERE period IS NOT NULL
GROUP BY app_name, category, period
ORDER BY app_name, category, period;


-- Verification: random sample of YNAB usability reviews from 2026
SELECT r.month, r.score, r.content
FROM reviews r
JOIN review_categories c ON r.reviewId = c.reviewId
WHERE r.app_name = 'YNAB'
  AND c.category = 'Usability & design'
  AND r.month >= '2026-01'
ORDER BY RANDOM()
LIMIT 10;


-- Verification: random sample of Rocket Money account/login reviews from 2026
SELECT r.month, r.score, r.content
FROM reviews r
JOIN review_categories c ON r.reviewId = c.reviewId
WHERE r.app_name = 'Rocket Money'
  AND c.category = 'Account, login & support'
  AND r.month >= '2026-01'
ORDER BY RANDOM()
LIMIT 10;