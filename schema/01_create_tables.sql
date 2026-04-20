-- ============================================
-- TABLE 1: Experiment Registry
-- Stores metadata about each test we run
-- ============================================
CREATE TABLE IF NOT EXISTS experiments (
    experiment_id     SERIAL PRIMARY KEY,
    experiment_name   VARCHAR(100) NOT NULL,
    description       TEXT,
    start_date        DATE,
    end_date          DATE,
    status            VARCHAR(20) DEFAULT 'active',
    created_at        TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================
-- TABLE 2: Core A/B Test Events
-- Fed by ab_data.csv
-- ============================================
CREATE TABLE IF NOT EXISTS ab_test_events (
    event_id          SERIAL PRIMARY KEY,
    user_id           INTEGER NOT NULL,
    event_timestamp   TIMESTAMP,
    variant_group     VARCHAR(20),      -- 'control' or 'treatment'
    landing_page      VARCHAR(50),      -- which page they saw
    converted         SMALLINT,         -- 0 or 1
    experiment_id     INTEGER REFERENCES experiments(experiment_id)
);

-- ============================================
-- TABLE 3: Ad Exposure Data
-- Fed by marketing_AB.csv
-- ============================================
CREATE TABLE IF NOT EXISTS ad_exposure (
    exposure_id       SERIAL PRIMARY KEY,
    user_id           INTEGER NOT NULL,
    test_group        VARCHAR(10),      -- 'ad' or 'psa'
    converted         SMALLINT,         -- 0 or 1
    total_ads         INTEGER,          -- total ads shown to user
    most_ads_day      VARCHAR(15),      -- day of week with most ad exposure
    most_ads_hour     INTEGER,          -- hour of day with most ad exposure
    experiment_id     INTEGER REFERENCES experiments(experiment_id)
);

-- ============================================
-- TABLE 4: Analysis Summary
-- Populated by our SQL queries, stores results
-- ============================================
CREATE TABLE IF NOT EXISTS analysis_summary (
    summary_id        SERIAL PRIMARY KEY,
    experiment_id     INTEGER REFERENCES experiments(experiment_id),
    variant           VARCHAR(20),
    total_users       INTEGER,
    total_conversions INTEGER,
    conversion_rate   NUMERIC(8,6),
    z_score           NUMERIC(10,6),
    p_value           NUMERIC(10,6),
    ci_lower          NUMERIC(8,6),
    ci_upper          NUMERIC(8,6),
    is_significant    BOOLEAN,
    winner            VARCHAR(20),
    calculated_at     TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);