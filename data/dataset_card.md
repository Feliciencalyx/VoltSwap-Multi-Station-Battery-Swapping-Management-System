# Dataset Card: EMBSCS 34-Station Electric Motorcycle Battery Swapping Dataset

## 1. Dataset Overview

* **Dataset Name:** Electric Motorcycle Battery Swapping and Charging Stations (EMBSCS) Empirical Telemetry Dataset
* **Raw Files Storage:** `data/raw/embscs-dataset-main/` (Preserved raw and unedited, containing 9 CSV files and 14 Excel workbooks)
* **Format:** Semicolon-delimited `.csv` (PI metrics) and OpenXML `.xlsx` (VDF/VEF indices)
* **Total Scope:**
  * **34 Commercial Swapping Stations** (`BS007` through `BS290`)
  * **92 Consecutive Calendar Days** (October 1 – December 31, 2023)
  * **3,128 Station-Day Observations** per Performance Indicator category
  * **9,384 Total Performance Metric Observations** across the three CSV series
  * **144,389 Total Battery Swap Transactions** recorded across the 34-station network
* **Source / Platform:** Published Open Access Academic Research Repository on Electric Motorcycle Battery Swapping Vulnerability & Performance Indicators (EMBSCS).
* **Licence:** Creative Commons Attribution 4.0 International (CC BY 4.0) — Permitted for academic research and database engineering evaluation.

---

## 2. What One Record Represents

The dataset contains two complementary operational representations:
1. **Daily Operational Observation (Station-Day Record):**
   Each record in `PI_1`, `PI_2`, and `PI_3` represents the aggregate 24-hour activity of a specific battery swapping station on a given calendar date:
   * `swap_throughput`: Number of battery swaps completed on that date.
   * `unique_batteries`: Count of distinct physical battery packs processed through that station.
   * `customers_served`: Count of distinct motorcycle riders who performed swaps.
2. **Station Infrastructure & Vulnerability Metrics:**
   Each station profile in the `VDF` and `VEF` series represents physical hardware and environmental factors:
   * `active_compartments`: Total active charging bays/doors per cabinet (6 to 9 compartments, `VDF9`).
   * `distance_to_hub`: Physical road distance in meters to the primary metropolitan logistics depot (`VDF8`).
   * `avg_soc_swapping`: Typical remaining battery charge upon intake (11% to 16% SoC, `VDF1`).
   * `swap_completion_time`: Average duration in minutes to complete a swap (1.2 to 1.5 minutes, `VDF4`).
   * `operational_disruptions`: Grid outage and equipment disruption counts (`VEF1`).
   * `vulnerability_score`: Composite vulnerability index ($0.000$ to $1.000$, `Table D.1`).

---

## 3. Raw Data Files Inventory

| File Series | Files Included | Metrics Captured | Dimensions |
| :--- | :--- | :--- | :--- |
| **`PI_1_Throughput`** | Oct, Nov, Dec 2023 (3 CSVs) | Daily swap transactions completed per station | 92 days $\times$ 34 stations |
| **`PI_2_Unique_batteries`**| Oct, Nov, Dec 2023 (3 CSVs) | Unique physical battery packs exchanged | 92 days $\times$ 34 stations |
| **`PI_3_Battery_customers`**| Oct, Nov, Dec 2023 (3 CSVs) | Unique riders served per station per day | 92 days $\times$ 34 stations |
| **`VDF1_SOC_Swapping`** | Excel workbook | Monthly average battery State of Charge at arrival | 34 stations $\times$ 3 months |
| **`VDF4_Swap_completion`** | Excel workbook | Average swap completion time in minutes | 34 stations $\times$ 3 months |
| **`VDF8_Distance_stations`**| Excel workbook | Road distance in meters between stations and hub | 34 station rows |
| **`VDF9_Activated_compart`**| Excel workbook | Active charging bays/doors per swapping cabinet | 34 station rows |
| **`VEF1_Disruptions`** | Excel workbook | Monthly station operational disruptions/outages | 34 stations $\times$ 3 months |
| **`Table D.1_Vulnerability`**| Excel workbook | Multi-factor station vulnerability index scores | 34 stations $\times$ 3 months |

---

## 4. Raw Data Quality Audit (Baseline Inspection)

> **IMPORTANT:** In strict compliance with Phase II guidelines, **no raw file has been modified in `data/raw/`**. All quality findings below are documented as the Phase IV ETL cleaning and transformation checklist:

| Quality Characteristic | Exact Count / Finding | Impact & Observation | Phase IV ETL Transformation |
| :--- | :---: | :--- | :--- |
| **Denormalized Wide Matrix Layout** | **34 column repeating groups** | Each CSV row contains 34 separate station columns for each single date (violates 1NF). | Unpivot (melt) the 34 station columns into 3,128 atomic relational rows: `(station_id, operation_date, throughput)`. |
| **Non-Standard CSV Delimiter** | **9 CSV files** | Fields are delimited by semicolons (`;`) rather than standard commas. | Configured Python CSV reader and Oracle external tables with `DELIMITER ';'` parameter. |
| **Decimal Representation for Counts** | **9,384 data cells** | Integer counts are stored as floating point strings (e.g. `19.0`, `44.0`, `3.0`). | Cast floats to `int` and insert as Oracle `NUMBER(5)` integer columns. |
| **Embedded Formula Strings in Excel** | **14 workbooks** | Scaled columns contain raw Excel formula text (e.g. `=(B$38-B2)/(B$38-D$37)`). | Extracted raw metric values from data columns (`B`, `C`, `D`) rather than dependent formula columns. |
| **Station Code Header Variations** | **34 headers** | Stations represented as alphanumeric codes (`BS007`..`BS290`) without descriptive names. | Mapped station codes to primary key `station_id` and assigned canonical names (`VoltSwap Station BS007`). |
| **Null / Zero Charging Duration** | **2 stations in Nov/Dec** | Station `BS016` has 0 recorded charging duration in November/December due to depot battery rotation. | Handled via `NVL` / default fallback to network average charging duration (28.4 minutes). |
