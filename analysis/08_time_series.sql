-- ============================================
-- TIME SERIES ANALYSIS
-- Running conversion rates over time
-- Experiment 1 only (has timestamp data)
-- ============================================


-- ----------------------------------------
-- DAILY CONVERSION RATES PER VARIANT
-- How did each variant perform day by day?
-- ----------------------------------------
WITH daily_stats AS (
    SELECT
        DATE_TRUNC('day', event_timestamp)      AS event_date,
        variant_group,
        COUNT(*)                                AS daily_users,
        SUM(converted)                          AS daily_conversions,
        ROUND(AVG(converted::NUMERIC) * 100, 4) AS daily_conversion_rate
    FROM ab_test_events
    WHERE experiment_id = 1
    GROUP BY DATE_TRUNC('day', event_timestamp), variant_group
)
SELECT
    event_date,
    variant_group,
    daily_users,
    daily_conversions,
    daily_conversion_rate,
    -- Running totals using window functions
    SUM(daily_users) OVER (
        PARTITION BY variant_group
        ORDER BY event_date
        ROWS UNBOUNDED PRECEDING
    )                                           AS running_total_users,
    SUM(daily_conversions) OVER (
        PARTITION BY variant_group
        ORDER BY event_date
        ROWS UNBOUNDED PRECEDING
    )                                           AS running_total_conversions,
    -- Running conversion rate
    ROUND(
        SUM(daily_conversions) OVER (
            PARTITION BY variant_group
            ORDER BY event_date
            ROWS UNBOUNDED PRECEDING
        ) * 100.0 /
        NULLIF(SUM(daily_users) OVER (
            PARTITION BY variant_group
            ORDER BY event_date
            ROWS UNBOUNDED PRECEDING
        ), 0)
    , 4)                                        AS running_conversion_rate
FROM daily_stats
ORDER BY event_date, variant_group;


-- ----------------------------------------
-- WEEKLY ROLLUP PER VARIANT
-- Smooths out daily noise
-- ----------------------------------------
WITH weekly_stats AS (
    SELECT
        DATE_TRUNC('week', event_timestamp)     AS week_start,
        variant_group,
        COUNT(*)                                AS weekly_users,
        SUM(converted)                          AS weekly_conversions,
        ROUND(AVG(converted::NUMERIC) * 100, 4) AS weekly_conversion_rate
    FROM ab_test_events
    WHERE experiment_id = 1
    GROUP BY DATE_TRUNC('week', event_timestamp), variant_group
)
SELECT
    week_start,
    variant_group,
    weekly_users,
    weekly_conversions,
    weekly_conversion_rate,
    -- Week over week change
    ROUND(
        weekly_conversion_rate - LAG(weekly_conversion_rate) OVER (
            PARTITION BY variant_group
            ORDER BY week_start
        )
    , 4)                                        AS wow_change_pct
FROM weekly_stats
ORDER BY week_start, variant_group;


-- ----------------------------------------
-- DAILY VOLUME CHECK
-- Were users added consistently each day?
-- Detects any suspicious spikes or gaps
-- ----------------------------------------
SELECT
    DATE_TRUNC('day', event_timestamp)          AS event_date,
    COUNT(*)                                    AS total_users,
    SUM(CASE WHEN variant_group = 'control'
        THEN 1 ELSE 0 END)                      AS control_users,
    SUM(CASE WHEN variant_group = 'treatment'
        THEN 1 ELSE 0 END)                      AS treatment_users,
    ROUND(
        SUM(CASE WHEN variant_group = 'control'
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                           AS control_pct,
    ROUND(
        SUM(CASE WHEN variant_group = 'treatment'
            THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 2
    )                                           AS treatment_pct
FROM ab_test_events
WHERE experiment_id = 1
GROUP BY DATE_TRUNC('day', event_timestamp)
ORDER BY event_date;