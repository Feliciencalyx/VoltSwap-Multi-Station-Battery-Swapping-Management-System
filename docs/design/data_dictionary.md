# Logical Data Dictionary: VoltSwap Management System

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Phase:** Phase II – Data Sourcing, Normalization and Logical Design  

> **Note on Data Types:** In accordance with Phase II specifications, specific Oracle physical data types and byte allocations are omitted here. They will be defined during Phase IV physical implementation.

---

## 1. Table: `CUSTOMERS`
*Represents electric motorcycle riders registered to access VoltSwap stations.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `customer_id` | **PK** | Unique identifier for each registered customer | Yes | Yes |
| `customer_name` | - | Full name or anonymized handle of rider | Yes | No |
| `customer_phone` | - | Primary telephone contact number | Yes | Yes |
| `vehicle_plate` | - | Registration plate of the motorcycle | Yes | Yes |
| `registration_date` | - | Date the customer registered with the service | Yes | No |
| `account_status` | - | Operational standing (`ACTIVE`, `SUSPENDED`, `FLAGGED`) | Yes | No |

---

## 2. Table: `STATIONS`
*Represents physical swapping hubs deployed across Kigali metropolitan districts.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `station_id` | **PK** | Unique identifier for the swapping station | Yes | Yes |
| `station_name` | - | Commercial name of the station hub | Yes | Yes |
| `district` | - | Administrative district location | Yes | No |
| `total_bays` | - | Total physical charging and holding bays | Yes | No |
| `station_status` | - | Current state (`ACTIVE`, `MAINTENANCE`, `OFFLINE`) | Yes | No |

---

## 3. Table: `BATTERY_MODELS`
*Catalog of standardized battery chemistry and engineering specifications.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `model_id` | **PK** | Unique identifier for battery specification model | Yes | Yes |
| `model_name` | - | Commercial model designation | Yes | Yes |
| `capacity_kwh` | - | Nominal energy storage capacity in kilowatt-hours | Yes | No |
| `nominal_voltage`| - | Operating voltage rating | Yes | No |
| `rated_cycles` | - | Manufacturer certified maximum charge cycles | Yes | No |

---

## 4. Table: `BATTERIES`
*Individual physical battery hardware packs circulating in the system.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `battery_id` | **PK** | Unique system identifier for physical pack | Yes | Yes |
| `serial_number` | - | Manufacturer engraved hardware barcode/serial | Yes | Yes |
| `model_id` | **FK** | References parent `BATTERY_MODELS(model_id)` | Yes | No |
| `current_station_id` | **FK** | Station currently holding or charging this pack | No | No |
| `current_soc_pct`| - | Current real-time State of Charge percentage (0–100) | Yes | No |
| `health_status` | - | Operational state (`CHARGED`, `CHARGING`, `IN_USE`, `PENDING_INSPECTION`, `MAINTENANCE`, `RETIRED`) | Yes | No |
| `total_swaps` | - | Cumulative number of swap cycles executed | Yes | No |

---

## 5. Table: `SWAP_TRANSACTIONS`
*Transactional event recording the exchange of a depleted pack for a charged pack.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `swap_id` | **PK** | Unique transactional exchange transaction identifier | Yes | Yes |
| `customer_id` | **FK** | References `CUSTOMERS(customer_id)` | Yes | No |
| `station_id` | **FK** | References `STATIONS(station_id)` where swap occurred | Yes | No |
| `battery_in_id` | **FK** | References `BATTERIES(battery_id)` (depleted pack returned) | Yes | No |
| `battery_out_id`| **FK** | References `BATTERIES(battery_id)` (charged pack issued) | Yes | No |
| `returned_soc_pct`| - | Charge level of incoming battery at intake | Yes | No |
| `issued_soc_pct` | - | Charge level of outgoing battery at release | Yes | No |
| `energy_consumed_kwh`| - | Net energy replenished ($SoC_{out} - SoC_{in}$) | Yes | No |
| `swap_time` | - | Timestamp of physical exchange | Yes | No |
| `attendant_name` | - | Name of staff attendant operating console | Yes | No |

---

## 6. Table: `PAYMENTS`
*Financial accounting records tied to swap transactions.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `payment_id` | **PK** | Unique payment reference code | Yes | Yes |
| `swap_id` | **FK** | References parent `SWAP_TRANSACTIONS(swap_id)` | Yes | Yes |
| `amount_rwf` | - | Monetary fee charged in Rwandan Francs | Yes | No |
| `payment_method` | - | Settlement channel (`MTN_MOMO`, `AIRTEL_MONEY`, `CARD`, `CASH`) | Yes | No |
| `payment_status` | - | Settlement state (`COMPLETED`, `PENDING`, `FAILED`, `REFUNDED`) | Yes | No |
| `payment_time` | - | Timestamp of payment confirmation | Yes | No |

---

## 7. Table: `BATTERY_INSPECTIONS`
*Safety triage and technical quality-control checks conducted on returned batteries.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `inspection_id` | **PK** | Unique inspection audit report identifier | Yes | Yes |
| `battery_id` | **FK** | References `BATTERIES(battery_id)` under test | Yes | No |
| `inspector_name` | - | Staff technician performing bench test | Yes | No |
| `inspection_date`| - | Date and time inspection was conducted | Yes | No |
| `physical_result`| - | Inspection verdict (`PASSED`, `MINOR_SCRATCH`, `TERMINAL_WEAR`, `FAILED_DEGRADED`) | Yes | No |
| `remarks` | - | Technical observations or triage instructions | Yes | No |

---

## 8. Relational Cardinality and Optionality Summary

| Parent Entity | Child Entity | Relationship Description | Cardinality | Parent Optionality | Child Optionality |
|:---|:---|:---|:---:|:---:|:---:|
| `CUSTOMERS` | `SWAP_TRANSACTIONS` | A customer executes swap transactions | $1 : N$ | Mandatory (A swap must have 1 customer) | Optional (A customer may have 0 or many swaps) |
| `STATIONS` | `SWAP_TRANSACTIONS` | A station hosts swap transactions | $1 : N$ | Mandatory (A swap occurs at 1 station) | Optional (A station may host 0 or many swaps) |
| `STATIONS` | `BATTERIES` | A station currently stocks batteries | $1 : N$ | Optional (A battery may be in use on road) | Optional (A station holds 0 or many batteries) |
| `BATTERY_MODELS`| `BATTERIES` | A model classifies physical battery packs | $1 : N$ | Mandatory (A battery must belong to 1 model) | Optional (A model may exist without active packs) |
| `BATTERIES` | `SWAP_TRANSACTIONS` (In) | A battery is returned in swaps | $1 : N$ | Mandatory | Optional |
| `BATTERIES` | `SWAP_TRANSACTIONS` (Out) | A battery is issued in swaps | $1 : N$ | Mandatory | Optional |
| `SWAP_TRANSACTIONS`| `PAYMENTS` | A swap produces a payment settlement | $1 : 1$ | Mandatory (Every payment belongs to 1 swap) | Mandatory (Every swap requires exactly 1 payment record) |
| `BATTERIES` | `BATTERY_INSPECTIONS` | A battery undergoes safety inspections | $1 : N$ | Mandatory (An inspection checks 1 battery) | Optional (A battery may have 0 or many inspection logs) |
