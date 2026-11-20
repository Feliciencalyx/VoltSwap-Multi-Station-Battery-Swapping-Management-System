# VoltSwap: Multi-Station Battery Swapping Management System

**Course:** INSY 8311 – Database Development with PL/SQL  
**Academic Year:** 2026–2027 (Semester I)  
**Instructor:** Eric Maniraguha  
**Faculty:** Faculty of Information Technology, Adventist University of Central Africa (AUCA)  
**Student Name:** NSHIMYUMUKIZA Felicien  
**Student ID:** 20251SEN197  
**Group:** Group B  
**Repository Name:** `felicien_20251SEN197_voltSwap`  

---

## 1. Project Overview & Problem Statement
With the rapid electrification of commercial motorcycles and light electric vehicles across Kigali, battery swapping has emerged as the premier operational model to eliminate charging wait times. However, multi-station swapping networks face critical coordination bottlenecks:
* Attendants operate on disconnected, manual paper and spreadsheet logs.
* Risk of issuing depleted, degraded (SoH < 80%), or uninspected battery packs to riders.
* Discrepancies between mobile money payments (`MTN MoMo`/`Airtel Money`) and energy dispensed.
* Lack of real-time inventory visibility across stations leading to rider congestion.

**VoltSwap** is an enterprise database solution built on Oracle Database and PL/SQL to manage customer profiles, station infrastructure across 34 commercial hubs, battery hardware lifecycles, atomic swap transactions, and mandatory safety inspections.

---

## 2. Project Aim & Objectives
### Aim:
To architect and implement a robust Oracle relational database that coordinates safe, real-time, multi-station battery swapping operations.

### Specific Objectives:
1. Model the end-to-end battery swapping workflow using BPMN swimlanes with explicit data CRUD mappings.
2. Structure and normalize the empirical 34-station EMBSCS dataset into Third Normal Form (3NF) relational tables.
3. Configure an Oracle Pluggable Database (PDB) with customized tablespaces and security controls.
4. Implement atomic PL/SQL procedures, functions, packages, and triggers enforcing business safety rules.
5. Deploy an interactive innovation layer (Python Streamlit) connected live to the Oracle PDB.

---

## 3. Data Source: EMBSCS Empirical Dataset
* **Raw Files Storage:** `data/raw/embscs-dataset-main/` (Preserved raw and unedited)
* **Dataset Scope:**
  * **34 Commercial Swapping Stations** (`BS007`..`BS290`)
  * **92 Calendar Days** (October 1 – December 31, 2023)
  * **3,128 Station-Day Observations** per Performance Indicator (PI) category (9,384 total metric cells)
  * **144,389 Total Real-World Swaps** recorded across the network
  * Hardware telemetry: Charging compartments (`VDF9`), distance to hub (`VDF8`), swap durations (`VDF4`), arrival SoC (`VDF1`), and disruptions (`VEF1`).
* **Dataset Card:** Full metadata and raw audit in [`data/dataset_card.md`](data/dataset_card.md).

---

## 4. Normalized 3NF Database Architecture (Phase II & IV)
Normalized into Third Normal Form entities (detailed in [`docs/design/normalization.md`](docs/design/normalization.md), [`docs/design/data_dictionary.md`](docs/design/data_dictionary.md), and [`docs/design/erd_guide.md`](docs/design/erd_guide.md)):
1. `STATIONS` – 34 commercial hubs, district locations, active compartments, and vulnerability ratings.
2. `STATION_DAILY_METRICS` – 3,128 empirical daily observations (swap throughput, unique batteries, customer counts, avg swap time).
3. `STATION_DISRUPTIONS` – Monthly grid outage and disruption logs from `VEF1`.
4. `BATTERY_MODELS` – Technical catalog (capacity kWh, voltage, rated cycles).
5. `BATTERIES` – Hardware tracking (serial numbers, SoC%, health status, station).
6. `CUSTOMERS` – Rider identities, contacts, and vehicle registration plates.
7. `SWAP_TRANSACTIONS` – Transaction ledger tracking battery-in, battery-out, and energy dispensed.
8. `PAYMENTS` – Financial settlement ledger (MoMo, Airtel, Cash, Card).
9. `BATTERY_INSPECTIONS` – Quality-control log tracking physical tests and technician sign-offs.

---

## 5. Planned PL/SQL Features (Phase V & VI)
* **Stored Procedures:** `process_battery_swap` executing atomic multi-table updates within a transaction; `register_new_customer`; `log_battery_inspection`.
* **Stored Functions:** `calculate_swap_fee` dynamically computing fees based on consumed kWh and customer discount tiers; `check_station_availability`; `get_battery_health_grade`.
* **Packages & Cursors:** `PKG_VOLTSWAP_OPS` encapsulating parameterized cursors, `BULK COLLECT`, `FORALL` batch processing, and daily reconciliation reports.
* **Business Triggers:**
  * `TRG_PREVENT_UNINSPECTED_SWAP`: Blocks swap issuance if the battery has not passed mandatory technical inspection or has SoC < 90%.
  * `TRG_RESTRICT_PAYMENT_MUTATION`: Disallows unauthorized modification of settled financial records.
* **Security & Auditing:** Autonomous transaction procedure `log_audit_event` logging security violations into `AUDIT_LOG`.

---

## 6. Innovation Layer (8 Marks)
An interactive **Python Streamlit Console** connecting live to the Oracle PDB via `python-oracledb`:
* Live telemetry for the 34 EMBSCS stations (KPIs, throughput leaderboards, compartment utilization).
* Station attendant point-of-sale terminal triggering Oracle stored procedures.
* Vulnerability and disruption monitoring (`Table D.1` & `VEF1`).
* Full documentation and run commands in [`innovation/README.md`](innovation/README.md).

---

## 7. How to Run the Entire Database Suite

### Step 1: Run Database Setup (as SYSDBA)
```sql
@database/setup/01_create_pdb.sql;
@database/setup/02_create_user.sql;
@database/setup/03_tablespaces.sql;
@database/setup/04_archive_log.sql;
@database/setup/05_verify.sql;
```

### Step 2: Deploy Schema, EMBSCS Data & PL/SQL Suite
Connect as `felicien_admin@b_197_felicien_voltswap_db`:
```sql
CONNECT felicien_admin/felicien@localhost:1521/b_197_felicien_voltswap_db;
@database/run_all.sql;
```

### Step 3: Launch Innovation Dashboard
```powershell
py -3.10 -m streamlit run innovation/app.py
```
Open `http://localhost:8501` to demonstrate the live interactive dashboard.

---

## 8. References (APA 7th)
* EMBSCS Academic Research Consortium. (2024). *Electric Motorcycle Battery Swapping and Charging Stations (EMBSCS) Empirical Telemetry Dataset across 34 Stations (October–December 2023)*. GitHub & Zenodo.
* Ministry of Infrastructure (MININFRA), Republic of Rwanda. (2021). *Strategic Paper on Electric Mobility Adaptation in Rwanda*. Kigali: Government of Rwanda.
* Oracle Corporation. (2024). *Oracle Database PL/SQL Language Reference, 19c/21c*. Redwood City, CA: Oracle.
* Revankar, S. R., & Kalkhambkar, V. N. (2023). Grid integration and operational scheduling of battery swapping stations: A comprehensive review. *Journal of Energy Storage*, 41, 102834.
* Zheng, Y., Dong, Z. Y., Xu, Y., Meng, K., & Zhao, J. H. (2024). Electric vehicle battery swapping station management and optimal dispatching. *IEEE Transactions on Smart Grid*, 15(2), 1420–1431.
