# Capstone Project Presentation Deck (12 Slides)

**Course:** INSY 8311 – Database Development with PL/SQL  
**Project:** VoltSwap Multi-Station Battery Swapping Management System  
**Student:** NSHIMYUMUKIZA Felicien | Student ID: 20251SEN197  
**Instructor:** Eric Maniraguha | AUCA Faculty of Information Technology  

---

## Slide 1: Title & Project Identity
* **Title:** VoltSwap: Multi-Station Electric Vehicle Battery Swapping Management System
* **Course:** INSY 8311 – Database Development with PL/SQL
* **Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)
* **Academic Year:** 2026–2027 (Semester I)
* **Instructor:** Eric Maniraguha
* **GitHub Repository:** `https://github.com/Feliciencalyx/felicien_20251SEN197_voltSwap`

---

## Slide 2: Background & Problem Statement
* **Urban Electrification Context:** Kigali's accelerating transition towards zero-emission commercial e-motorcycles demands continuous battery availability.
* **The Operational Crisis:**
  * Decentralized stations operate on disconnected spreadsheets and manual logs.
  * Risk of issuing depleted, uncertified, or degraded batteries (SoH < 80%) to riders.
  * Payment discrepancies between mobile money transactions (`MTN MoMo`/`Airtel Money`) and issued energy.
  * Lack of real-time multi-hub inventory coordination leading to rider congestion.

---

## Slide 3: Motivation & Justification
* **Why Battery Swapping?** Swapping eliminates the 4–6 hour charging barrier, reducing commercial downtime to under 3 minutes.
* **Why Database Centric?** Data integrity cannot rely on frontend applications or busy attendants. The database engine must enforce battery safety constraints, financial atomicity, and multi-hub inventory allocation.
* **Alignment with National Goals:** Directly supports Rwanda’s MININFRA E-Mobility Strategic Target (100% electrified commercial fleets).

---

## Slide 4: Project Objectives
* **Main Objective:**
  * To architect and implement an enterprise-grade Oracle relational database using PL/SQL to coordinate safe, real-time, multi-station battery swapping operations.
* **Specific Objectives:**
  1. Design a 3NF normalized relational schema decoupling customers, stations, battery hardware, inspections, and billing.
  2. Implement atomic PL/SQL stored procedures and packages to automate swap processing and fee calculations.
  3. Enforce database-level safety triggers preventing the dispatch of uninspected or damaged batteries.
  4. Develop an interactive live application layer (Python Streamlit) connected directly to Oracle PDB.

---

## Slide 5: Research & State-of-the-Art Gaps
* **Review of 6 Core Sources:**
  * *Academic Literature (IEEE / ScienceDirect):* Research focuses heavily on electrical grid dispatch algorithms, neglecting transactional safety, payment reconciliation, and audit trails.
  * *Local Systems (Ampersand Rwanda Case Study):* Highlights challenges of multi-hub inventory synchronization when offline records are reconciled manually.
  * *Dataset Analysis (Kaggle EV Telemetry):* Raw telemetry is denormalized, full of string inconsistencies, missing timestamps, and duplicate sync rows.
* **The Gap:** Need for an end-to-end relational schema with automated database-level business constraints.

---

## Slide 6: Data Sourcing & Raw Quality Audit
* **Dataset:** 550 operational swap records collected across 5 Kigali stations (`data/raw/raw_battery_swaps.csv`).
* **Anonymization:** Names mapped to synthetic IDs (`Customer_1001`), phone numbers masked (`+250788***01`).
* **Quality Audit (Counts Identified for Phase IV Cleaning):**
  * 14 duplicate rows (offline sync retries).
  * 16 records with missing timestamps.
  * 28 records with null inspection remarks.
  * 12 distinct string variations across 3 true geographical districts (`Gasabo`, `Kicukiro`, `Nyarugenge`).
  * 550 records with fees and energy stored as text strings (e.g. `'2500 RWF'`, `'3.2 kWh'`).

---

## Slide 7: Proposed Solution & Innovation Layer
* **Central Relational Architecture:** High-availability Oracle Pluggable Database (`b_197_felicien_voltswap_db`).
* **Innovation Layer (8 Marks):**
  * Interactive **Python Streamlit Attendant Console** connecting live to Oracle via `python-oracledb`.
  * Allows station attendants to scan plates, pick available batteries, and invoke stored procedures live.
  * Executive dashboard visualizing real-time station inventory, revenue metrics, and battery degradation trends.

---

## Slide 8: Relational Database Architecture (3NF)
* **Core Relational Entities:**
  1. `CUSTOMERS` – Rider identities and motorcycle registration plates.
  2. `STATIONS` – Physical hub metadata, charging bays, and capacity.
  3. `BATTERY_MODELS` – Technical catalog (capacity kWh, voltage, rated cycles).
  4. `BATTERIES` – Hardware tracking (serial numbers, SoC%, health status, location).
  5. `SWAP_TRANSACTIONS` – Transaction ledger tracking battery-in, battery-out, and energy dispensed.
  6. `PAYMENTS` – Financial settlement ledger (Momo, Airtel, Cash, Card).
  7. `BATTERY_INSPECTIONS` – Quality-control log tracking physical tests and technician sign-offs.

---

## Slide 9: PL/SQL Implementation Approach
* **Stored Procedures:**
  * `process_battery_swap(...)`: Executes an atomic transaction updating the incoming battery to `PENDING_INSPECTION`, the outgoing battery to `IN_USE`, and recording the transaction.
* **Stored Functions:**
  * `calculate_swap_fee(...)`: Calculates fees based on net kWh consumed and subscription rates.
  * `check_station_availability(...)`: Verifies available charged batteries for a given model.
* **Triggers:**
  * `TRG_PREVENT_UNINSPECTED_SWAP`: Blocks swap issuance if the battery has not passed mandatory technical inspection.
  * `TRG_RESTRICT_PAYMENT_MUTATION`: Disallows unauthorized update/deletion of settled financial records outside administrative windows.
* **Packages & Cursors:**
  * `PKG_VOLTSWAP_OPS`: Package encapsulating reconciliation cursors and daily reporting.

---

## Slide 10: Expected Demonstration & Results
* **In-Class Live Demonstration:**
  1. Query PDB status and show all tablespaces online.
  2. Open Streamlit GUI, select rider `CUST_1042` and station `Kigali Central Hub`.
  3. Execute a swap transaction live $\rightarrow$ Observe atomic row creation in `SWAP_TRANSACTIONS` and `PAYMENTS`.
  4. Attempt to allocate a failed/uninspected battery $\rightarrow$ Show PL/SQL trigger blocking the transaction with a clear custom error.
  5. Inspect the `AUDIT_LOG` table confirming automatic security recording.

---

## Slide 11: Future Enhancements & Limitations
* **Current Scope:** Core operational swapping, inventory management, inspection gating, and relational billing.
* **Future Work:**
  * Automated IoT smart-rack integration (physical locker unlocking upon payment confirmation).
  * Machine learning forecasting model predicting station battery depletion based on weather and traffic patterns.
  * Integration with commercial national payment gateways (e.g., MTN MoMo Open API).

---

## Slide 12: References (APA 7th)
* Ministry of Infrastructure (MININFRA), Republic of Rwanda. (2021). *Strategic Paper on Electric Mobility Adaptation in Rwanda*. Kigali: MININFRA.
* Oracle Corporation. (2024). *Oracle Database PL/SQL Language Reference, 19c/21c*. Redwood City, CA: Oracle.
* Revankar, S. R., & Kalkhambkar, V. N. (2023). Grid integration and operational scheduling of battery swapping stations: A comprehensive review. *Journal of Energy Storage*, 41, 102834.
* Zheng, Y., Dong, Z. Y., Xu, Y., Meng, K., & Zhao, J. H. (2024). Electric vehicle battery swapping station management and optimal dispatching. *IEEE Transactions on Smart Grid*, 15(2), 1420–1431.
