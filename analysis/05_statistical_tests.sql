-- ============================================
-- STATISTICAL SIGNIFICANCE TESTING
-- Z-scores and P-values for both experiments
-- 
-- Formula:
-- p1, p2 = conversion rates per variant
-- n1, n2 = user counts per variant
-- pooled_p = combined conversion rate
-- standard_error = SQRT(pooled_p * (1 - pooled_p) * (1/n1 + 1/n2))
-- z_score = (p1 - p2) / standard_error
-- p_value approximated via normal distribution
-- Significance threshold: z > 1.96 (95% confidence)
-- ============================================


-- ----------------------------------------
-- EXPERIMENT 1: Landing Page Test
-- ----------------------------------------
WITH variant_stats AS (
    SELECT
        variant_group,
        COUNT(*)                        AS n,
        SUM(converted)                  AS conversions,
        AVG(converted::NUMERIC)         AS p
    FROM ab_test_events
    WHERE experiment_id = 1
    GROUP BY variant_group
),
control AS (
    SELECT n, conversions, p FROM variant_stats WHERE variant_group = 'control'
),
treatment AS (
    SELECT n, conversions, p FROM variant_stats WHERE variant_group = 'treatment'
),
pooled AS (
    SELECT
        (c.conversions + t.conversions)::NUMERIC
        / (c.n + t.n)                   AS pooled_p,
        c.n                             AS n_control,
        t.n                             AS n_treatment,
        c.p                             AS p_control,
        t.p                             AS p_treatment
    FROM control c, treatment t
),
z_calc AS (
    SELECT
        p_control,
        p_treatment,
        n_control,
        n_treatment,
        pooled_p,
        -- Standard error
        SQRT(
            pooled_p * (1 - pooled_p) * (1.0/n_control + 1.0/n_treatment)
        )                               AS standard_error,
        -- Z-score
        (p_control - p_treatment) /
        NULLIF(
            SQRT(
                pooled_p * (1 - pooled_p) * (1.0/n_control + 1.0/n_treatment)
            ), 0
        )                               AS z_score
    FROM pooled
)
SELECT
    'Landing Page Test'                             AS experiment,
    ROUND(p_control * 100, 4)                       AS control_rate_pct,
    ROUND(p_treatment * 100, 4)                     AS treatment_rate_pct,
    ROUND((p_control - p_treatment) * 100, 4)       AS difference_pct,
    ROUND(standard_error::NUMERIC, 8)               AS standard_error,
    ROUND(z_score::NUMERIC, 4)                      AS z_score,
    -- Two-tailed p-value approximation
    ROUND(
        2 * (1 - (
            0.5 * (1 + SIGN(z_score) * (
                1 - EXP(-0.7178 * ABS(z_score) *
                    (1 + 0.044715 * POWER(z_score, 2))
                )
            ))
        ))::NUMERIC, 4
    )                                               AS p_value_approx,
    ABS(z_score) > 1.96                             AS is_significant,
    CASE
        WHEN ABS(z_score) > 1.96 AND p_control > p_treatment
            THEN 'Control Wins'
        WHEN ABS(z_score) > 1.96 AND p_treatment > p_control
            THEN 'Treatment Wins'
        ELSE 'No Significant Difference'
    END                                             AS verdict
FROM z_calc;


-- ----------------------------------------
-- EXPERIMENT 2: Ad Exposure Test
-- ----------------------------------------
WITH variant_stats AS (
    SELECT
        test_group,
        COUNT(*)                        AS n,
        SUM(converted)                  AS conversions,
        AVG(converted::NUMERIC)         AS p
    FROM ad_exposure
    WHERE experiment_id = 2
    GROUP BY test_group
),
ad AS (
    SELECT n, conversions, p FROM variant_stats WHERE test_group = 'ad'
),
psa AS (
    SELECT n, conversions, p FROM variant_stats WHERE test_group = 'psa'
),
pooled AS (
    SELECT
        (a.conversions + p.conversions)::NUMERIC
        / (a.n + p.n)                   AS pooled_p,
        a.n                             AS n_ad,
        p.n                             AS n_psa,
        a.p                             AS p_ad,
        p.p                             AS p_psa
    FROM ad a, psa p
),
z_calc AS (
    SELECT
        p_ad,
        p_psa,
        n_ad,
        n_psa,
        pooled_p,
        SQRT(
            pooled_p * (1 - pooled_p) * (1.0/n_ad + 1.0/n_psa)
        )                               AS standard_error,
        (p_ad - p_psa) /
        NULLIF(
            SQRT(
                pooled_p * (1 - pooled_p) * (1.0/n_ad + 1.0/n_psa)
            ), 0
        )                               AS z_score
    FROM pooled
)
SELECT
    'Ad Exposure Test'                              AS experiment,
    ROUND(p_ad * 100, 4)                            AS ad_rate_pct,
    ROUND(p_psa * 100, 4)                           AS psa_rate_pct,
    ROUND((p_ad - p_psa) * 100, 4)                  AS difference_pct,
    ROUND(standard_error::NUMERIC, 8)               AS standard_error,
    ROUND(z_score::NUMERIC, 4)                      AS z_score,
    ROUND(
        2 * (1 - (
            0.5 * (1 + SIGN(z_score) * (
                1 - EXP(-0.7178 * ABS(z_score) *
                    (1 + 0.044715 * POWER(z_score, 2))
                )
            ))
        ))::NUMERIC, 4
    )                                               AS p_value_approx,
    ABS(z_score) > 1.96                             AS is_significant,
    CASE
        WHEN ABS(z_score) > 1.96 AND p_ad > p_psa
            THEN 'Ad Group Wins'
        WHEN ABS(z_score) > 1.96 AND p_psa > p_ad
            THEN 'PSA Group Wins'
        ELSE 'No Significant Difference'
    END                                             AS verdict
FROM z_calc;