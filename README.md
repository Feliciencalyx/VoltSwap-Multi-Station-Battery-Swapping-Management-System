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

**VoltSwap** is an enterprise database solution built on Oracle Database and PL/SQL to manage customer profiles, station inventory, battery hardware lifecycles, atomic swap transactions, and mandatory safety inspections.

---

## 2. Project Aim & Objectives
### Aim:
To architect and implement a robust Oracle relational database that coordinates safe, real-time, multi-station battery swapping operations.

### Specific Objectives:
1. Model the end-to-end battery swapping workflow using BPMN swimlanes with explicit data CRUD mappings.
2. Structure and normalize raw operational logs into Third Normal Form (3NF) relational tables.
3. Configure an Oracle Pluggable Database (PDB) with customized tablespaces and security controls.
4. Implement atomic PL/SQL procedures, functions, packages, and triggers enforcing business safety rules.
5. Deploy an interactive innovation layer (Python Streamlit) connected live to the Oracle PDB.

---

## 3. Data Source
* **File Location:** `data/raw/raw_battery_swaps.csv` (Preserved raw and unedited)
* **Dataset Size:** 550 records across 5 Kigali stations
* **Dataset Card:** Detailed metadata and raw data quality audit in [`data/dataset_card.md`](data/dataset_card.md).
* **Privacy Compliance:** Rider names anonymized (`Customer_1001`–`1094`) and phone numbers masked (`+250788***01`).

---

## 4. Phase I – Business Process Modeling

### Process Description:
The modeled business process captures the complete lifecycle of a battery swap: rider arrival, plate and battery barcode intake scanning, inventory verification, dynamic energy fee computation, mobile payment authorization, physical battery exchange, quality bench inspection of returned packs, and management auditing.

* **Modeling Tool Used:** [draw.io (diagrams.net)](https://app.diagrams.net/)
* **Published Shareable Diagram Link:** [https://viewer.diagrams.net/?highlight=0000ff&edit=_blank&layers=1&nav=1#R%5BVoltSwap_Process_Model%5D](https://viewer.diagrams.net/?highlight=0000ff&edit=_blank&layers=1&nav=1#R%5BVoltSwap_Process_Model%5D) *(Update with your direct draw.io File → Publish → Link URL)*
* **Supporting Explanation Document:** [`docs/business_process/business_process_explanation.md`](docs/business_process/business_process_explanation.md)
* **Step-by-Step Drawing & Incognito Test Guide:** [`docs/business_process/business_process_diagram_guide.md`](docs/business_process/business_process_diagram_guide.md)

---

## 5. Planned 3NF Relational Tables
Normalized into 7 relational entities (detailed in [`docs/design/normalization.md`](docs/design/normalization.md) and [`docs/design/data_dictionary.md`](docs/design/data_dictionary.md)):
1. `CUSTOMERS` – Rider identities, contacts, and vehicle registration plates.
2. `STATIONS` – Physical hubs, district locations, and charging bays.
3. `BATTERY_MODELS` – Technical catalog (capacity kWh, voltage, rated cycles).
4. `BATTERIES` – Hardware tracking (serial numbers, SoC%, health status, station).
5. `SWAP_TRANSACTIONS` – Transaction ledger tracking battery-in, battery-out, and energy dispensed.
6. `PAYMENTS` – Financial settlement ledger (MoMo, Airtel, Cash, Card).
7. `BATTERY_INSPECTIONS` – Quality-control log tracking physical tests and technician sign-offs.

---

## 6. Planned PL/SQL Features
* **Stored Procedures:** `process_battery_swap` executing atomic four-table updates within a transaction.
* **Stored Functions:** `calculate_swap_fee` dynamically computing fees based on consumed kWh; `check_station_availability` returning ready battery counts.
* **Packages & Cursors:** `PKG_VOLTSWAP_OPS` encapsulating daily station reconciliation reports.
* **Business Triggers:**
  * `TRG_PREVENT_UNINSPECTED_SWAP`: Blocks swap issuance if the battery has not passed mandatory technical inspection.
  * `TRG_RESTRICT_PAYMENT_MUTATION`: Disallows unauthorized modification of settled financial records.
* **Security & Auditing:** Autonomous transaction trigger logging security violations into `AUDIT_LOG`.

---

## 7. Innovation Layer (8 Marks)
An interactive **Python Streamlit Attendant & Operations Console** connecting live to the Oracle PDB via `python-oracledb`. 
* Real-time multi-station inventory monitoring.
* One-click swap execution invoking PL/SQL procedures.
* Live trigger safety verification.
* Full documentation and run commands in [`innovation/README.md`](innovation/README.md).

---

## 8. Database Architecture & Setup Scripts (Phase III)
Setup scripts located in `database/setup/`:
* [`01_create_pdb.sql`](database/setup/01_create_pdb.sql) – Creates `b_197_felicien_voltswap_db`, opens it, and saves state.
* [`02_create_user.sql`](database/setup/02_create_user.sql) – Creates `felicien_admin` with DBA role.
* [`03_tablespaces.sql`](database/setup/03_tablespaces.sql) – Configures `voltswap_data` (100M/1G), `voltswap_idx` (50M/500M), and `voltswap_temp` (50M/500M).
* [`04_archive_log.sql`](database/setup/04_archive_log.sql) – Architectural explanation of CDB vs PDB scope and enabling steps.
* [`05_verify.sql`](database/setup/05_verify.sql) – Verification queries for PDB, users, storage, and archive mode.

---

## 9. References (APA 7th)
* Ministry of Infrastructure (MININFRA), Republic of Rwanda. (2021). *Strategic Paper on Electric Mobility Adaptation in Rwanda*. Kigali: Government of Rwanda.
* Oracle Corporation. (2024). *Oracle Database PL/SQL Language Reference, 19c/21c*. Redwood City, CA: Oracle.
* Revankar, S. R., & Kalkhambkar, V. N. (2023). Grid integration and operational scheduling of battery swapping stations: A comprehensive review. *Journal of Energy Storage*, 41, 102834.
* Zheng, Y., Dong, Z. Y., Xu, Y., Meng, K., & Zhao, J. H. (2024). Electric vehicle battery swapping station management and optimal dispatching. *IEEE Transactions on Smart Grid*, 15(2), 1420–1431.
