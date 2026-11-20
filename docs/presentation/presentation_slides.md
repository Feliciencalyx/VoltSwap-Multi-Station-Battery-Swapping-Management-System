# Capstone Project Presentation Deck (12 Slides): Electric Car Swapping

**Course:** INSY 8311 – Database Development with PL/SQL  
**Project:** VoltSwap Multi-Station Electric Car Battery Swapping Management System  
**Student:** NSHIMYUMUKIZA Felicien | Student ID: 20251SEN197  
**Instructor:** Eric Maniraguha | AUCA Faculty of Information Technology  

---

## Slide 1: Title & Project Identity
* **Title:** VoltSwap: Multi-Station Electric Car Battery Swapping Management System
* **Course:** INSY 8311 – Database Development with PL/SQL
* **Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197 | Group B)
* **Academic Year:** 2026–2027 (Semester I)
* **Instructor:** Eric Maniraguha
* **GitHub Repository:** `https://github.com/Feliciencalyx/felicien_20251SEN197_voltSwap`

---

## Slide 2: Background & Problem Statement
* **EV Car Electrification Context:** Passenger cars, electric taxi fleets, and commercial EV sedans require high-uptime operations that 45–60 minute DC fast charging cannot deliver.
* **The Swapping Operational Crisis:**
  * Decentralized car stations operate on disconnected spreadsheets and manual logs.
  * Risk of issuing degraded (SoH < 80%) or uninspected high-voltage battery packs (40–85 kWh) to vehicles.
  * Billing discrepancies between electronic payments (`MTN MoMo`/cards/fleet billing) and energy dispensed.
  * Lack of real-time multi-hub inventory coordination leading to car queues.

---

## Slide 3: Motivation & Justification
* **Why Car Battery Swapping?** Swapping replaces a heavy underbody EV battery pack in under 3 minutes, matching the speed of a traditional petrol refuel.
* **Why Database Centric?** High-voltage automotive packs demand rigorous database-tier safety constraints: tracking thermal health, charge state, and preventing issuance of compromised packs.
* **Alignment with National Goals:** Directly supports Rwanda’s MININFRA E-Mobility Strategic Target transitioning public transport and commercial vehicle fleets to electric.

---

## Slide 4: Project Objectives
* **Main Objective:**
  * To architect and implement an enterprise-grade Oracle relational database using PL/SQL to coordinate safe, real-time, multi-station electric car battery swapping operations.
* **Specific Objectives:**
  1. Design a 3NF normalized relational schema decoupling driver profiles, stations, EV battery packs, inspections, and billing.
  2. Implement atomic PL/SQL stored procedures and packages to automate drive-in car swap processing and tariff calculations.
  3. Enforce database-level safety triggers preventing the dispatch of uninspected or damaged automotive batteries.
  4. Develop an interactive live application layer (Python Streamlit) connected directly to Oracle PDB.

---

## Slide 5: Research & State-of-the-Art Gaps
* **Review of 6 Core Sources:**
  * *Academic Literature (IEEE / ScienceDirect):* Research focuses heavily on electrical grid dispatch algorithms, neglecting transactional safety, fleet billing reconciliation, and audit trails.
  * *Commercial Systems (Nio Power Swap & Ampersand Case Studies):* Demonstrates automated drive-through swap mechanisms requiring strict inventory synchronization.
  * *Empirical Dataset Analysis (EMBSCS 34-Station Logs):* 144,389 swaps across 34 commercial stations, showing wide denormalized formats requiring relational 3NF design.
* **The Gap:** Need for an end-to-end relational schema with automated database-level business constraints for automotive EV battery packs.

---

## Slide 6: Data Sourcing & Raw Quality Audit
* **Dataset:** Empirical operational logs across 34 commercial stations over 92 consecutive days (October–December 2023).
* **Scale:** 144,389 swaps, 3,128 daily station observations per metric.
* **Anonymization:** Driver names mapped to synthetic IDs (`Customer_1001`), phone numbers masked (`+250788***01`).
* **Quality Audit (Counts Identified for Phase IV Cleaning):**
  * Semicolon delimiters across 9 CSV files.
  * Denormalized 34-station wide matrix representation.
  * Decimal representations for integer counts (`19.0`, `44.0`).
  * Embedded formula expressions in Excel sheets.

---

## Slide 7: Proposed Solution & Innovation Layer
* **Central Relational Architecture:** High-availability Oracle Pluggable Database (`b_197_felicien_voltswap_db`).
* **Innovation Layer (8 Marks):**
  * Interactive **Python Streamlit Attendant & Fleet Console** connecting live to Oracle via `python-oracledb`.
  * Allows bay operators to select incoming EV car plates, pick available high-capacity batteries, and invoke stored procedures live.
  * Executive telemetry dashboard visualizing 34-station inventory, throughput leaderboards (`BS199`, `BS233`), and vulnerability ratings.

---

## Slide 8: Relational Database Architecture (3NF)
* **Core Relational Entities:**
  1. `STATIONS` – 34 commercial drive-in swap hubs, districts, and bay capacities.
  2. `STATION_DAILY_METRICS` – 3,128 empirical records (daily throughput, unique batteries, EV cars served).
  3. `STATION_DISRUPTIONS` – Monthly grid outage and disruption logs from `VEF1`.
  4. `BATTERY_MODELS` – High-voltage car battery specs (`VoltCar-40kWh`, `VoltCar-60kWh`, `VoltCar-85kWh`).
  5. `BATTERIES` – Hardware tracking (serials, SoC%, health status, station).
  6. `CUSTOMERS` – EV car owners, commercial taxi drivers, and vehicle registration numbers.
  7. `SWAP_TRANSACTIONS` – Transaction ledger tracking battery-in, battery-out, and energy dispensed.
  8. `PAYMENTS` – Financial settlement ledger (MoMo, Airtel, Cash, Fleet Card).
  9. `BATTERY_INSPECTIONS` – Quality-control log tracking thermal safety, insulation, and technician sign-offs.

---

## Slide 9: PL/SQL Implementation Approach
* **Stored Procedures:**
  * `process_battery_swap(...)`: Executes an atomic transaction updating the incoming pack to `PENDING_INSPECTION`, the outgoing pack to `IN_USE`, and recording the transaction.
* **Stored Functions:**
  * `calculate_swap_fee(...)`: Calculates fees based on net kWh consumed and subscription rates (`PRIVATE_CAR`, `COMMERCIAL_TAXI`, `CORPORATE_FLEET`).
  * `check_station_availability(...)`: Verifies available charged batteries for a given model.
* **Triggers:**
  * `TRG_PREVENT_UNINSPECTED_SWAP`: Blocks swap issuance if the automotive pack has not passed mandatory technical inspection.
  * `TRG_RESTRICT_PAYMENT_MUTATION`: Disallows unauthorized update/deletion of settled financial records outside administrative windows.
* **Packages & Cursors:**
  * `PKG_VOLTSWAP_OPS`: Package encapsulating reconciliation cursors and daily reporting.

---

## Slide 10: Expected Demonstration & Results
* **In-Class Live Demonstration:**
  1. Query PDB status and show all tablespaces online.
  2. Open Streamlit GUI, select car `RAA 101K` and station `BS007`.
  3. Execute a car battery swap live $\rightarrow$ Observe atomic row creation in `SWAP_TRANSACTIONS` and `PAYMENTS`.
  4. Attempt to allocate a failed/uninspected battery $\rightarrow$ Show PL/SQL trigger blocking the transaction with a clear custom error.
  5. Inspect the `AUDIT_LOG` table confirming automatic security recording.

---

## Slide 11: Future Enhancements & Limitations
* **Current Scope:** Core operational car swapping, inventory management, high-voltage inspection gating, and relational billing.
* **Future Work:**
  * Automated robotic car underbody unbolting telemetry integration.
  * Machine learning forecasting model predicting station battery depletion based on commuter traffic and taxi shifts.
  * Integration with commercial fleet card payment APIs.

---

## Slide 12: References (APA 7th)
* EMBSCS Academic Research Consortium. (2024). *Electric Vehicle Battery Swapping and Charging Stations (EMBSCS) Empirical Telemetry Dataset across 34 Stations (October–December 2023)*. GitHub & Zenodo.
* Ministry of Infrastructure (MININFRA), Republic of Rwanda. (2021). *Strategic Paper on Electric Mobility Adaptation in Rwanda*. Kigali: MININFRA.
* Oracle Corporation. (2024). *Oracle Database PL/SQL Language Reference, 19c/21c*. Redwood City, CA: Oracle.
* Revankar, S. R., & Kalkhambkar, V. N. (2023). Grid integration and operational scheduling of battery swapping stations: A comprehensive review. *Journal of Energy Storage*, 41, 102834.
* Zheng, Y., Dong, Z. Y., Xu, Y., Meng, K., & Zhao, J. H. (2024). Electric vehicle battery swapping station management and optimal dispatching. *IEEE Transactions on Smart Grid*, 15(2), 1420–1431.
