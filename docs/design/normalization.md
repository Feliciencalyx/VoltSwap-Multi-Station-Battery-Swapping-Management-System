# Database Normalization: EMBSCS Dataset to Third Normal Form (3NF)

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Project:** VoltSwap Multi-Station Battery Swapping Management System  

---

## 1. Normalization Strategy & Theoretical Framework

The primary objective of relational normalization is to eliminate update, insertion, and deletion anomalies while eliminating data redundancy. Starting from the raw, wide denormalized matrix logs in `data/raw/embscs-dataset-main/`, we progress systematically through **UNF $\rightarrow$ 1NF $\rightarrow$ 2NF $\rightarrow$ 3NF**.

---

## 2. Step 1: Un-Normalized Form (UNF)

In UNF, the raw CSV files (`PI_1_Throughput_October.csv`, etc.) store daily metrics in a wide cross-tabulation format where each row represents one date and 34 repeating station columns contain the metric values.

### Real Sample Data (UNF - Wide Format):

| datetukar | BS007 | BS011 | BS016 | BS059 | BS060 | BS061 | BS084 | ... | BS290 |
|:---|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| 2023-10-01 | 19.0 | 44.0 | 3.0 | 33.0 | 68.0 | 71.0 | 35.0 | ... | 46.0 |
| 2023-10-02 | 24.0 | 48.0 | 10.0 | 45.0 | 72.0 | 75.0 | 38.0 | ... | 52.0 |
| 2023-10-03 | 23.0 | 44.0 | 15.0 | 41.0 | 65.0 | 69.0 | 33.0 | ... | 49.0 |

*Problem:* Adding a new station requires altering the schema (adding a column), and querying multi-station aggregations is difficult.

---

## 3. Step 2: First Normal Form (1NF)

### Transformation Rule
* Eliminate repeating groups across columns by unpivoting (melting) the 34 station columns into atomic, normalized rows.
* Ensure every attribute holds a single atomic scalar value.
* Establish a Composite Primary Key: `(station_id, operation_date)`.

> **Dependency Removed in 1NF:**  
> *Removed repeating groups across station columns by unpivoting daily telemetry into atomic rows identified by composite key `(station_id, operation_date)`.*

### Real Sample Data (1NF):

| station_id | operation_date | swap_throughput | unique_batteries | customers_served | total_bays | distance_m | vuln_score |
|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| BS007 | 2023-10-01 | 19 | 18 | 16 | 8 | 3867 | 0.575 |
| BS011 | 2023-10-01 | 44 | 36 | 34 | 6 | 672 | 0.912 |
| BS016 | 2023-10-01 | 3 | 3 | 3 | 7 | 943 | 0.971 |
| BS007 | 2023-10-02 | 24 | 22 | 20 | 8 | 3867 | 0.575 |
| BS011 | 2023-10-02 | 48 | 41 | 38 | 6 | 672 | 0.912 |

---

## 4. Step 3: Second Normal Form (2NF)

### Transformation Rule
* Satisfy all 1NF conditions.
* Remove **partial functional dependencies**: attributes that depend only on `station_id` (and not on `operation_date`) are separated into the parent entity `STATIONS`.
  * `station_id` $\rightarrow$ `total_bays`, `distance_m`, `vuln_score`, `district`, `station_name`.
  * `(station_id, operation_date)` $\rightarrow$ `swap_throughput`, `unique_batteries`, `customers_served`, `avg_swap_time`, `avg_soc`.

> **Dependency Removed in 2NF:**  
> *Removed partial functional dependencies where station physical specifications and vulnerability ratings depended solely on `station_id` rather than the composite station-day key.*

### Real Sample Data (2NF Relations):

#### Relation 1: `STATIONS`
| station_id | station_code | total_bays | distance_to_hub_m | vulnerability_score | district |
|:---|:---|:---:|:---:|:---:|:---|
| BS007 | BS007 | 8 | 3867 | 0.575 | Nyarugenge |
| BS011 | BS011 | 6 | 672 | 0.912 | Gasabo |
| BS016 | BS016 | 7 | 943 | 0.971 | Kicukiro |

#### Relation 2: `STATION_DAILY_METRICS`
| station_id (FK) | operation_date | swap_throughput | unique_batteries_swapped | customers_served |
|:---|:---|:---:|:---:|:---:|
| BS007 | 2023-10-01 | 19 | 18 | 16 |
| BS011 | 2023-10-01 | 44 | 36 | 34 |
| BS016 | 2023-10-01 | 3 | 3 | 3 |

---

## 5. Step 4: Third Normal Form (3NF)

### Transformation Rule
* Satisfy all 2NF conditions.
* Remove **transitive functional dependencies**: non-key attributes depending on other non-key attributes ($X \rightarrow Y \rightarrow Z$) are isolated into independent relational tables:
  * In `BATTERIES`: Model attributes (`capacity_kwh`, `nominal_voltage`, `rated_cycles`) depend on `model_id`, not on physical `battery_id`. Moved to `BATTERY_MODELS`.
  * In `STATIONS`: Operational disruption incidents recorded across months (`VEF1`) constitute an independent event lifecycle. Moved to `STATION_DISRUPTIONS`.
  * In `SWAP_TRANSACTIONS`: Financial receipts and payment methods depend on the payment event. Moved to `PAYMENTS`.
  * In `SWAP_TRANSACTIONS`: Quality test results depend on the physical inspection event. Moved to `BATTERY_INSPECTIONS`.

> **Dependency Removed in 3NF:**  
> *Removed transitive dependencies where station outage logs, battery model engineering specifications, and financial settlement records depended on intermediate non-key attributes.*

---

## 6. Final 3NF Relations with Real Data Rows

### Table 1: `STATIONS` (34 Commercial Swapping Hubs)
*Primary Key: `station_id`*

| station_id | station_code | station_name | district | total_bays | distance_to_hub_m | vulnerability_score | status |
|:---|:---|:---|:---|:---:|:---:|:---:|:---|
| BS007 | BS007 | VoltSwap Station BS007 | Nyarugenge | 8 | 3867 | 0.575 | ACTIVE |
| BS011 | BS011 | VoltSwap Station BS011 | Gasabo | 6 | 672 | 0.912 | ACTIVE |
| BS016 | BS016 | VoltSwap Station BS016 | Kicukiro | 7 | 943 | 0.971 | ACTIVE |
| BS059 | BS059 | VoltSwap Station BS059 | Nyarugenge | 9 | 9225 | 0.538 | ACTIVE |

---

### Table 2: `STATION_DAILY_METRICS` (3,128 Real Observations)
*Primary Key: `metric_id` | Foreign Key: `station_id` $\rightarrow$ `STATIONS`*

| metric_id | station_id | operation_date | swap_throughput | unique_batteries_swapped | customers_served | avg_swap_time_min | avg_soc_pct |
|:---:|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | BS007 | 2023-10-01 | 19 | 18 | 16 | 1.34 | 14.7 |
| 2 | BS011 | 2023-10-01 | 44 | 36 | 34 | 1.38 | 14.3 |
| 3 | BS016 | 2023-10-01 | 3 | 3 | 3 | 1.42 | 12.5 |
| 4 | BS059 | 2023-10-01 | 33 | 28 | 25 | 1.42 | 12.7 |

---

### Table 3: `STATION_DISRUPTIONS` (Outage Telemetry from VEF1)
*Primary Key: `disruption_id` | Foreign Key: `station_id` $\rightarrow$ `STATIONS`*

| disruption_id | station_id | month_recorded | outage_count | remarks |
|:---:|:---|:---|:---:|:---|
| 1 | BS007 | 2023-10 | 1 | October operational disruption events logged |
| 2 | BS007 | 2023-11 | 1 | November operational disruption events logged |
| 3 | BS007 | 2023-12 | 8 | December operational disruption events logged |
| 4 | BS011 | 2023-10 | 7 | October operational disruption events logged |

---

### Table 4: `BATTERY_MODELS`
*Primary Key: `model_id`*

| model_id | model_name | capacity_kwh | nominal_voltage | rated_cycles |
|:---|:---|:---:|:---|:---:|
| MOD_01 | VoltCore-48V | 3.2 | 48V | 1500 |
| MOD_02 | VoltMax-60V | 4.5 | 60V | 2000 |
| MOD_03 | VoltPro-72V | 5.8 | 72V | 2200 |

---

### Table 5: `BATTERIES`
*Primary Key: `battery_id` | Foreign Keys: `model_id`, `current_station_id`*

| battery_id | serial_number | model_id | current_station_id | current_soc_pct | health_status | total_swaps |
|:---|:---|:---|:---|:---:|:---|:---:|
| BAT_0001 | BAT-0001 | MOD_01 | BS007 | 95 | CHARGED | 12 |
| BAT_0002 | BAT-0002 | MOD_01 | BS011 | 95 | CHARGED | 12 |
| BAT_0003 | BAT-0003 | MOD_01 | BS016 | 15 | PENDING_INSPECTION | 12 |

---

### Table 6: `CUSTOMERS`
*Primary Key: `customer_id`*

| customer_id | customer_name | customer_phone | vehicle_plate | registration_date | account_status |
|:---|:---|:---|:---|:---|:---|
| CUST_1001 | Customer_1001 | +250788000001 | RAA 101K | 2023-09-01 | ACTIVE |
| CUST_1002 | Customer_1002 | +250788000002 | RAB 102K | 2023-09-01 | ACTIVE |
| CUST_1003 | Customer_1003 | +250788000003 | RAC 103K | 2023-09-01 | ACTIVE |

---

### Table 7: `SWAP_TRANSACTIONS`
*Primary Key: `swap_id` | Foreign Keys: `customer_id`, `station_id`, `battery_in_id`, `battery_out_id`*

| swap_id | customer_id | station_id | battery_in_id | battery_out_id | energy_kwh | swap_time | attendant_name |
|:---|:---|:---|:---|:---|:---:|:---|:---|
| SWP_10001 | CUST_1001 | BS007 | BAT_0003 | BAT_0001 | 2.56 | 2023-10-01 08:30:00 | Attendant_BS007 |
| SWP_10002 | CUST_1002 | BS011 | BAT_0006 | BAT_0002 | 2.68 | 2023-10-01 09:15:00 | Attendant_BS011 |
