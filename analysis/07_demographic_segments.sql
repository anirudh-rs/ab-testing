-- ============================================
-- SEGMENTED ANALYSIS
-- Experiment 1: Breakdown by landing page type
-- Experiment 2: Breakdown by ad frequency,
--               day of week, and hour of day
-- ============================================


-- ----------------------------------------
-- EXPERIMENT 1: Conversion by Page Type
-- Does page type align with variant group?
-- ----------------------------------------
SELECT
    'Landing Page Test'                         AS experiment,
    variant_group,
    landing_page,
    COUNT(*)                                    AS total_users,
    SUM(converted)                              AS conversions,
    ROUND(AVG(converted::NUMERIC) * 100, 4)     AS conversion_rate_pct,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (PARTITION BY variant_group), 2
    )                                           AS pct_of_variant
FROM ab_test_events
WHERE experiment_id = 1
GROUP BY variant_group, landing_page
ORDER BY variant_group, landing_page;


-- ----------------------------------------
-- EXPERIMENT 1: Mismatched Assignments
-- Users who got the wrong page for their group
-- This is a data quality check
-- ----------------------------------------
SELECT
    'Data Quality Check'                        AS check_type,
    variant_group,
    landing_page,
    COUNT(*)                                    AS mismatched_users,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM ab_test_events
WHERE experiment_id = 1
  AND (
      (variant_group = 'control'   AND landing_page = 'new_page') OR
      (variant_group = 'treatment' AND landing_page = 'old_page')
  )
GROUP BY variant_group, landing_page
ORDER BY variant_group;


-- ----------------------------------------
-- EXPERIMENT 2: Conversion by Ad Frequency
-- Bucketed into exposure tiers
-- ----------------------------------------
WITH frequency_buckets AS (
    SELECT
        user_id,
        test_group,
        converted,
        total_ads,
        CASE
            WHEN total_ads = 0          THEN '0 ads'
            WHEN total_ads BETWEEN 1 AND 10   THEN '01-10 ads'
            WHEN total_ads BETWEEN 11 AND 50  THEN '11-50 ads'
            WHEN total_ads BETWEEN 51 AND 100 THEN '51-100 ads'
            WHEN total_ads > 100        THEN '100+ ads'
        END                                     AS frequency_tier
    FROM ad_exposure
    WHERE experiment_id = 2
      AND test_group = 'ad'
)
SELECT
    'Ad Exposure Test'                          AS experiment,
    frequency_tier,
    COUNT(*)                                    AS total_users,
    SUM(converted)                              AS conversions,
    ROUND(AVG(converted::NUMERIC) * 100, 4)     AS conversion_rate_pct,
    ROUND(AVG(total_ads::NUMERIC), 1)           AS avg_ads_shown
FROM frequency_buckets
GROUP BY frequency_tier
ORDER BY frequency_tier;


-- ----------------------------------------
-- EXPERIMENT 2: Conversion by Day of Week
-- Which days drive the most conversions?
-- ----------------------------------------
SELECT
    'Ad Exposure Test'                          AS experiment,
    test_group,
    most_ads_day                                AS day_of_week,
    COUNT(*)                                    AS total_users,
    SUM(converted)                              AS conversions,
    ROUND(AVG(converted::NUMERIC) * 100, 4)     AS conversion_rate_pct
FROM ad_exposure
WHERE experiment_id = 2
GROUP BY test_group, most_ads_day
ORDER BY test_group,
    CASE most_ads_day
        WHEN 'Monday'    THEN 1
        WHEN 'Tuesday'   THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday'  THEN 4
        WHEN 'Friday'    THEN 5
        WHEN 'Saturday'  THEN 6
        WHEN 'Sunday'    THEN 7
    END;


-- ----------------------------------------
-- EXPERIMENT 2: Conversion by Hour of Day
-- Which hours drive the most conversions?
-- ----------------------------------------
SELECT
    'Ad Exposure Test'                          AS experiment,
    test_group,
    most_ads_hour                               AS hour_of_day,
    COUNT(*)                                    AS total_users,
    SUM(converted)                              AS conversions,
    ROUND(AVG(converted::NUMERIC) * 100, 4)     AS conversion_rate_pct
FROM ad_exposure
WHERE experiment_id = 2
GROUP BY test_group, most_ads_hour
ORDER BY test_group, most_ads_hour;