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

| Experiment | Result | Verdict |
|---|---|---|
| Landing Page Test | Z=1.24, P=0.39 | ❌ No significant difference — do not ship |
| Ad Exposure Test | Z=7.37, P≈0.00 | ✅ Ads win — 43% relative uplift over PSA |

**Additional insights:**
- Users shown 100+ ads convert at **17.14%** vs **0.33%** for 1-10 ads — a 52x difference
- Peak conversion times are **Monday-Tuesday, 2pm-4pm**
- **1.3% of users** received mismatched page assignments — flagged as a data quality issue
- Traffic split held at a perfect **50/50** every single day of the test

---

## Tech Stack

- **PostgreSQL** — all data storage, querying, and statistical analysis
- **pgAdmin** — database management and query execution
- **Python** — CSV data loading only (psycopg2, pandas)
- **Tableau Public** — results visualisation

---

## Dataset

| Dataset | Source | Rows |
|---|---|---|
| `ab_data.csv` | [Kaggle — A/B Testing](https://www.kaggle.com/datasets/zhangluyuan/ab-testing) | 294,478 |
| `marketing_AB.csv` | [Kaggle — Marketing A/B Testing](https://www.kaggle.com/datasets/faviovaz/marketing-ab-testing) | 588,101 |

---

## Project Structure
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

1. Clone the repository
```bash
   git clone https://github.com/YOUR_USERNAME/ABTesting.git
   cd ABTesting
```

2. Install Python dependencies
```bash
   pip install psycopg2-binary pandas
```

3. Create the database in pgAdmin
```sql
   CREATE DATABASE ab_test_db;
```

4. Run the schema scripts in pgAdmin
schema/01_create_tables.sql
schema/02_create_indexes.sql

5. Update your credentials in `data_load/03_load_data.py` then run
```bash
   python data_load/03_load_data.py
```

6. Run the analysis queries in order
analysis/04_conversion_rates.sql
analysis/05_statistical_tests.sql
analysis/06_confidence_intervals.sql
analysis/07_demographic_segments.sql
analysis/08_time_series.sql
reports/09_summary_report.sql

---

## Visualisation

Interactive Tableau Public dashboard:
[View Dashboard](YOUR_TABLEAU_PUBLIC_URL)

---

## Author

**YOUR NAME**  
[LinkedIn](https://linkedin.com/in/YOUR_PROFILE) | [GitHub](https://github.com/YOUR_USERNAME)