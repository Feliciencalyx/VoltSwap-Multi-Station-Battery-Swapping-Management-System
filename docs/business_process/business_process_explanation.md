# Business Process Explanation: VoltSwap Battery Swapping & Lifecycle Operations

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Phase:** Phase I – Business Process Modeling  
**Organization:** VoltSwap Technologies Ltd.  

---

## 1. Process Overview & Initiation
The VoltSwap business process coordinates the operational lifecycle of battery swapping across multi-hub metropolitan stations. The process begins when an electric motorcycle driver (Customer) arrives at a VoltSwap station with a depleted battery pack. The primary goal is to perform a safe, verified exchange for a fully charged battery in under three minutes, while capturing energy consumption metrics, executing financial settlement, and logging safety inspections.

---

## 2. Actors and Step-by-Step Activity Progression

The workflow spans five distinct swimlanes operating in synchronized sequence:

### Swimlane 1: Customer (Rider)
1. **Arrival & Request:** The rider drives into the swapping bay and presents their motorcycle registration and battery serial to the station attendant.
2. **Review & Payment:** Upon receiving the calculated energy replenishment quote, the rider approves the transaction and executes payment via mobile money (`MTN MoMo` or `Airtel Money`) or cash.
3. **Receipt & Departure:** The customer receives the fully charged battery, mounts it in the vehicle, and departs.

### Swimlane 2: Station Attendant
1. **Intake Scanning:** Scans the barcode/QR code on the returned depleted battery and records the incoming customer ID.
2. **Console Verification:** Submits the swap request through the station terminal to verify stock availability.
3. **Physical Swap Execution:** Unlocks the designated charging bay, extracts the allocated charged battery pack, places the depleted pack into the intake buffer, and hands the replacement battery to the customer.

### Swimlane 3: Inspection Staff (Quality & Safety Technician)
1. **Triage & Physical Inspection:** Evaluates the returned depleted pack for physical casing integrity, terminal pin wear, and thermal anomalies.
2. **Bench Testing:** Measures open-circuit voltage and internal resistance on the diagnostic testing bench.
3. **Verdict Submission:** Records the formal inspection result (`PASSED`, `MINOR_MAINTENANCE`, or `FAILED_DEGRADED`) in the terminal. If passed, the battery is queued for charging; if damaged, it is routed to the technical repair depot.

### Swimlane 4: System / Database Engine (Oracle PL/SQL)
1. **Stock Query `[RETRIEVE]`:** Checks table `BATTERIES` for available packs matching the requested model where `status = 'CHARGED'` and `SoC >= 90%`.
2. **Fee Computation `[RETRIEVE/CALCULATE]`:** Executes function `calculate_swap_fee` taking the delta between returned SoC% and issued SoC% multiplied by the current tariff rate.
3. **Atomic Execution `[CREATE / UPDATE]`:** 
   * Updates returned battery status to `'PENDING_INSPECTION'` `[UPDATE]`.
   * Updates issued battery status to `'IN_USE'` `[UPDATE]`.
   * Inserts row into `SWAP_TRANSACTIONS` `[CREATE]`.
   * Inserts row into `PAYMENTS` `[CREATE]`.
4. **Safety Enforcement (Trigger):** Automatically intercepts any attempt to allocate a battery lacking an approved inspection clearance.

### Swimlane 5: Station & Operations Manager
1. **Monitoring & Auditing:** Reviews live dashboard metrics regarding station inventory balance, peak swap volumes, and revenue collections.
2. **Log Review:** Examines the security `AUDIT_LOG` and inspection exception reports to schedule preventive battery maintenance and fleet rebalancing.

---

## 3. Decision Points and Alternative Paths
* **Decision 1: Battery Availability Check:**
  * *Path A (In Stock):* If compatible charged batteries exist at the station, proceed directly to swap authorization.
  * *Path B (Stock Depleted):* If no charged pack is available, the system alerts the attendant, identifies the nearest neighboring station with stock (e.g., Remera vs. Kimironko), and offers the customer an immediate transfer or reservation.
* **Decision 2: Payment Settlement:**
  * *Path A (Successful):* System receives gateway confirmation code, marks `payment_status = 'COMPLETED'`, and unlocks the bay.
  * *Path B (Failed/Cancelled):* Attendant offers alternate payment method (e.g., Cash or secondary MoMo wallet). If unresolvable, the swap is aborted and records rolled back.
* **Decision 3: Battery Inspection Assessment:**
  * *Path A (Passed):* Battery is plugged into the automated charging rack and status transitions to `'CHARGING'`.
  * *Path B (Defect Detected):* Battery is locked from the charging pool, status transitions to `'MAINTENANCE'`, and an alert is flagged for depot technician collection.

---

## 4. Operational and Decision-Making Impact
This integrated process eliminates manual data entry errors and inventory hoarding. By centralizing the operational data in Oracle PL/SQL, management achieves real-time inventory visibility across Kigali, prevents defective battery hazards through enforced safety triggers, and guarantees accounting reconciliation between energy dispensed and collected revenue.
