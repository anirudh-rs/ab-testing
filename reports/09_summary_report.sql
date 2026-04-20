-- ============================================
-- FINAL SUMMARY REPORT
-- Combines all analysis into one executive view
-- Flags winners, losers, and inconclusive tests
-- ============================================


-- ----------------------------------------
-- SECTION 1: EXPERIMENT OVERVIEW
-- ----------------------------------------
SELECT
    '== EXPERIMENT OVERVIEW =='              AS report_section,
    e.experiment_id,
    e.experiment_name,
    e.description,
    e.start_date,
    e.end_date,
    e.status,
    CASE experiment_id
        WHEN 1 THEN (SELECT COUNT(*) FROM ab_test_events)
        WHEN 2 THEN (SELECT COUNT(*) FROM ad_exposure)
    END                                      AS total_users
FROM experiments e
ORDER BY e.experiment_id;


-- ----------------------------------------
-- SECTION 2: CONVERSION RATE SUMMARY
-- ----------------------------------------
WITH exp1 AS (
    SELECT
        1                                    AS experiment_id,
        'Landing Page Test'                  AS experiment_name,
        variant_group                        AS variant,
        COUNT(*)                             AS total_users,
        SUM(converted)                       AS total_conversions,
        ROUND(AVG(converted::NUMERIC)*100,4) AS conversion_rate_pct
    FROM ab_test_events
    GROUP BY variant_group
),
exp2 AS (
    SELECT
        2                                    AS experiment_id,
        'Ad Exposure Test'                   AS experiment_name,
        test_group                           AS variant,
        COUNT(*)                             AS total_users,
        SUM(converted)                       AS total_conversions,
        ROUND(AVG(converted::NUMERIC)*100,4) AS conversion_rate_pct
    FROM ad_exposure
    GROUP BY test_group
)
SELECT
    '== CONVERSION RATES =='                 AS report_section,
    experiment_id,
    experiment_name,
    variant,
    total_users,
    total_conversions,
    conversion_rate_pct
FROM exp1
UNION ALL
SELECT
    '== CONVERSION RATES ==',
    experiment_id,
    experiment_name,
    variant,
    total_users,
    total_conversions,
    conversion_rate_pct
FROM exp2
ORDER BY experiment_id, variant;


-- ----------------------------------------
-- SECTION 3: STATISTICAL SIGNIFICANCE
-- ----------------------------------------
WITH exp1_stats AS (
    SELECT
        variant_group,
        COUNT(*)                             AS n,
        AVG(converted::NUMERIC)              AS p,
        SUM(converted)                       AS conversions
    FROM ab_test_events
    GROUP BY variant_group
),
exp1_control    AS (SELECT * FROM exp1_stats WHERE variant_group = 'control'),
exp1_treatment  AS (SELECT * FROM exp1_stats WHERE variant_group = 'treatment'),
exp1_calc AS (
    SELECT
        1                                    AS experiment_id,
        'Landing Page Test'                  AS experiment_name,
        ROUND(c.p * 100, 4)                  AS control_rate,
        ROUND(t.p * 100, 4)                  AS treatment_rate,
        ROUND((c.p - t.p) * 100, 4)          AS difference_pct,
        ROUND(
            ((c.p - t.p) / NULLIF(SQRT(
                ((c.conversions + t.conversions)::NUMERIC / (c.n + t.n)) *
                (1 - (c.conversions + t.conversions)::NUMERIC / (c.n + t.n)) *
                (1.0/c.n + 1.0/t.n)
            ), 0))::NUMERIC, 4)              AS z_score,
        ABS((c.p - t.p) / NULLIF(SQRT(
            ((c.conversions + t.conversions)::NUMERIC / (c.n + t.n)) *
            (1 - (c.conversions + t.conversions)::NUMERIC / (c.n + t.n)) *
            (1.0/c.n + 1.0/t.n)
        ), 0)) > 1.96                        AS is_significant
    FROM exp1_control c, exp1_treatment t
),
exp2_stats AS (
    SELECT
        test_group,
        COUNT(*)                             AS n,
        AVG(converted::NUMERIC)              AS p,
        SUM(converted)                       AS conversions
    FROM ad_exposure
    GROUP BY test_group
),
exp2_ad     AS (SELECT * FROM exp2_stats WHERE test_group = 'ad'),
exp2_psa    AS (SELECT * FROM exp2_stats WHERE test_group = 'psa'),
exp2_calc AS (
    SELECT
        2                                    AS experiment_id,
        'Ad Exposure Test'                   AS experiment_name,
        ROUND(a.p * 100, 4)                  AS control_rate,
        ROUND(p.p * 100, 4)                  AS treatment_rate,
        ROUND((a.p - p.p) * 100, 4)          AS difference_pct,
        ROUND(
            ((a.p - p.p) / NULLIF(SQRT(
                ((a.conversions + p.conversions)::NUMERIC / (a.n + p.n)) *
                (1 - (a.conversions + p.conversions)::NUMERIC / (a.n + p.n)) *
                (1.0/a.n + 1.0/p.n)
            ), 0))::NUMERIC, 4)              AS z_score,
        ABS((a.p - p.p) / NULLIF(SQRT(
            ((a.conversions + p.conversions)::NUMERIC / (a.n + p.n)) *
            (1 - (a.conversions + p.conversions)::NUMERIC / (a.n + p.n)) *
            (1.0/a.n + 1.0/p.n)
        ), 0)) > 1.96                        AS is_significant
    FROM exp2_ad a, exp2_psa p
)
SELECT
    '== SIGNIFICANCE TESTS =='               AS report_section,
    experiment_id,
    experiment_name,
    control_rate,
    treatment_rate,
    difference_pct,
    z_score,
    is_significant,
    CASE
        WHEN NOT is_significant
            THEN '❌ INCONCLUSIVE — Do not ship'
        WHEN is_significant AND difference_pct > 0
            THEN '✅ VARIANT 1 WINS — Consider shipping'
        WHEN is_significant AND difference_pct < 0
            THEN '✅ VARIANT 2 WINS — Consider shipping'
    END                                      AS recommendation
FROM exp1_calc
UNION ALL
SELECT
    '== SIGNIFICANCE TESTS ==',
    experiment_id,
    experiment_name,
    control_rate,
    treatment_rate,
    difference_pct,
    z_score,
    is_significant,
    CASE
        WHEN NOT is_significant
            THEN '❌ INCONCLUSIVE — Do not ship'
        WHEN is_significant AND difference_pct > 0
            THEN '✅ VARIANT 1 WINS — Consider shipping'
        WHEN is_significant AND difference_pct < 0
            THEN '✅ VARIANT 2 WINS — Consider shipping'
    END
FROM exp2_calc
ORDER BY experiment_id;


-- ----------------------------------------
-- SECTION 4: CONFIDENCE INTERVALS
-- ----------------------------------------
WITH exp1_ci AS (
    SELECT
        1                                    AS experiment_id,
        'Landing Page Test'                  AS experiment_name,
        variant_group                        AS variant,
        COUNT(*)                             AS n,
        AVG(converted::NUMERIC)              AS p
    FROM ab_test_events
    GROUP BY variant_group
),
exp2_ci AS (
    SELECT
        2                                    AS experiment_id,
        'Ad Exposure Test'                   AS experiment_name,
        test_group                           AS variant,
        COUNT(*)                             AS n,
        AVG(converted::NUMERIC)              AS p
    FROM ad_exposure
    GROUP BY test_group
),
all_ci AS (
    SELECT * FROM exp1_ci
    UNION ALL
    SELECT * FROM exp2_ci
)
SELECT
    '== CONFIDENCE INTERVALS =='             AS report_section,
    experiment_id,
    experiment_name,
    variant,
    ROUND(p * 100, 4)                        AS conversion_rate_pct,
    ROUND((p - 1.96 * SQRT(p*(1-p)/n))
        * 100, 4)                            AS ci_lower_pct,
    ROUND((p + 1.96 * SQRT(p*(1-p)/n))
        * 100, 4)                            AS ci_upper_pct
FROM all_ci
ORDER BY experiment_id, variant;


-- ----------------------------------------
-- SECTION 5: KEY INSIGHTS SUMMARY
-- ----------------------------------------
SELECT '== KEY INSIGHTS =='                  AS report_section,
1                                            AS insight_id,
'Landing Page Test: No significant difference detected (z=1.24, p=0.39). 
The new landing page does not outperform the old page. 
Recommendation: Do NOT roll out the new page.'  AS insight;

SELECT '== KEY INSIGHTS =='                  AS report_section,
2                                            AS insight_id,
'Ad Exposure Test: Highly significant result (z=7.37, p≈0.00). 
Ad group converts at 2.55% vs PSA at 1.79% — a 43% relative uplift. 
Recommendation: Continue running ads over PSA.'  AS insight;

SELECT '== KEY INSIGHTS =='                  AS report_section,
3                                            AS insight_id,
'Ad Frequency Finding: Conversion rate scales with ad exposure. 
100+ ads = 17.14% conversion vs 1-10 ads = 0.33%. 
Recommendation: Prioritise high-frequency retargeting for engaged users.' AS insight;

SELECT '== KEY INSIGHTS =='                  AS report_section,
4                                            AS insight_id,
'Data Quality Finding: 3,893 users (1.3%) received mismatched page assignments. 
Control users shown new page: 1,928. Treatment users shown old page: 1,965. 
Recommendation: Flag to engineering for future test integrity.' AS insight;

SELECT '== KEY INSIGHTS =='                  AS report_section,
5                                            AS insight_id,
'Timing Finding: Monday and Tuesday show highest conversion rates (3.32%, 3.04%). 
Peak conversion hours are 2pm-4pm across both groups. 
Recommendation: Concentrate ad spend Monday-Tuesday afternoons.' AS insight;