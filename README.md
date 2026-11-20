# VoltSwap: Multi-Station Electric Car Battery Swapping Management System

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
With the accelerating transition towards zero-emission passenger vehicles and commercial electric taxi cabs, battery swapping for **electric passenger cars, commercial EV taxis, and corporate fleet vehicles** has emerged as the premier operational model to eliminate 40–80 minute fast-charging queues. In an automated drive-in car battery swapping station, a depleted vehicle battery pack (40–85 kWh) is disengaged from the vehicle underbody and replaced with a fully conditioned, charged pack in under three minutes.

However, decentralized multi-station car swapping networks face critical coordination bottlenecks:
* Station attendants and bay operators operate on disconnected, manual paper and spreadsheet logs.
* Risk of allocating depleted, degraded (State of Health < 80%), or uninspected high-voltage battery packs to passenger cars.
* Discrepancies between digital fleet payments (`MTN MoMo`/`Airtel Money`, corporate billing) and energy dispensed (kWh).
* Lack of real-time inventory and bay availability visibility across stations leading to EV car congestion.

**VoltSwap** is an enterprise database solution built on Oracle Database and PL/SQL to manage driver accounts, car vehicle profiles, station drive-in bays across 34 commercial hubs, high-capacity battery hardware lifecycles, atomic swap transactions, and mandatory safety inspections.

---

## 2. Project Aim & Objectives
### Aim:
To architect and implement a robust Oracle relational database that coordinates safe, real-time, multi-station electric car battery swapping and fleet operations.

### Specific Objectives:
1. Model the end-to-end car battery swapping workflow using BPMN swimlanes with explicit data CRUD mappings.
2. Structure and normalize empirical 34-station swapping telemetry into Third Normal Form (3NF) relational tables.
3. Configure an Oracle Pluggable Database (PDB) with customized tablespaces and security controls.
4. Implement atomic PL/SQL procedures, functions, packages, and triggers enforcing vehicle safety and tariff rules.
5. Deploy an interactive innovation layer (Python Streamlit) connected live to the Oracle PDB.

---

## 3. Data Source: 34-Station Empirical Swapping Dataset
* **Raw Files Storage:** `data/raw/embscs-dataset-main/` (Preserved raw and unedited)
* **Dataset Scope:**
  * **34 Commercial Swapping Stations** (`BS007`..`BS290`)
  * **92 Calendar Days** (October 1 – December 31, 2023)
  * **3,128 Station-Day Observations** per Performance Indicator (PI) category (9,384 total metric cells)
  * **144,389 Total Real-World Swaps** recorded across the multi-station network
  * Hardware telemetry: Charging compartments/bays (`VDF9`), road distances to hub (`VDF8`), swap durations (`VDF4`), arrival SoC ($11\%–16\%$, `VDF1`), and disruptions (`VEF1`).
* **Dataset Card:** Full metadata and raw audit in [`data/dataset_card.md`](data/dataset_card.md).

---

## 4. Normalized 3NF Database Architecture (Phase II & IV)
Normalized into Third Normal Form entities (detailed in [`docs/design/normalization.md`](docs/design/normalization.md), [`docs/design/data_dictionary.md`](docs/design/data_dictionary.md), and [`docs/design/erd_guide.md`](docs/design/erd_guide.md)):
1. `STATIONS` – 34 commercial hubs, district locations, drive-in swap bays, and vulnerability ratings.
2. `STATION_DAILY_METRICS` – 3,128 empirical daily observations (swap throughput, unique batteries, EV car counts, avg swap time).
3. `STATION_DISRUPTIONS` – Monthly grid outage and disruption logs from `VEF1`.
4. `BATTERY_MODELS` – High-voltage EV car battery specifications (`VoltCar-40kWh`, `VoltCar-60kWh`, `VoltCar-85kWh`).
5. `BATTERIES` – Physical car battery pack tracking (serial numbers, SoC%, health status, station).
6. `CUSTOMERS` – EV car owners, commercial taxi drivers, and vehicle registration numbers.
7. `SWAP_TRANSACTIONS` – Transaction ledger tracking battery-in, battery-out, and net energy dispensed.
8. `PAYMENTS` – Financial settlement ledger (MoMo, Airtel, Cash, Fleet Card).
9. `BATTERY_INSPECTIONS` – High-voltage quality-control log tracking thermal safety, insulation, and technician sign-offs.

---

## 5. Planned PL/SQL Features (Phase V & VI)
* **Stored Procedures:** `process_battery_swap` executing atomic multi-table updates within a transaction; `register_new_customer`; `log_battery_inspection`.
* **Stored Functions:** `calculate_swap_fee` dynamically computing fees based on net kWh replenished and customer tiers (`PRIVATE_CAR`, `COMMERCIAL_TAXI`, `CORPORATE_FLEET`); `check_station_availability`; `get_battery_health_grade`.
* **Packages & Cursors:** `PKG_VOLTSWAP_OPS` encapsulating parameterized cursors, `BULK COLLECT`, `FORALL` batch processing, and daily reconciliation reports.
* **Business Triggers:**
  * `TRG_PREVENT_UNINSPECTED_SWAP`: Blocks swap issuance if the car battery has not passed mandatory technical inspection or has SoC < 90%.
  * `TRG_RESTRICT_PAYMENT_MUTATION`: Disallows unauthorized modification of settled financial records.
* **Security & Auditing:** Autonomous transaction procedure `log_audit_event` logging security violations into `AUDIT_LOG`.

---

## 6. Innovation Layer (8 Marks)
An interactive **Python Streamlit Console** connecting live to the Oracle PDB via `python-oracledb`:
* Live telemetry for the 34 car swapping stations (KPIs, throughput leaderboards, compartment utilization).
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
* EMBSCS Academic Research Consortium. (2024). *Electric Vehicle Battery Swapping and Charging Stations (EMBSCS) Empirical Telemetry Dataset across 34 Stations (October–December 2023)*. GitHub & Zenodo.
* Ministry of Infrastructure (MININFRA), Republic of Rwanda. (2021). *Strategic Paper on Electric Mobility Adaptation in Rwanda*. Kigali: Government of Rwanda.
* Oracle Corporation. (2024). *Oracle Database PL/SQL Language Reference, 19c/21c*. Redwood City, CA: Oracle.
* Revankar, S. R., & Kalkhambkar, V. N. (2023). Grid integration and operational scheduling of battery swapping stations: A comprehensive review. *Journal of Energy Storage*, 41, 102834.
* Zheng, Y., Dong, Z. Y., Xu, Y., Meng, K., & Zhao, J. H. (2024). Electric vehicle battery swapping station management and optimal dispatching. *IEEE Transactions on Smart Grid*, 15(2), 1420–1431.
