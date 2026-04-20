-- ============================================
-- CONVERSION RATES PER VARIANT
-- Experiment 1: Landing Page Test (ab_test_events)
-- Experiment 2: Ad Exposure Test (ad_exposure)
-- ============================================

-- ----------------------------------------
-- EXPERIMENT 1: Landing Page Test
-- Control (old page) vs Treatment (new page)
-- ----------------------------------------
WITH experiment_1 AS (
    SELECT
        variant_group,
        COUNT(*)                                    AS total_users,
        SUM(converted)                              AS total_conversions,
        ROUND(AVG(converted::NUMERIC) * 100, 4)    AS conversion_rate_pct
    FROM ab_test_events
    WHERE experiment_id = 1
    GROUP BY variant_group
),
experiment_1_totals AS (
    SELECT
        variant_group,
        total_users,
        total_conversions,
        conversion_rate_pct,
        SUM(total_users) OVER ()                    AS overall_users,
        ROUND(
            total_users * 100.0 / SUM(total_users) OVER (), 2
        )                                           AS pct_of_traffic
    FROM experiment_1
)
SELECT
    'Landing Page Test'     AS experiment,
    variant_group           AS variant,
    total_users,
    total_conversions,
    conversion_rate_pct     AS conversion_rate_pct,
    pct_of_traffic          AS traffic_split_pct
FROM experiment_1_totals
ORDER BY variant_group;


-- ----------------------------------------
-- EXPERIMENT 2: Ad Exposure Test
-- Ad group vs PSA group
-- ----------------------------------------
WITH experiment_2 AS (
    SELECT
        test_group,
        COUNT(*)                                    AS total_users,
        SUM(converted)                              AS total_conversions,
        ROUND(AVG(converted::NUMERIC) * 100, 4)    AS conversion_rate_pct
    FROM ad_exposure
    WHERE experiment_id = 2
    GROUP BY test_group
),
experiment_2_totals AS (
    SELECT
        test_group,
        total_users,
        total_conversions,
        conversion_rate_pct,
        SUM(total_users) OVER ()                    AS overall_users,
        ROUND(
            total_users * 100.0 / SUM(total_users) OVER (), 2
        )                                           AS pct_of_traffic
    FROM experiment_2
)
SELECT
    'Ad Exposure Test'      AS experiment,
    test_group              AS variant,
    total_users,
    total_conversions,
    conversion_rate_pct     AS conversion_rate_pct,
    pct_of_traffic          AS traffic_split_pct
FROM experiment_2_totals
ORDER BY test_group;