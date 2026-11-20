# VoltSwap Multi-Station Battery Swapping Management System
**Course:** INSY 8311 – Database Development with PL/SQL  
**Academic Year:** 2026–2027 (Semester I)  
**Student Name:** NSHIMYUMUKIZA Felicien  
**Student ID:** 20251SEN197  
**Instructor:** Eric Maniraguha  
**Fictional Organization:** VoltSwap Technologies Ltd.  

---

## 1. Title
**VoltSwap: Multi-Station Electric Vehicle Battery Swapping and Lifecycle Management System**

## 2. Problem Statement
With the rapid electrification of commercial motorcycles and light electric vehicles across urban centers such as Kigali, battery swapping has emerged as the premier model to eliminate charging downtime. However, decentralized multi-station swapping networks face acute operational bottlenecks:
1. **Inventory Visibility Gaps:** Station attendants frequently operate on localized paper or spreadsheet logs, resulting in double-allocation of fully charged battery packs or riders arriving to find zero compatible batteries.
2. **Quality and Safety Blindspots:** Depleted batteries returned with terminal wear, casing damage, or degraded health (State of Health < 80%) are sometimes erroneously re-issued without undergoing mandatory technical safety inspections.
3. **Transaction & Payment Desynchronization:** Mobile money payments (`MTN MoMo` and `Airtel Money`) and cash transactions are manually recorded, creating accounting discrepancies between energy dispensed (kWh) and revenue booked.

Without an enterprise relational database enforcing strict data constraints and transactional integrity, operational inefficiency, revenue leakage, and safety hazards compromise the organization's scalability.

## 3. Proposed Solution
VoltSwap will implement a centralized, high-performance relational database architecture built on Oracle Database and PL/SQL. The proposed solution coordinates operations across multiple swapping stations by managing:
* Central customer profiles and vehicle registrations.
* Station infrastructure, swap bays, and live battery inventories.
* Strict state-driven battery lifecycles (`CHARGED`, `IN_USE`, `PENDING_INSPECTION`, `MAINTENANCE`, `RETIRED`).
* Atomic swap transactions coupling battery intake, battery issuance, energy metering, and payment receipts.
* Mandatory inspection gating preventing any uncertified battery from returning to the active swap pool.

## 4. Data Source
The system utilizes a real-world structured operational log (`data/raw/raw_battery_swaps.csv`) containing 550 swap records across five Kigali metropolitan stations (Nyarugenge, Gasabo, Kicukiro). The dataset records rider identifiers, vehicle registration numbers, battery hardware serials, state of charge (SoC%), energy consumption (kWh), tariff billing, payment modes, and physical inspection outcomes. All sensitive identities are strictly anonymized in compliance with academic data protection standards.

## 5. Planned Database Tables (Third Normal Form)
The raw dataset will be normalized into seven relational entities:
1. `CUSTOMERS`: Stores rider biographical data, contact numbers, and vehicle registration numbers.
2. `STATIONS`: Stores physical hub locations, administrative districts, charging bays, and operating statuses.
3. `BATTERY_MODELS`: Standard catalog of battery chemistry, voltage specifications, capacity (kWh), and rated life cycles.
4. `BATTERIES`: Individual physical packs, tracking serial numbers, current SoC, health metrics, and active station assignment.
5. `SWAP_TRANSACTIONS`: Core transaction entity recording returned battery, released battery, timestamps, and kWh consumed.
6. `PAYMENTS`: Financial ledger capturing payment method, transaction amounts, status, and receipt references.
7. `BATTERY_INSPECTIONS`: Quality-control log recording physical condition, voltage stability, inspector identity, and pass/fail verdicts.

## 6. Planned PL/SQL Features
The database will embed business logic inside the Oracle database engine:
* **Stored Procedures:** `process_battery_swap` executing an atomic four-step transaction (intake check, release verification, inventory state update, and transaction logging).
* **Stored Functions:** `calculate_swap_fee` dynamically computing energy billing based on consumed kWh and customer subscription tier; `check_station_availability` verifying ready battery counts.
* **Explicit Cursors & Packages:** Package `PKG_VOLTSWAP_OPERATIONS` encapsulating station reconciliation cursors and monthly battery degradation reports.
* **Business & Security Triggers:**
  * `TRG_PREVENT_UNINSPECTED_SWAP`: Blocks swap issuance if the battery has not passed mandatory technical inspection.
  * `TRG_RESTRICT_PAYMENT_MUTATION`: Disallows unauthorized update/deletion of settled financial records outside administrative windows.
* **Audit Logging:** An autonomous transaction audit logger recording security violations, unauthorized queries, and privilege escalation attempts.

## 7. Innovation (8 Marks)
VoltSwap will connect a live interactive **Python Streamlit Attendant & Operations Dashboard** (`innovation/app.py`) directly to the Oracle Pluggable Database via `python-oracledb`. 
* **Live Operational Terminal:** Station attendants can visually select an incoming motorcycle plate, confirm available charged batteries, and trigger the `process_battery_swap` PL/SQL stored procedure live with a single click.
* **Executive Telemetry:** Managers view real-time KPIs, station inventory heatmaps, and battery health degradation curves queried dynamically from Oracle views.

## 8. References (APA 7th)
* Ministry of Infrastructure (MININFRA), Republic of Rwanda. (2021). *Strategic Paper on Electric Mobility Adaptation in Rwanda*. Kigali: Government of Rwanda.
* Oracle Corporation. (2024). *Oracle Database PL/SQL Language Reference, 19c/21c*. Redwood City, CA: Oracle.
* Revankar, S. R., & Kalkhambkar, V. N. (2023). Grid integration and operational scheduling of battery swapping stations: A comprehensive review. *Journal of Energy Storage*, 41, 102834.
* Zheng, Y., Dong, Z. Y., Xu, Y., Meng, K., & Zhao, J. H. (2024). Electric vehicle battery swapping station management and optimal dispatching. *IEEE Transactions on Smart Grid*, 15(2), 1420–1431.
