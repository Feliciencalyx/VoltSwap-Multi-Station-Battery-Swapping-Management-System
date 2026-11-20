# Logical Entity-Relationship Diagram (ERD) Specification

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Deliverable:** `docs/design/erd.png` (Crow's-Foot Notation)  

---

## 1. Crow's-Foot Relational Architecture

The logical data model consists of 7 normalized entities structured in Third Normal Form (3NF).

```
 +------------------+           1:N           +---------------------+
 |    CUSTOMERS     |------------------------<|  SWAP_TRANSACTIONS  |
 +------------------+                         +---------------------+
 | PK  customer_id  |                                    | 1:1
 |     customer_name|                                    |
 |     phone_number |                                    v
 |     vehicle_plate|                         +---------------------+
 +------------------+                         |      PAYMENTS       |
                                              +---------------------+
                                              | PK  payment_id      |
 +------------------+           1:N           | FK  swap_id         |
 |     STATIONS     |------------------------<|     amount_rwf      |
 +------------------+                         |     payment_method  |
 | PK  station_id   |                         |     payment_status  |
 |     station_name |                         +---------------------+
 |     district     |
 |     total_bays   |
 +------------------+
          |
          | 1:N (stocks currently)
          v
 +------------------+           1:N           +---------------------+
 |    BATTERIES     |------------------------<| BATTERY_INSPECTIONS |
 +------------------+                         +---------------------+
 | PK  battery_id   |                         | PK  inspection_id   |
 |     serial_number|                         | FK  battery_id      |
 | FK  model_id     |                         |     inspector_name  |
 | FK  station_id   |                         |     inspection_date |
 |     current_soc  |                         |     physical_result |
 |     status       |                         +---------------------+
 +------------------+
          ^
          | N:1
 +------------------+
 |  BATTERY_MODELS  |
 +------------------+
 | PK  model_id     |
 |     model_name   |
 |     capacity_kwh |
 |     nominal_volt |
 +------------------+
```

---

## 2. Cardinality and Optionality Matrix

1. **CUSTOMERS to SWAP_TRANSACTIONS:**
   * One customer may make zero, one, or many swap transactions ($0..N$).
   * Each swap transaction must be initiated by exactly one registered customer ($1..1$).
   * *Notation:* One mandatory end at `CUSTOMERS`, zero-to-many optional end at `SWAP_TRANSACTIONS`.

2. **STATIONS to SWAP_TRANSACTIONS:**
   * One station hosts zero, one, or many swap transactions ($0..N$).
   * Each swap transaction must occur at exactly one physical station hub ($1..1$).

3. **BATTERY_MODELS to BATTERIES:**
   * One model specification classifies zero, one, or many physical battery packs ($0..N$).
   * Each physical battery pack must be an instance of exactly one model specification ($1..1$).

4. **BATTERIES to SWAP_TRANSACTIONS (Dual Relationship):**
   * *Returned Battery (`battery_in_id`):* Each swap logs exactly one returned battery. A physical battery may be returned zero, one, or multiple times over its lifecycle.
   * *Issued Battery (`battery_out_id`):* Each swap logs exactly one issued battery. A physical battery may be issued zero, one, or multiple times.

5. **SWAP_TRANSACTIONS to PAYMENTS:**
   * Each completed swap transaction corresponds to exactly one payment record ($1..1$).
   * Each payment record is strictly bound to exactly one parent swap transaction ($1..1$).

6. **BATTERIES to BATTERY_INSPECTIONS:**
   * One physical battery pack undergoes zero, one, or many safety inspections over time ($0..N$).
   * Each inspection record pertains to exactly one physical battery pack ($1..1$).

---

## 3. How to Save `erd.png`
You can open **draw.io**, select **Entity Relationship** shapes from the left panel, assemble the 7 boxes with crow's-foot connectors as specified above, and export as **PNG** directly into:  
`docs/design/erd.png`
