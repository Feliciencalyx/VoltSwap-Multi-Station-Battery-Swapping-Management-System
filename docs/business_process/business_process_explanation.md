# Business Process Explanation: VoltSwap Electric Car Battery Swapping Operations

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Phase:** Phase I – Business Process Modeling  
**Organization:** VoltSwap Technologies Ltd.  

---

## 1. Process Overview & Initiation
The VoltSwap business process coordinates the operational lifecycle of electric car battery swapping across 34 commercial drive-in stations. The process begins when an electric car driver (Private EV Owner or Commercial Taxi Driver) drives their vehicle into an automated swapping bay with a depleted battery pack (40–85 kWh). The primary goal is to perform a safe, automated exchange for a fully conditioned, charged battery pack in under three minutes, while capturing energy consumption metrics, executing financial settlement, and logging high-voltage safety inspections.

---

## 2. Actors and Step-by-Step Activity Progression

The workflow spans five distinct swimlanes operating in synchronized sequence:

### Swimlane 1: Customer (Electric Car Driver / Taxi Fleet Driver)
1. **Arrival & Bay Entry:** The driver positions the electric car on the automated bay alignment guide and presents their vehicle registration plate and customer credentials to the bay terminal.
2. **Review & Payment:** Upon receiving the calculated energy replenishment quote, the driver approves the transaction and executes payment via mobile money (`MTN MoMo` or `Airtel Money`), credit card, or fleet account.
3. **Automated Exchange & Departure:** The vehicle underbody automated swap mechanism completes the pack replacement. The driver confirms dashboard battery diagnostics and departs the bay.

### Swimlane 2: Station Attendant / Bay Operator
1. **Intake Scanning:** Scans the vehicle RFID / barcode on the depleted battery pack and verifies vehicle registration plate.
2. **Console Verification:** Submits the swap request through the station terminal to verify stock availability of compatible car battery packs (e.g. `VoltCar-40kWh`, `VoltCar-60kWh`, `VoltCar-85kWh`).
3. **Swap Oversight:** Initiates and monitors the automated underbody battery exchange sequence, ensuring safe detachment of the depleted pack and secure latching of the replacement pack.

### Swimlane 3: High-Voltage Quality & Safety Technician
1. **Intake Triage & Diagnostic Inspection:** Evaluates the returned car pack on the diagnostic test bench for thermal stability, structural enclosure damage, and high-voltage insulation resistance.
2. **Cell Voltage & Degradation Test:** Analyzes cell voltage balance and cycle degradation metrics.
3. **Verdict Submission:** Records the formal inspection result (`PASSED`, `MINOR_MAINTENANCE`, or `FAILED_DEGRADED`) in the terminal. If passed, the battery is slotted into the automated charging rack; if degraded, it is locked into the maintenance depot.

### Swimlane 4: System / Database Engine (Oracle PL/SQL)
1. **Stock Query `[RETRIEVE]`:** Checks table `BATTERIES` for available packs matching the vehicle's model where `status = 'CHARGED'` and `SoC >= 90%`.
2. **Fee Computation `[RETRIEVE/CALCULATE]`:** Executes function `calculate_swap_fee` taking the delta between returned SoC% and issued SoC% multiplied by the tariff rate, applying fleet/taxi discounts.
3. **Atomic Execution `[CREATE / UPDATE]`:** 
   * Updates returned car battery status to `'PENDING_INSPECTION'` `[UPDATE]`.
   * Updates issued car battery status to `'IN_USE'` `[UPDATE]`.
   * Inserts row into `SWAP_TRANSACTIONS` `[CREATE]`.
   * Inserts row into `PAYMENTS` `[CREATE]`.
4. **Safety Enforcement (Trigger):** Automatically blocks any attempt to allocate a battery lacking an approved inspection clearance or with SoC < 90%.

### Swimlane 5: Station & Fleet Operations Manager
1. **Monitoring & Auditing:** Reviews live dashboard metrics regarding 34-station inventory balance, bay throughput, peak hours, and revenue collections.
2. **Log Review:** Examines the security `AUDIT_LOG` and station disruption reports (`VEF1`) to schedule preventive rack maintenance and logistics rebalancing between hubs.

---

## 3. Decision Points and Alternative Paths
* **Decision 1: Compatible Car Battery Availability:**
  * *Path A (In Stock):* If compatible charged packs exist at the station, proceed directly to swap authorization.
  * *Path B (Stock Depleted):* If no charged pack is available, the system alerts the driver, identifies the nearest neighboring station with stock (via `VDF8` distance metrics), and offers an immediate reservation.
* **Decision 2: Payment Settlement:**
  * *Path A (Successful):* System receives confirmation code, marks `payment_status = 'COMPLETED'`, and authorizes the bay lock release.
  * *Path B (Failed/Cancelled):* Driver is prompted for alternate payment. If unresolved, the swap is aborted and records rolled back.
* **Decision 3: Battery Inspection Assessment:**
  * *Path A (Passed):* Battery is plugged into the automated charging cabinet and transitions to `'CHARGING'`.
  * *Path B (Defect Detected):* Battery is locked from the charging pool, transitions to `'MAINTENANCE'`, and is flagged for depot technician collection.

---

## 4. Operational and Decision-Making Impact
This integrated process eliminates manual errors and inventory shortages. By centralizing operational data in Oracle PL/SQL, management achieves real-time inventory visibility across all 34 commercial stations, prevents battery failure hazards through enforced safety triggers, and guarantees accounting reconciliation between energy dispensed and collected revenue.
