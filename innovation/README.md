# VoltSwap Innovation Layer: Interactive Electric Car Swapping & Operations Console

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Instructor:** Eric Maniraguha  
**Grade Component:** Innovation Layer (8 of 40 Marks)  

---

## 1. Executive Summary & Problem Fit (2 Marks)
In high-throughput urban electric car battery swapping stations, bay operators and fleet dispatchers cannot navigate complex database consoles while passenger cars and electric taxi fleets queue in drive-in bays. The VoltSwap Innovation Layer provides a dedicated, lightweight web console powered by Python Streamlit and `python-oracledb`. 

It enables:
* Real-time 34-station high-capacity car battery inventory tracking (Charged vs Charging vs Maintenance).
* Point-of-sale car swap execution invoking the `process_battery_swap` PL/SQL stored procedure with a single click.
* Live enforcement of high-voltage safety triggers (blocking issuance of uninspected or degraded automotive packs).
* Telemetry for fleet managers monitoring energy dispensed (kWh), revenue collected (RWF), and station vulnerability indices (`Table D.1`).

---

## 2. Oracle Database Connection Architecture (3 Marks)
The application connects directly to the project's Oracle Pluggable Database (`b_197_felicien_voltswap_db`) using `python-oracledb` Thin Mode:
* **Host:** `localhost`
* **Port:** `1521`
* **Service Name / PDB:** `b_197_felicien_voltswap_db`
* **User:** `felicien_admin`
* **Password:** `felicien`

All business logic (energy tariff calculations, customer fleet tier discounts, inventory transitions, and safety constraints) remains strictly inside Oracle PL/SQL packages and triggers. The Streamlit interface acts solely as an operational and presentation client.

---

## 3. How to Run the Innovation App (2 Marks)

### Step 1: Install Dependencies
Open your terminal / PowerShell in the project directory:
```powershell
py -3.10 -m pip install -r innovation/requirements.txt
```

### Step 2: Launch the Streamlit Console
```powershell
py -3.10 -m streamlit run innovation/app.py
```
The application will launch in your default web browser at `http://localhost:8501`.

---

## 4. Demonstration Features for the Final Exam Defense
1. **Live 34-Station Telemetry:** Explore real-time metrics across 34 commercial hubs, viewing cumulative 92-day swaps and arrival State of Charge ($11\%–16\%$).
2. **Execute Car Swap:** Select incoming electric car plate `RAA 101K` at station `BS007`. Observe the committed transaction JSON proving the Oracle PL/SQL procedure executed.
3. **Trigger Violation Demo:** Attempt to allocate an uninspected battery $\rightarrow$ Show the user interface catching the Oracle trigger exception and preventing dangerous issuance.
4. **Vulnerability & Outage Tracking:** Review the station disruption table and vulnerability scores across October, November, and December.
