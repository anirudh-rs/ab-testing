import psycopg2
import pandas as pd
from psycopg2.extras import execute_values
import os

# ============================================
# DATABASE CONNECTION
# ============================================
conn = psycopg2.connect(
    host="localhost",
    port=5432,
    database="ab_test_db",
    user="postgres",
    password="anirudhrs123"    # update this
)
cursor = conn.cursor()
print("✓ Connected to ab_test_db")

# ============================================
# LOAD ab_data.csv → ab_test_events
# ============================================
print("\nLoading ab_data.csv...")

ab_path = os.path.join("..", "data", "ab_data.csv")
ab_df = pd.read_csv(ab_path)

# Clean column names
ab_df.columns = ab_df.columns.str.strip().str.lower().str.replace(" ", "_")

print(f"  Columns found: {list(ab_df.columns)}")
print(f"  Rows to load:  {len(ab_df):,}")

# Prepare rows
ab_rows = [
    (
        int(row["user_id"]),
        row["timestamp"],
        row["group"],
        row["landing_page"],
        int(row["converted"]),
        1   # experiment_id 1 = Landing Page Test
    )
    for _, row in ab_df.iterrows()
]

execute_values(cursor, """
    INSERT INTO ab_test_events 
        (user_id, event_timestamp, variant_group, landing_page, converted, experiment_id)
    VALUES %s
""", ab_rows)

print(f"  ✓ {len(ab_rows):,} rows inserted into ab_test_events")

# ============================================
# LOAD marketing_AB.csv → ad_exposure
# ============================================
print("\nLoading marketing_AB.csv...")

mkt_path = os.path.join("..", "data", "marketing_AB.csv")
mkt_df = pd.read_csv(mkt_path)

# Drop the blank index column
mkt_df = mkt_df.iloc[:, 1:]

# Clean column names
mkt_df.columns = (
    mkt_df.columns
    .str.strip()
    .str.lower()
    .str.replace(" ", "_")
)

print(f"  Columns found: {list(mkt_df.columns)}")
print(f"  Rows to load:  {len(mkt_df):,}")

# Prepare rows
mkt_rows = [
    (
        int(row["user_id"]),
        row["test_group"],
        int(row["converted"]),
        int(row["total_ads"]),
        row["most_ads_day"],
        int(row["most_ads_hour"]),
        2   # experiment_id 2 = Ad Exposure Test
    )
    for _, row in mkt_df.iterrows()
]

execute_values(cursor, """
    INSERT INTO ad_exposure
        (user_id, test_group, converted, total_ads, most_ads_day, most_ads_hour, experiment_id)
    VALUES %s
""", mkt_rows)

print(f"  ✓ {len(mkt_rows):,} rows inserted into ad_exposure")

# ============================================
# COMMIT AND CLOSE
# ============================================
conn.commit()
cursor.close()
conn.close()
print("\n✓ All data loaded and committed successfully")