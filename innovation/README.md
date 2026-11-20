# VoltSwap Innovation Layer: Interactive Attendant & Operations Console

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Instructor:** Eric Maniraguha  
**Grade Component:** Innovation Layer (8 of 40 Marks)  

---

## 1. Executive Summary & Problem Fit (2 Marks)
In high-throughput urban swapping hubs, station attendants cannot navigate SQL Developer or command-line terminals while riders wait in queues. The VoltSwap Innovation Layer provides a dedicated, lightweight web console powered by Python Streamlit and `python-oracledb`. 

It enables:
* Real-time multi-hub battery inventory tracking (Charged vs Charging vs Maintenance).
* Attendant point-of-sale execution invoking the `process_battery_swap` PL/SQL stored procedure with a single click.
* Live enforcement of safety triggers (preventing issuance of degraded or uninspected packs).
* Live telemetry for operations managers monitoring energy dispensed (kWh) and revenue collected (RWF).

---

## 2. Oracle Database Connection Architecture (3 Marks)
The application connects directly to the project's Oracle Pluggable Database (`b_197_felicien_voltswap_db`) using `python-oracledb` Thin Mode:
* **Host:** `localhost`
* **Port:** `1521`
* **Service Name / PDB:** `b_197_felicien_voltswap_db`
* **User:** `felicien_admin`
* **Password:** `felicien`

All business logic (energy tariff calculations, inventory transitions, and safety constraints) remains strictly inside Oracle PL/SQL packages and triggers. The Streamlit interface acts solely as an operational and presentation client.

---

## 3. How to Run the Innovation App (2 Marks)

### Step 1: Install Dependencies
Open your terminal / PowerShell in the project directory and install the requirements:
```powershell
pip install -r innovation/requirements.txt
```

### Step 2: Configure Database Credentials (Optional)
By default, the application connects to `localhost:1521/b_197_felicien_voltswap_db` using `felicien_admin`. You can override these using environment variables:
```powershell
$env:DB_USER = "felicien_admin"
$env:DB_PASS = "felicien"
$env:DB_HOST = "localhost"
$env:DB_PORT = "1521"
$env:DB_SERVICE = "b_197_felicien_voltswap_db"
```

### Step 3: Launch the Streamlit Console
```powershell
streamlit run innovation/app.py
```
The application will launch in your default web browser at `http://localhost:8501`.

---

## 4. Demonstration Features for the Final Exam Defense
1. **Live Inventory Telemetry:** Switch between Kigali Central Hub, Remera, and Kimironko to observe available charged units.
2. **Execute Swap:** Submit a new battery swap for customer `CUST_1042`. Observe the returned confirmation JSON proving the database transaction committed.
3. **Trigger Violation Demo:** Attempt to allocate an uninspected battery $\rightarrow$ Show the user interface catching the Oracle trigger exception and preventing dangerous issuance.
4. **Audit Trail Review:** Inspect the live audit table displaying security logs and blocked operations.
