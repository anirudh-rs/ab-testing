-- ============================================
-- 95% CONFIDENCE INTERVALS PER VARIANT
--
-- Formula:
-- CI = p ± 1.96 * SQRT(p * (1-p) / n)
-- Where:
--   p = conversion rate
--   n = number of users
--   1.96 = z-score for 95% confidence
-- ============================================


-- ----------------------------------------
-- EXPERIMENT 1: Landing Page Test
-- ----------------------------------------
WITH stats AS (
    SELECT
        variant_group                           AS variant,
        COUNT(*)                                AS n,
        AVG(converted::NUMERIC)                 AS p
    FROM ab_test_events
    WHERE experiment_id = 1
    GROUP BY variant_group
),
ci_calc AS (
    SELECT
        variant,
        n,
        p,
        -- Margin of error
        1.96 * SQRT(p * (1 - p) / n)           AS margin_of_error
    FROM stats
)
SELECT
    'Landing Page Test'                         AS experiment,
    variant,
    n                                           AS total_users,
    ROUND(p * 100, 4)                           AS conversion_rate_pct,
    ROUND(margin_of_error * 100, 4)             AS margin_of_error_pct,
    ROUND((p - margin_of_error) * 100, 4)       AS ci_lower_pct,
    ROUND((p + margin_of_error) * 100, 4)       AS ci_upper_pct,
    -- Interval width tells us precision
    ROUND(margin_of_error * 2 * 100, 4)         AS interval_width_pct
FROM ci_calc
ORDER BY variant;


-- ----------------------------------------
-- EXPERIMENT 2: Ad Exposure Test
-- ----------------------------------------
WITH stats AS (
    SELECT
        test_group                              AS variant,
        COUNT(*)                                AS n,
        AVG(converted::NUMERIC)                 AS p
    FROM ad_exposure
    WHERE experiment_id = 2
    GROUP BY test_group
),
ci_calc AS (
    SELECT
        variant,
        n,
        p,
        1.96 * SQRT(p * (1 - p) / n)           AS margin_of_error
    FROM stats
)
SELECT
    'Ad Exposure Test'                          AS experiment,
    variant,
    n                                           AS total_users,
    ROUND(p * 100, 4)                           AS conversion_rate_pct,
    ROUND(margin_of_error * 100, 4)             AS margin_of_error_pct,
    ROUND((p - margin_of_error) * 100, 4)       AS ci_lower_pct,
    ROUND((p + margin_of_error) * 100, 4)       AS ci_upper_pct,
    ROUND(margin_of_error * 2 * 100, 4)         AS interval_width_pct
FROM ci_calc
ORDER BY variant;