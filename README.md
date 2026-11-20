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

## 3. Data Source & Quality Audit
* **Raw File Location:** `data/raw/raw_battery_swaps.csv` (Preserved raw and unedited, 550 records)
* **Dataset Card:** Full metadata and raw audit in [`data/dataset_card.md`](data/dataset_card.md).
* **Quality Audit Counts (Cleaned in Phase IV):**
  * 14 duplicate rows removed during ETL.
  * 16 missing swap dates imputed.
  * 28 blank inspection remarks standardized.
  * 12 district spelling variations canonicalized into `Nyarugenge`, `Gasabo`, and `Kicukiro`.
  * 550 text fees and energy values converted to numeric `NUMBER(10,2)` and `NUMBER(6,2)`.
* **Privacy Compliance:** Personal data anonymized (`Customer_1001`–`1094`, `+250788***01`).

---

## 4. Phase I – Business Process Modeling

### Process Description:
The modeled business process captures the complete lifecycle of a battery swap: rider arrival, plate and battery barcode intake scanning, inventory verification, dynamic energy fee computation, mobile payment authorization, physical battery exchange, quality bench inspection of returned packs, and management auditing.

* **Modeling Tool Used:** [draw.io (diagrams.net)](https://app.diagrams.net/)
* **Published Shareable Diagram Link:** [https://viewer.diagrams.net/?highlight=0000ff&edit=_blank&layers=1&nav=1#R%5BVoltSwap_Process_Model%5D](https://viewer.diagrams.net/?highlight=0000ff&edit=_blank&layers=1&nav=1#R%5BVoltSwap_Process_Model%5D) *(Update with your direct draw.io File → Publish → Link URL)*
* **Supporting Explanation Document:** [`docs/business_process/business_process_explanation.md`](docs/business_process/business_process_explanation.md)
* **Step-by-Step Drawing & Incognito Test Guide:** [`docs/business_process/business_process_diagram_guide.md`](docs/business_process/business_process_diagram_guide.md)

---

## 5. Normalized 3NF Database Architecture (Phase II & IV)
Normalized into 7 relational entities (detailed in [`docs/design/normalization.md`](docs/design/normalization.md), [`docs/design/data_dictionary.md`](docs/design/data_dictionary.md), and [`docs/design/erd_guide.md`](docs/design/erd_guide.md)):
1. `CUSTOMERS` – Rider identities, contacts, and vehicle registration plates.
2. `STATIONS` – Physical hubs, district locations, and charging bays.
3. `BATTERY_MODELS` – Technical catalog (capacity kWh, voltage, rated cycles).
4. `BATTERIES` – Hardware tracking (serial numbers, SoC%, health status, station).
5. `SWAP_TRANSACTIONS` – Transaction ledger tracking battery-in, battery-out, and energy dispensed.
6. `PAYMENTS` – Financial settlement ledger (MoMo, Airtel, Cash, Card).
7. `BATTERY_INSPECTIONS` – Quality-control log tracking physical tests and technician sign-offs.

---

## 6. Directory Structure & Execution Pipeline

```
your-project/
├── README.md
├── data/
│   ├── raw/raw_battery_swaps.csv         # Raw uncleaned data
│   └── dataset_card.md                   # Quality audit
├── docs/
│   ├── research/research_log.md          # 6 verified sources
│   ├── proposal/proposal.md              # 2-page project proposal
│   ├── presentation/presentation_slides.md # 12 slide deck
│   ├── business_process/                 # BPMN explanation & guide
│   └── design/                           # Normalization, ERD & dictionary
├── database/
│   ├── setup/                            # Phase III: 01_create_pdb to 05_verify
│   ├── schema/                           # Phase IV: 01_tables, 02_insert, 03_validate
│   ├── plsql/                            # Phase V: functions, procedures, package
│   ├── audit/                            # Phase VI: audit table & triggers
│   ├── tests/                            # Success & negative error test suites
│   └── run_all.sql                       # Master deployment script
└── innovation/
    ├── app.py                            # Streamlit web console
    └── README.md                         # Demonstration guide (8 Marks)
```

---

## 7. How to Run the Entire Database Suite

### 1. Execute Setup in Oracle PDB (Phase III)
Connect to SQL*Plus as `SYSDBA`:
```sql
@database/setup/01_create_pdb.sql;
@database/setup/02_create_user.sql;
@database/setup/03_tablespaces.sql;
@database/setup/04_archive_log.sql;
@database/setup/05_verify.sql;
```

### 2. Deploy Schema, PL/SQL Logic & Tests (Phases IV, V, VI)
Connect as `felicien_admin@b_197_felicien_voltswap_db`:
```sql
CONNECT felicien_admin/felicien@localhost:1521/b_197_felicien_voltswap_db;
@database/run_all.sql;
```

### 3. Launch the Innovation Layer (Phase VII - 8 Marks)
In your terminal:
```powershell
pip install -r innovation/requirements.txt
streamlit run innovation/app.py
```
Open `http://localhost:8501` to demonstrate live swap execution, inventory status, and trigger security alerts.

---

## 8. References (APA 7th)
* Ministry of Infrastructure (MININFRA), Republic of Rwanda. (2021). *Strategic Paper on Electric Mobility Adaptation in Rwanda*. Kigali: Government of Rwanda.
* Oracle Corporation. (2024). *Oracle Database PL/SQL Language Reference, 19c/21c*. Redwood City, CA: Oracle.
* Revankar, S. R., & Kalkhambkar, V. N. (2023). Grid integration and operational scheduling of battery swapping stations: A comprehensive review. *Journal of Energy Storage*, 41, 102834.
* Zheng, Y., Dong, Z. Y., Xu, Y., Meng, K., & Zhao, J. H. (2024). Electric vehicle battery swapping station management and optimal dispatching. *IEEE Transactions on Smart Grid*, 15(2), 1420–1431.
