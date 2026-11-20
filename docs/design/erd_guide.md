# Logical Entity-Relationship Diagram (ERD) Specification: EMBSCS Integrated

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Deliverable:** `docs/design/erd.png` (Crow's-Foot Notation)  

---

## 1. Relational Architecture Diagram

```
       +-----------------------+              1:N
       |  STATION_DISRUPTIONS  |<-----------------------------+
       +-----------------------+                              |
       | PK disruption_id      |                              |
       | FK station_id         |                              |
       |    outage_count       |                              |
       +-----------------------+                              |
                                                              |
       +-----------------------+              1:N             |
       | STATION_DAILY_METRICS |<-----------------------------+
       +-----------------------+                              |
       | PK metric_id          |                              |
       | FK station_id         |                              |
       |    operation_date     |                              |
       |    swap_throughput    |                              |
       |    unique_batteries   |                              |
       +-----------------------+                              |
                                                              |
 +------------------+           1:N           +---------------+-----+           1:N           +---------------------+
 |    CUSTOMERS     |------------------------<|  SWAP_TRANSACTIONS  |>------------------------|      STATIONS       |
 +------------------+                         +---------------------+                         +---------------------+
 | PK  customer_id  |                         | PK  swap_id         |                         | PK  station_id      |
 |     customer_name|                         | FK  customer_id     |                         |     station_name    |
 |     customer_phone                         | FK  station_id      |                         |     district        |
 |     vehicle_plate|                         | FK  battery_in_id   |                         |     total_bays      |
 +------------------+                         | FK  battery_out_id  |                         |     vulnerability   |
                                              +---------------------+                         +---------------------+
                                                         | 1:1                                           |
                                                         v                                               | 1:N (stocks)
                                              +---------------------+                                    v
                                              |      PAYMENTS       |                         +---------------------+
                                              +---------------------+                         |      BATTERIES      |
                                              | PK  payment_id      |                         +---------------------+
                                              | FK  swap_id         |                         | PK  battery_id      |
                                              |     amount_rwf      |                         |     serial_number   |
                                              |     payment_method  |                         | FK  model_id        |
                                              +---------------------+                         | FK  current_station |
                                                                                              |     current_soc_pct |
                                                                                              +---------------------+
                                                                                                 ^             |
                                                                                      N:1 (spec) |             | 1:N
                                                                                                 |             v
                                                                                      +----------+---+   +-----+---------------+
                                                                                      |BATTERY_MODELS|   | BATTERY_INSPECTIONS |
                                                                                      +--------------+   +---------------------+
                                                                                      |PK model_id   |   | PK  inspection_id   |
                                                                                      |   model_name |   | FK  battery_id      |
                                                                                      |   capacity   |   |     physical_result |
                                                                                      +--------------+   +---------------------+
```

---

## 2. Cardinality & Optionality Matrix

1. **`STATIONS` to `STATION_DAILY_METRICS`:**
   * One station records multiple daily telemetry observations ($1..N$).
   * Each daily metric record is strictly associated with exactly one physical station ($1..1$).
2. **`STATIONS` to `STATION_DISRUPTIONS`:**
   * One station may experience zero, one, or several disruption events ($0..N$).
   * Each disruption log references exactly one station ($1..1$).
3. **`STATIONS` to `BATTERIES`:**
   * One station currently holds zero, one, or multiple batteries in its charging compartments ($0..N$).
   * A battery is held at one station or is in transit/on road (optional foreign key $0..1$).
4. **`CUSTOMERS` to `SWAP_TRANSACTIONS`:**
   * A registered customer executes zero, one, or multiple battery swaps ($0..N$).
   * Each swap transaction is initiated by exactly one registered customer ($1..1$).
5. **`SWAP_TRANSACTIONS` to `PAYMENTS`:**
   * Each swap transaction requires exactly one financial settlement record ($1..1$).
6. **`BATTERIES` to `BATTERY_INSPECTIONS`:**
   * A physical battery pack undergoes periodic safety inspections ($0..N$).
   * Each inspection log evaluates exactly one battery pack ($1..1$).
