# VoltSwap Multi-Station Electric Car Battery Swapping Management System
**Course:** INSY 8311 – Database Development with PL/SQL  
**Academic Year:** 2026–2027 (Semester I)  
**Student Name:** NSHIMYUMUKIZA Felicien  
**Student ID:** 20251SEN197  
**Instructor:** Eric Maniraguha  
**Fictional Organization:** VoltSwap Technologies Ltd.  

---

## 1. Title
**VoltSwap: Multi-Station Electric Car Battery Swapping and Lifecycle Management System**

## 2. Problem Statement
With the rapid electrification of passenger cars, commercial electric taxi cabs, and corporate fleets across metropolitan centers such as Kigali, battery swapping has emerged as the premier operational model to eliminate 40–80 minute charging bottlenecks. In automated drive-in swap bays, a depleted electric car battery pack (40–85 kWh) is dismounted from the vehicle underbody and replaced with a fully charged pack in under three minutes. However, decentralized multi-station car swapping networks face critical operational challenges:
1. **Inventory & Bay Visibility Gaps:** Station attendants frequently operate on localized paper or spreadsheet logs, resulting in EV cars arriving at stations with zero compatible charged battery packs or facing long bay queues.
2. **High-Voltage Quality & Safety Blindspots:** Large automotive lithium packs returned with thermal anomalies, cell imbalances, or degraded health (State of Health < 80%) risk catastrophic damage if re-issued without passing mandatory high-voltage technical safety inspections.
3. **Billing & Energy Desynchronization:** Mobile money payments (`MTN MoMo` and `Airtel Money`), bank cards, and corporate fleet accounts are recorded manually, creating accounting discrepancies between energy dispensed (kWh) and revenue booked.

Without an enterprise relational database enforcing strict data constraints, bay synchronization, and transactional integrity, operational inefficiency, revenue loss, and safety risks compromise the organization's scalability.

## 3. Proposed Solution
VoltSwap will implement a centralized, high-performance relational database architecture built on Oracle Database and PL/SQL. The proposed solution coordinates operations across 34 commercial swapping stations by managing:
* Central customer profiles, EV car models, and vehicle registration numbers.
* Station infrastructure, automated drive-in bays, and live high-voltage battery inventories.
* Strict state-driven battery lifecycles (`CHARGED`, `IN_USE`, `PENDING_INSPECTION`, `MAINTENANCE`, `RETIRED`).
* Atomic swap transactions coupling vehicle intake, automated pack issuance, energy metering, and payment receipts.
* Mandatory inspection gating preventing any uncertified automotive battery from returning to the active vehicle swap pool.

## 4. Data Source
The system utilizes an empirical real-world operational dataset (`data/raw/embscs-dataset-main/`) recording 144,389 battery swaps and 3,128 daily observations across 34 commercial stations over 92 consecutive calendar days (October 1 – December 31, 2023). The dataset captures daily swap throughput (`PI_1`), unique vehicle batteries exchanged (`PI_2`), distinct EV drivers served (`PI_3`), charging compartment capacities (`VDF9`), road distances (`VDF8`), swap durations (`VDF4`), and grid disruption logs (`VEF1`). Sensitive driver identities are strictly anonymized in compliance with academic data protection standards.

## 5. Planned Database Tables (Third Normal Form)
The dataset is normalized into relational entities in Third Normal Form:
1. `STATIONS`: Stores 34 commercial drive-in swap hubs, administrative districts, bay capacities, and vulnerability indices.
2. `STATION_DAILY_METRICS`: Stores 3,128 empirical daily telemetry records (swap throughput, unique batteries, EV drivers served, avg swap time).
3. `STATION_DISRUPTIONS`: Stores operational outage records captured from station telemetry.
4. `BATTERY_MODELS`: Standard catalog of automotive EV battery chemistry, voltages, and capacities (40 kWh, 60 kWh, 85 kWh).
5. `BATTERIES`: Individual physical automotive packs, tracking serial numbers, current SoC, health metrics, and station locations.
6. `CUSTOMERS`: Stores EV car owners, commercial taxi drivers, and vehicle registration plates.
7. `SWAP_TRANSACTIONS`: Core transaction entity recording returned pack, released pack, timestamps, and net kWh dispensed.
8. `PAYMENTS`: Financial ledger capturing payment method, transaction amounts, status, and receipt references.
9. `BATTERY_INSPECTIONS`: Quality-control log recording high-voltage insulation tests, cell health, inspector identity, and pass/fail verdicts.

## 6. Planned PL/SQL Features
The database will embed business logic inside the Oracle database engine:
* **Stored Procedures:** `process_battery_swap` executing an atomic four-step transaction (intake check, release verification, inventory state update, and transaction logging).
* **Stored Functions:** `calculate_swap_fee` dynamically computing energy billing based on consumed kWh and customer subscription tier (`PRIVATE_CAR`, `COMMERCIAL_TAXI`, `CORPORATE_FLEET`); `check_station_availability` verifying ready battery counts.
* **Explicit Cursors & Packages:** Package `PKG_VOLTSWAP_OPS` encapsulating station reconciliation cursors and monthly battery degradation reports.
* **Business & Security Triggers:**
  * `TRG_PREVENT_UNINSPECTED_SWAP`: Blocks swap issuance if the automotive pack has not passed mandatory technical inspection.
  * `TRG_RESTRICT_PAYMENT_MUTATION`: Disallows unauthorized update/deletion of settled financial records outside administrative windows.
* **Audit Logging:** An autonomous transaction audit logger recording security violations, unauthorized queries, and privilege escalation attempts.

## 7. Innovation (8 Marks)
VoltSwap will connect a live interactive **Python Streamlit Attendant & Operations Dashboard** (`innovation/app.py`) directly to the Oracle Pluggable Database via `python-oracledb`. 
* **Live Drive-in Terminal:** Station attendants can visually select an incoming electric car plate, confirm available charged battery packs, and trigger the `process_battery_swap` PL/SQL stored procedure live with a single click.
* **Executive Telemetry:** Fleet managers view real-time KPIs, station inventory heatmaps, and vulnerability curves queried dynamically from Oracle views across all 34 commercial hubs.

## 8. References (APA 7th)
* EMBSCS Academic Research Consortium. (2024). *Electric Vehicle Battery Swapping and Charging Stations (EMBSCS) Empirical Telemetry Dataset across 34 Stations (October–December 2023)*. GitHub & Zenodo.
* Ministry of Infrastructure (MININFRA), Republic of Rwanda. (2021). *Strategic Paper on Electric Mobility Adaptation in Rwanda*. Kigali: Government of Rwanda.
* Oracle Corporation. (2024). *Oracle Database PL/SQL Language Reference, 19c/21c*. Redwood City, CA: Oracle.
* Revankar, S. R., & Kalkhambkar, V. N. (2023). Grid integration and operational scheduling of battery swapping stations: A comprehensive review. *Journal of Energy Storage*, 41, 102834.
* Zheng, Y., Dong, Z. Y., Xu, Y., Meng, K., & Zhao, J. H. (2024). Electric vehicle battery swapping station management and optimal dispatching. *IEEE Transactions on Smart Grid*, 15(2), 1420–1431.
