-- Speeds up queries filtering by variant group
CREATE INDEX IF NOT EXISTS idx_ab_variant 
ON ab_test_events(variant_group);

-- Speeds up conversion lookups
CREATE INDEX IF NOT EXISTS idx_ab_converted 
ON ab_test_events(converted);

-- Speeds up timestamp-based queries
CREATE INDEX IF NOT EXISTS idx_ab_timestamp 
ON ab_test_events(event_timestamp);

-- Speeds up ad group filtering
CREATE INDEX IF NOT EXISTS idx_ad_group 
ON ad_exposure(test_group);

-- Speeds up ad conversion lookups
CREATE INDEX IF NOT EXISTS idx_ad_converted 
ON ad_exposure(converted);