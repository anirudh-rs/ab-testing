# A/B Test Results Analysis

A pure SQL analytics framework for analysing A/B test results entirely in PostgreSQL.
Built to replicate the kind of experimentation analysis used by product and data teams
at companies like Netflix, Airbnb, and Booking.com.

---

## Project Overview

This project analyses two real-world A/B experiments using advanced SQL techniques
including z-score significance testing, confidence interval construction, demographic
segmentation, and time-series analysis — all without leaving PostgreSQL.

---

## Key Findings

| Finding | Result |
|---|---|
| Landing Page Test | ❌ Inconclusive (z=1.24, p=0.39) — do not ship |
| Ad Exposure Test | ✅ Ads win with 43% uplift (z=7.37, p≈0.00) |
| Ad Frequency | 100+ ads converts at 52x the rate of 1-10 ads |
| Peak Timing | Monday-Tuesday, 2pm-4pm drives highest conversions |
| Data Quality | 1.3% of users received mismatched page assignments |
| Test Integrity | Perfect 50/50 traffic split across all 23 days |
| Stabilisation | Conversion rates converged within 3 days of test start |

---

## Tech Stack

- **PostgreSQL** — all data storage, querying, and statistical analysis
- **pgAdmin** — database management and query execution
- **Python** — CSV data loading only (psycopg2, pandas)
- **Tableau Public** — results visualisation across 3 dashboards

---

## Dataset

| Dataset | Source | Rows |
|---|---|---|
| `ab_data.csv` | [Kaggle — A/B Testing](https://www.kaggle.com/datasets/zhangluyuan/ab-testing) | 294,478 |
| `marketing_AB.csv` | [Kaggle — Marketing A/B Testing](https://www.kaggle.com/datasets/faviovaz/marketing-ab-testing) | 588,101 |

---

## Project Structure

<pre>
ABTesting/
│
├── data/
│   ├── ab_data.csv
│   ├── marketing_AB.csv
│   └── exports/
│       ├── conversion_rates.csv
│       ├── statistical_summary.csv
│       ├── daily_conversions.csv
│       ├── ad_frequency_tiers.csv
│       └── day_hour_conversions.csv
│
├── schema/
│   ├── 01_create_tables.sql
│   └── 02_create_indexes.sql
│
├── data_load/
│   └── 03_load_data.py
│
├── analysis/
│   ├── 04_conversion_rates.sql
│   ├── 05_statistical_tests.sql
│   ├── 06_confidence_intervals.sql
│   ├── 07_demographic_segments.sql
│   └── 08_time_series.sql
│
├── reports/
│   └── 09_summary_report.sql
│
└── README.md
</pre>

---

## SQL Techniques Used

- **CTEs** to isolate control and treatment groups cleanly
- **Z-score and p-value calculations** using SQL math functions
- **Confidence interval construction** using STDDEV and COUNT
- **Window functions** for running conversion rates over time
- **CASE statements** for variant classification and segmentation
- **DATE_TRUNC** for time-based performance breakdowns
- **Aggregate functions** for conversion rate calculations per variant
- **Subqueries** for demographic segmentation

---

## How to Run This Project

### Prerequisites
- PostgreSQL 15+
- pgAdmin
- Python 3.8+

### Setup

**1. Clone the repository**
```bash
git clone https://github.com/anirudhraghavendra/ABTesting.git
cd ABTesting
```

**2. Install Python dependencies**
```bash
pip install psycopg2-binary pandas
```

**3. Create the database in pgAdmin**
```sql
CREATE DATABASE ab_test_db;
```

**4. Run the schema scripts in pgAdmin**
```
schema/01_create_tables.sql
schema/02_create_indexes.sql
```

**5. Update your credentials in `data_load/03_load_data.py` then run**
```bash
python data_load/03_load_data.py
```

**6. Run the analysis queries in order**
```
analysis/04_conversion_rates.sql
analysis/05_statistical_tests.sql
analysis/06_confidence_intervals.sql
analysis/07_demographic_segments.sql
analysis/08_time_series.sql
reports/09_summary_report.sql
```

---

## Visualisation

Three Tableau Public dashboards built from exported SQL results:

**Dashboard 1 — Experiment Results Summary**
- Conversion rates per variant across both experiments
- Z-score significance testing with 1.96 threshold reference line
- 95% confidence intervals with overlap detection

[View Dashboard 1](https://public.tableau.com/app/profile/anirudh.raghavendra/viz/ABTesting1_17771333267360/ExperimentsResultsSummary)

**Dashboard 2 — Ad Exposure Analysis**
- Conversion rate by ad frequency tier (0 to 100+ ads)
- Hourly conversion trend for ad vs PSA group
- Day and hour heatmap showing peak conversion windows

[View Dashboard 2](https://public.tableau.com/app/profile/anirudh.raghavendra/viz/ABTesting2_17771333874980/AdExposureAnalysis)

**Dashboard 3 — Test Integrity & Time Series**
- Daily conversion rates over the full 23-day test period
- Running conversion rates confirming test stabilisation by day 3

[View Dashboard 3](https://public.tableau.com/app/profile/anirudh.raghavendra/viz/ABTesting3/TestIntegrityTimeSeries)
