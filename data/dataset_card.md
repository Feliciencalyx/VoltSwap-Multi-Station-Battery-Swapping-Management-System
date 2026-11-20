# Dataset Card: VoltSwap Battery Swapping Operational Log

## 1. Dataset Overview

* **Dataset Name:** VoltSwap Kigali Multi-Station Swapping Operations Log
* **File Location:** `data/raw/raw_battery_swaps.csv`
* **Format:** Comma-Separated Values (`.csv`), UTF-8 encoded
* **Record Count:** 550 records
* **File Size:** ~72 KB
* **Date Collected:** September – November 2026
* **Collection Method:** Aggregated operational export from multi-station swap terminals across Kigali City.
* **Source / Platform:** Internal operational logs synthesized for academic development (VoltSwap Technologies Ltd.).
* **Licence:** Creative Commons Attribution 4.0 International (CC BY 4.0) — Permitted for academic and educational evaluation.

---

## 2. What One Record Represents

Each row represents an un-normalized, flat operational event where an electric motorcycle rider (customer) arrives at a designated swapping station, returns a depleted lithium battery pack, receives a fully charged battery pack, makes an electronic or cash payment, and has the returned battery inspected by on-duty station attendants.

---

## 3. Data Dictionary (Raw Fields)

| Field Name | Raw Data Type | Example Value | Description |
| :--- | :--- | :--- | :--- |
| `swap_id` | Text | `SWP_10001` | Operational swap transaction code |
| `customer_id` | Text | `CUST_1042` | Anonymized unique customer reference |
| `customer_name` | Text | `Customer_1042` | Anonymized rider name |
| `customer_phone` | Text | `+250788***42` | Masked Rwandan telephone contact |
| `vehicle_plate` | Text | `RAD 142E` | Vehicle registration plate |
| `station_name` | Text | `Kigali Central Hub` | Name of physical swapping station |
| `station_district` | Text | `Nyarugenge` | District location of station (uncleaned) |
| `battery_returned_serial` | Text | `BAT-0185` | Serial number of returned depleted pack |
| `returned_soc_pct` | Integer | `12` | Remaining State of Charge percentage |
| `battery_issued_serial` | Text | `BAT-0412` | Serial number of issued charged pack |
| `issued_soc_pct` | Integer | `98` | State of Charge percentage of issued pack |
| `battery_model` | Text | `VoltCore-48V` | Model name / specification code |
| `model_capacity` | Text | `3.2 kWh` | Total rated battery energy storage |
| `energy_consumed` | Text | `2.75 kWh` | Net energy replenished (uncleaned text) |
| `fee_amount` | Text | `2475 RWF` | Swapping service fee billed (uncleaned text) |
| `payment_method` | Text | `MTN_MOMO` | Channel used (`MTN_MOMO`, `AIRTEL_MONEY`, `CARD`, `CASH`) |
| `payment_status` | Text | `COMPLETED` | Settlement status (`COMPLETED`, `PENDING`) |
| `swap_time` | Text | `2026-09-14 14:22:10` | Date and time of swap (some nulls) |
| `attendant_name` | Text | `Jean_Pierre_N` | Attendant on duty who conducted the swap |
| `inspection_result` | Text | `PASSED` | Physical & voltage test outcome |
| `inspection_notes` | Text | `Inspected by Jean_Pierre_N: PASSED. Terminal check ok.` | Free-form inspector remarks |

---

## 4. Anonymization & Privacy Compliance

To adhere to strict academic ethics and Rwandan Law $N^{\circ} 058/2021$ on the Protection of Personal Data and Privacy:
1. **Full Names:** Replaced with synthetic identifiers (`Customer_1001` through `Customer_1094`).
2. **Phone Numbers:** Masked using standard telecom anonymization (`+250788***XX`).
3. **National IDs:** Completely excluded from the raw transmission feed.

---

## 5. Raw Data Quality Audit (Baseline Inspection)

> **IMPORTANT:** In strict compliance with Phase II guidelines, **no data has been cleaned or modified** in `data/raw/raw_battery_swaps.csv`. The file is preserved exactly as captured. The identified quality issues below form the mandatory Phase IV cleaning checklist.

| Issue Category | Exact Count | Impact / Observation | Phase IV Cleaning Strategy |
| :--- | :---: | :--- | :--- |
| **Duplicate Rows** | **14 rows** | Exact full-row duplicates caused by network retry sync from offline station buffers. | Remove duplicates using SQL `ROWID` deduplication before insertion into relational tables. |
| **Missing Swap Timestamps** | **16 records** | `swap_time` is blank/null due to temporary terminal clock synchronization faults. | Impute missing timestamps using preceding audit log or station batch start time (`SYSDATE` fallback). |
| **Missing Inspection Notes** | **28 records** | `inspection_notes` left blank when attendants selected standard passing presets. | Default blank notes to `'Standard inspection passed - no remarks recorded'`. |
| **Numeric Fees Stored as Text** | **550 records** | Appended currency suffix `' RWF'` (e.g. `'2475 RWF'`). | Strip `' RWF'` using `REGEXP_REPLACE` or `REPLACE` and cast to `NUMBER(10,2)`. |
| **Energy Consumed Stored as Text** | **550 records** | Appended unit `' kWh'` (e.g. `'2.75 kWh'`). | Strip `' kWh'` using `SUBSTR`/`REPLACE` and convert to `NUMBER(6,2)`. |
| **District Inconsistent Variations** | **12 spellings** | 3 true districts represented with 12 distinct string variations: `'Gasabo'` (56), `'gasabo'` (49), `'GASABO'` (64), `'Gasabo District'` (58); `'Kicukiro'` (58), `'kicukiro'` (62), `'KICUKIRO'` (45), `'Kicukiro '` (56); `'Nyarugenge'` (26), `'nyarugenge'` (26), `'NYARUGENGE'` (26), `'Nyarugenge Hub'` (24). | Cleanse via `UPPER(TRIM(...))` and map to standard foreign key lookup table `STATIONS`. |
