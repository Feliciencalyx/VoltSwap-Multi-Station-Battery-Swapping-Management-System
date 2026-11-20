# Logical Data Dictionary: VoltSwap Management System (Electric Cars)

**Course:** INSY 8311 – Database Development with PL/SQL  
**Student:** NSHIMYUMUKIZA Felicien (ID: 20251SEN197)  
**Phase:** Phase II – Data Sourcing, Normalization and Logical Design  

> **Note on Data Types:** In accordance with Phase II specifications, specific Oracle physical data types and byte sizes are omitted here; they are defined in Phase IV physical DDL.

---

## 1. Table: `STATIONS`
*Represents the 34 physical commercial electric car swapping hubs across metropolitan districts.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `station_id` | **PK** | Unique station identifier code (`BS007`..`BS290`) | Yes | Yes |
| `station_code` | - | Hardware short code matching EMBSCS telemetry | Yes | Yes |
| `station_name` | - | Commercial designation of drive-in station hub | Yes | Yes |
| `district` | - | Administrative district location | Yes | No |
| `total_bays` | - | Active drive-in bay charging compartments | Yes | No |
| `distance_to_hub_m` | - | Distance in meters to primary logistics depot | Yes | No |
| `vulnerability_score` | - | Composite vulnerability index ($0.000$ to $1.000$) | Yes | No |
| `station_status` | - | Operational state (`ACTIVE`, `DISRUPTED`, `MAINTENANCE`, `OFFLINE`) | Yes | No |

---

## 2. Table: `STATION_DAILY_METRICS`
*Aggregated daily telemetry holding 3,128 empirical observations (PI_1, PI_2, PI_3, VDF1, VDF4).*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `metric_id` | **PK** | Unique identifier for daily observation record | Yes | Yes |
| `station_id` | **FK** | References `STATIONS(station_id)` | Yes | No |
| `operation_date` | - | Calendar date of observation | Yes | No |
| `swap_throughput` | - | Total EV car swaps completed in 24-hour cycle | Yes | No |
| `unique_batteries_swapped` | - | Distinct automotive battery packs processed | Yes | No |
| `customers_served` | - | Distinct EV car drivers/fleets served on that date | Yes | No |
| `avg_swap_time_min` | - | Average swap completion duration in minutes | Yes | No |
| `avg_soc_pct` | - | Average incoming battery State of Charge % | Yes | No |

---

## 3. Table: `STATION_DISRUPTIONS`
*Operational outage and disruption records captured from VEF1 telemetry.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `disruption_id` | **PK** | Unique disruption event identifier | Yes | Yes |
| `station_id` | **FK** | References `STATIONS(station_id)` | Yes | No |
| `month_recorded` | - | Year and month of recorded disruption (`YYYY-MM`) | Yes | No |
| `outage_count` | - | Cumulative number of outage/disruption events | Yes | No |
| `remarks` | - | Descriptive technical notes regarding the disruption | No | No |

---

## 4. Table: `BATTERY_MODELS`
*Standard catalog of EV car battery chemistries, capacities, and voltages.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `model_id` | **PK** | Unique identifier for battery specification model | Yes | Yes |
| `model_name` | - | Commercial model designation (`VoltCar-40kWh`, etc.) | Yes | Yes |
| `capacity_kwh` | - | Nominal energy storage capacity (40.0, 60.0, 85.0 kWh) | Yes | No |
| `nominal_voltage`| - | Operating voltage rating (`400V`, `800V`) | Yes | No |
| `rated_cycles` | - | Manufacturer certified maximum lifetime charge cycles | Yes | No |

---

## 5. Table: `BATTERIES`
*Individual physical automotive battery packs circulating in the network.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `battery_id` | **PK** | Unique system hardware identifier | Yes | Yes |
| `serial_number` | - | Manufacturer engraved hardware barcode/serial | Yes | Yes |
| `model_id` | **FK** | References parent `BATTERY_MODELS(model_id)` | Yes | No |
| `current_station_id` | **FK** | Station currently holding/charging pack (or null if in car) | No | No |
| `current_soc_pct`| - | Current real-time State of Charge percentage (0–100) | Yes | No |
| `health_status` | - | State (`CHARGED`, `CHARGING`, `IN_USE`, `PENDING_INSPECTION`, `MAINTENANCE`, `RETIRED`) | Yes | No |
| `total_swaps` | - | Cumulative lifetime swap cycles executed | Yes | No |

---

## 6. Table: `CUSTOMERS`
*Registered EV car owners, commercial taxi drivers, and fleet operators.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `customer_id` | **PK** | Unique customer identifier | Yes | Yes |
| `customer_name` | - | Full name or business handle of driver/fleet | Yes | No |
| `customer_phone` | - | Masked telephone contact number | Yes | Yes |
| `vehicle_plate` | - | Electric car registration plate | Yes | Yes |
| `registration_date` | - | Account creation date | Yes | No |
| `account_status` | - | Operational standing (`ACTIVE`, `SUSPENDED`, `FLAGGED`) | Yes | No |

---

## 7. Table: `SWAP_TRANSACTIONS`
*Transactional event recording the exchange of a depleted car pack for a charged pack.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `swap_id` | **PK** | Unique exchange transaction identifier | Yes | Yes |
| `customer_id` | **FK** | References `CUSTOMERS(customer_id)` | Yes | No |
| `station_id` | **FK** | References `STATIONS(station_id)` | Yes | No |
| `battery_in_id` | **FK** | References `BATTERIES(battery_id)` (returned car pack) | Yes | No |
| `battery_out_id`| **FK** | References `BATTERIES(battery_id)` (issued car pack) | Yes | No |
| `returned_soc_pct`| - | Charge percentage of returned battery at intake | Yes | No |
| `issued_soc_pct` | - | Charge percentage of issued battery at release | Yes | No |
| `energy_consumed_kwh`| - | Net energy replenished ($SoC_{out} - SoC_{in}$) | Yes | No |
| `swap_time` | - | Timestamp of physical exchange | Yes | No |
| `attendant_name` | - | Drive-in bay operator conducting swap | Yes | No |

---

## 8. Table: `PAYMENTS`
*Financial accounting records tied to car swap transactions.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `payment_id` | **PK** | Unique payment reference code | Yes | Yes |
| `swap_id` | **FK** | References `SWAP_TRANSACTIONS(swap_id)` | Yes | Yes |
| `amount_rwf` | - | Monetary fee charged in Rwandan Francs | Yes | No |
| `payment_method` | - | Settlement channel (`MTN_MOMO`, `AIRTEL_MONEY`, `CARD`, `CASH`) | Yes | No |
| `payment_status` | - | Settlement state (`COMPLETED`, `PENDING`, `FAILED`, `REFUNDED`) | Yes | No |
| `payment_time` | - | Timestamp of payment confirmation | Yes | No |

---

## 9. Table: `BATTERY_INSPECTIONS`
*High-voltage quality-control triage records for returned automotive batteries.*

| Column Name | Key Type | Description / Meaning | Required? | Unique? |
|:---|:---:|:---|:---:|:---:|
| `inspection_id` | **PK** | Unique inspection audit report identifier | Yes | Yes |
| `battery_id` | **FK** | References `BATTERIES(battery_id)` | Yes | No |
| `inspector_name` | - | Technician conducting bench diagnostic | Yes | No |
| `inspection_date`| - | Timestamp inspection was conducted | Yes | No |
| `physical_result`| - | Diagnostic verdict (`PASSED`, `MINOR_SCRATCH`, `VOLTAGE_NORMAL`, `TERMINAL_WEAR`, `FAILED_DEGRADED`) | Yes | No |
| `remarks` | - | Technical triage remarks | Yes | No |
