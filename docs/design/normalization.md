# Database Normalization: From Raw Logs to Third Normal Form (3NF)

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Project:** VoltSwap Multi-Station Battery Swapping Management System  

---

## 1. Normalization Strategy & Theoretical Framework

The primary objective of relational normalization is to eliminate update, insertion, and deletion anomalies while eliminating data redundancy. Starting from the flat, denormalized operational feed in `data/raw/raw_battery_swaps.csv`, we progress systematically through **UNF $\rightarrow$ 1NF $\rightarrow$ 2NF $\rightarrow$ 3NF**.

---

## 2. Step 1: Un-Normalized Form (UNF)

In UNF, a single swap log contains repeating and nested entities (customer details, station metadata, multiple battery hardware units, payment records, and inspection logs) stored in a wide structure.

### Real Sample Data (UNF - 3 Rows):

| swap_id | customer_id | customer_name | customer_phone | vehicle_plate | station_name | station_district | battery_returned_serial | returned_soc | battery_issued_serial | issued_soc | battery_model | model_capacity | energy_consumed | fee_amount | payment_method | payment_status | swap_time | attendant_name | inspection_result | inspection_notes |
|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|:---|
| SWP_10001 | CUST_1082 | Customer_1082 | +250788***82 | RAF 182M | Kigali Central Hub | NYARUGENGE | BAT-0163 | 12 | BAT-0408 | 93 | VoltCore-48V | 3.2 kWh | 2.59 kWh | 2331 RWF | CASH | COMPLETED | 2026-11-01 22:16:00 | Chantal_U | PASSED | Inspected by Chantal_U: PASSED. Terminal check ok. |
| SWP_10002 | CUST_1004 | Customer_1004 | +250788***04 | RAE 104M | Kigali Central Hub | nyarugenge | BAT-0230 | 8 | BAT-0505 | 100 | VoltCore-48V | 3.2 kWh | 2.94 kWh | 2646 RWF | CASH | COMPLETED | 2026-09-19 10:22:00 | Chantal_U | MINOR_SCRATCH | Needs bench check: MINOR_SCRATCH |
| SWP_10003 | CUST_1036 | Customer_1036 | +250788***36 | RAB 136E | Kigali Central Hub | Nyarugenge Hub | BAT-0188 | 12 | BAT-0422 | 95 | VoltCore-48V | 3.2 kWh | 2.66 kWh | 2394 RWF | MTN_MOMO | COMPLETED | 2026-10-01 23:18:00 | Jean_Pierre_N | PASSED | Inspected by Jean_Pierre_N: PASSED. Terminal check ok. |

---

## 3. Step 2: First Normal Form (1NF)

### Transformation Rule
* Remove repeating groups, multi-valued attributes, and non-atomic fields.
* Ensure every column holds a single scalar value.
* Establish a Primary Key: `(swap_id)`.

> **Dependency Removed in 1NF:**  
> *Removed repeating groups and composite attributes so that every attribute contains an atomic scalar value and every record is uniquely identified.*

### Real Sample Data (1NF):
Every swap record is an atomic row with identified composite key and scalar values.

---

## 4. Step 3: Second Normal Form (2NF)

### Transformation Rule
* Meet all 1NF conditions.
* Remove **partial functional dependencies**: attributes that depend on only part of a composite key must be moved into their own dedicated relations.
  * Customer attributes (`customer_name`, `customer_phone`, `vehicle_plate`) depend strictly on `customer_id`.
  * Station attributes (`station_name`, `station_district`) depend strictly on `station_id`.
  * Battery attributes (`battery_model`, `model_capacity`) depend strictly on the battery specification.

> **Dependency Removed in 2NF:**  
> *Removed partial functional dependencies where customer, station, and battery specifications depended on only subsets of operational transaction identifiers.*

### Relations Formed in 2NF:
1. `CUSTOMERS` (`customer_id`, `customer_name`, `customer_phone`, `vehicle_plate`)
2. `STATIONS` (`station_id`, `station_name`, `station_district`)
3. `BATTERIES` (`battery_serial`, `battery_model`, `model_capacity`, `current_soc`)
4. `SWAP_OPERATIONS` (`swap_id`, `customer_id`, `station_id`, `battery_returned_serial`, `battery_issued_serial`, `energy_consumed`, `fee_amount`, `payment_method`, `payment_status`, `swap_time`, `inspection_result`, `inspection_notes`)

---

## 5. Step 4: Third Normal Form (3NF)

### Transformation Rule
* Meet all 2NF conditions.
* Remove **transitive functional dependencies**: non-key attributes that depend on other non-key attributes ($X \rightarrow Y \rightarrow Z$) must be isolated into independent lookup and transaction entities:
  * In `BATTERIES`: `model_capacity` depends on `battery_model`, not directly on the physical `battery_serial`. Moved to `BATTERY_MODELS`.
  * In `SWAP_OPERATIONS`: Financial settlement attributes (`payment_method`, `payment_status`, `fee_amount`) constitute an independent payment lifecycle, moved to `PAYMENTS`.
  * In `SWAP_OPERATIONS`: Inspection outcomes and notes represent a physical testing event performed on the returned battery, moved to `BATTERY_INSPECTIONS`.

> **Dependency Removed in 3NF:**  
> *Removed transitive dependencies where battery capacity depended on model rather than battery serial, and where payment and inspection lifecycles depended transitively on swap events.*

---

## 6. Final 3NF Entity Schemas with Real Data Rows

### Table 1: `CUSTOMERS`
*Primary Key: `customer_id`*

| customer_id | customer_name | customer_phone | vehicle_plate |
|:---|:---|:---|:---|
| CUST_1082 | Customer_1082 | +250788***82 | RAF 182M |
| CUST_1004 | Customer_1004 | +250788***04 | RAE 104M |
| CUST_1036 | Customer_1036 | +250788***36 | RAB 136E |

---

### Table 2: `STATIONS`
*Primary Key: `station_id`*

| station_id | station_name | district | total_bays | status |
|:---|:---|:---|:---|:---|
| STN_01 | Kigali Central Hub | Nyarugenge | 24 | ACTIVE |
| STN_02 | Remera Express | Gasabo | 18 | ACTIVE |
| STN_03 | Kimironko Station | Gasabo | 16 | ACTIVE |

---

### Table 3: `BATTERY_MODELS`
*Primary Key: `model_id`*

| model_id | model_name | capacity_kwh | nominal_voltage | rated_cycles |
|:---|:---|:---|:---|:---|
| MOD_01 | VoltCore-48V | 3.2 | 48V | 1500 |
| MOD_02 | VoltMax-60V | 4.5 | 60V | 2000 |
| MOD_03 | VoltPro-72V | 5.8 | 72V | 2200 |

---

### Table 4: `BATTERIES`
*Primary Key: `battery_id` | Foreign Keys: `model_id` $\rightarrow$ `BATTERY_MODELS`, `current_station_id` $\rightarrow$ `STATIONS`*

| battery_id | serial_number | model_id | current_station_id | current_soc_pct | status |
|:---|:---|:---|:---|:---|:---|
| BAT_0163 | BAT-0163 | MOD_01 | STN_01 | 12 | PENDING_INSPECTION |
| BAT_0408 | BAT-0408 | MOD_01 | STN_01 | 93 | IN_USE |
| BAT_0230 | BAT-0230 | MOD_01 | STN_01 | 8 | PENDING_INSPECTION |

---

### Table 5: `SWAP_TRANSACTIONS`
*Primary Key: `swap_id` | Foreign Keys: `customer_id`, `station_id`, `battery_in_id`, `battery_out_id`*

| swap_id | customer_id | station_id | battery_in_id | battery_out_id | energy_consumed_kwh | swap_time | attendant_name |
|:---|:---|:---|:---|:---|:---|:---|:---|
| SWP_10001 | CUST_1082 | STN_01 | BAT_0163 | BAT_0408 | 2.59 | 2026-11-01 22:16:00 | Chantal_U |
| SWP_10002 | CUST_1004 | STN_01 | BAT_0230 | BAT_0505 | 2.94 | 2026-09-19 10:22:00 | Chantal_U |
| SWP_10003 | CUST_1036 | STN_01 | BAT_0188 | BAT_0422 | 2.66 | 2026-10-01 23:18:00 | Jean_Pierre_N |

---

### Table 6: `PAYMENTS`
*Primary Key: `payment_id` | Foreign Key: `swap_id` $\rightarrow$ `SWAP_TRANSACTIONS`*

| payment_id | swap_id | amount_rwf | payment_method | payment_status | payment_time |
|:---|:---|:---|:---|:---|:---|
| PAY_10001 | SWP_10001 | 2331 | CASH | COMPLETED | 2026-11-01 22:16:00 |
| PAY_10002 | SWP_10002 | 2646 | CASH | COMPLETED | 2026-09-19 10:22:00 |
| PAY_10003 | SWP_10003 | 2394 | MTN_MOMO | COMPLETED | 2026-10-01 23:18:00 |

---

### Table 7: `BATTERY_INSPECTIONS`
*Primary Key: `inspection_id` | Foreign Key: `battery_id` $\rightarrow$ `BATTERIES`*

| inspection_id | battery_id | inspector_name | inspection_date | physical_result | remarks |
|:---|:---|:---|:---|:---|:---|
| INS_10001 | BAT_0163 | Chantal_U | 2026-11-01 22:18:00 | PASSED | Inspected by Chantal_U: PASSED. Terminal check ok. |
| INS_10002 | BAT_0230 | Chantal_U | 2026-09-19 10:25:00 | MINOR_SCRATCH | Needs bench check: MINOR_SCRATCH |
| INS_10003 | BAT_0188 | Jean_Pierre_N | 2026-10-01 23:20:00 | PASSED | Inspected by Jean_Pierre_N: PASSED. Terminal check ok. |

---

## 7. Raw Field to 3NF Relational Mapping

| Raw Field Name | Target Table | Target Column | Required Transformation / Type Conversion in Phase IV |
|:---|:---|:---|:---|
| `swap_id` | `SWAP_TRANSACTIONS` | `swap_id` | Direct mapping (VARCHAR2 primary key) |
| `customer_id` | `CUSTOMERS` | `customer_id` | Deduplicated into parent table |
| `customer_name` | `CUSTOMERS` | `customer_name` | Direct mapping |
| `customer_phone` | `CUSTOMERS` | `customer_phone` | Direct mapping |
| `vehicle_plate` | `CUSTOMERS` | `vehicle_plate` | Direct mapping |
| `station_name` | `STATIONS` | `station_name` | Deduplicated to unique station entities |
| `station_district` | `STATIONS` | `district` | Standardize 12 casing variations into 3 canonical values (`Gasabo`, `Kicukiro`, `Nyarugenge`) |
| `battery_returned_serial` | `BATTERIES` / `SWAP_TRANSACTIONS` | `battery_in_id` | Resolve to foreign key reference |
| `returned_soc_pct` | `BATTERIES` / `SWAP_TRANSACTIONS` | `returned_soc_pct` | Direct mapping (NUMBER) |
| `battery_issued_serial` | `BATTERIES` / `SWAP_TRANSACTIONS` | `battery_out_id` | Resolve to foreign key reference |
| `issued_soc_pct` | `BATTERIES` / `SWAP_TRANSACTIONS` | `issued_soc_pct` | Direct mapping (NUMBER) |
| `battery_model` | `BATTERY_MODELS` | `model_name` | Lookup foreign key reference (`model_id`) |
| `model_capacity` | `BATTERY_MODELS` | `capacity_kwh` | Strip `' kWh'` and convert to `NUMBER(4,2)` |
| `energy_consumed` | `SWAP_TRANSACTIONS` | `energy_consumed_kwh` | Strip `' kWh'` and convert to `NUMBER(6,2)` |
| `fee_amount` | `PAYMENTS` | `amount_rwf` | Strip `' RWF'` and convert to `NUMBER(10,2)` |
| `payment_method` | `PAYMENTS` | `payment_method` | Standardize uppercase code |
| `payment_status` | `PAYMENTS` | `payment_status` | Direct mapping |
| `swap_time` | `SWAP_TRANSACTIONS` / `PAYMENTS` | `swap_time` | Impute 16 nulls and convert text to `TIMESTAMP` / `DATE` |
| `attendant_name` | `SWAP_TRANSACTIONS` | `attendant_name` | Direct mapping |
| `inspection_result` | `BATTERY_INSPECTIONS` | `physical_result` | Direct mapping |
| `inspection_notes` | `BATTERY_INSPECTIONS` | `remarks` | Impute 28 blank notes with default text |
