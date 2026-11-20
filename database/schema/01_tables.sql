/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/schema/01_tables.sql
  Description:  Physical DDL script creating all Third Normal Form (3NF) 
                tables integrating the empirical 34-station EMBSCS dataset
                with granular swapping transaction entities.
============================================================================
*/

-- Drop existing tables in reverse dependency order
BEGIN
    FOR t IN (SELECT table_name FROM user_tables WHERE table_name IN (
        'BATTERY_INSPECTIONS', 'PAYMENTS', 'SWAP_TRANSACTIONS',
        'BATTERIES', 'BATTERY_MODELS', 'CUSTOMERS',
        'STATION_DAILY_METRICS', 'STATION_DISRUPTIONS', 'STATIONS'
    )) LOOP
        EXECUTE IMMEDIATE 'DROP TABLE ' || t.table_name || ' CASCADE CONSTRAINTS PURGE';
    END LOOP;
END;
/

PROMPT Creating Table: STATIONS (34 Real-World Hubs)...
CREATE TABLE STATIONS (
    station_id          VARCHAR2(20)    NOT NULL,
    station_code        VARCHAR2(20)    NOT NULL,
    station_name        VARCHAR2(100)   NOT NULL,
    district            VARCHAR2(50)    NOT NULL,
    total_bays          NUMBER(3)       DEFAULT 8 NOT NULL,
    distance_to_hub_m   NUMBER(8)       DEFAULT 0 NOT NULL,
    vulnerability_score NUMBER(5,3)     DEFAULT 0.500 NOT NULL,
    station_status      VARCHAR2(20)    DEFAULT 'ACTIVE' NOT NULL,
    CONSTRAINT pk_stations PRIMARY KEY (station_id),
    CONSTRAINT uq_station_code UNIQUE (station_code),
    CONSTRAINT chk_station_district CHECK (district IN ('Nyarugenge', 'Gasabo', 'Kicukiro')),
    CONSTRAINT chk_total_bays CHECK (total_bays > 0),
    CONSTRAINT chk_station_status CHECK (station_status IN ('ACTIVE', 'DISRUPTED', 'MAINTENANCE', 'OFFLINE'))
);

PROMPT Creating Table: STATION_DISRUPTIONS (VEF1 Outage Logs)...
CREATE TABLE STATION_DISRUPTIONS (
    disruption_id       NUMBER          NOT NULL,
    station_id          VARCHAR2(20)    NOT NULL,
    month_recorded      VARCHAR2(10)    NOT NULL,
    outage_count        NUMBER(4)       NOT NULL,
    remarks             VARCHAR2(255),
    CONSTRAINT pk_disruptions PRIMARY KEY (disruption_id),
    CONSTRAINT fk_disr_station FOREIGN KEY (station_id) REFERENCES STATIONS(station_id)
);

PROMPT Creating Table: STATION_DAILY_METRICS (3,128 Empirical Records from PI_1, PI_2, PI_3)...
CREATE TABLE STATION_DAILY_METRICS (
    metric_id               NUMBER          NOT NULL,
    station_id              VARCHAR2(20)    NOT NULL,
    operation_date          DATE            NOT NULL,
    swap_throughput         NUMBER(5)       NOT NULL,
    unique_batteries_swapped NUMBER(5)      NOT NULL,
    customers_served        NUMBER(5)       NOT NULL,
    avg_swap_time_min       NUMBER(4,2)     DEFAULT 1.35 NOT NULL,
    avg_soc_pct             NUMBER(4,1)     DEFAULT 14.5 NOT NULL,
    CONSTRAINT pk_daily_metrics PRIMARY KEY (metric_id),
    CONSTRAINT fk_metric_station FOREIGN KEY (station_id) REFERENCES STATIONS(station_id),
    CONSTRAINT uq_station_date UNIQUE (station_id, operation_date)
);

PROMPT Creating Table: CUSTOMERS...
CREATE TABLE CUSTOMERS (
    customer_id         VARCHAR2(20)    NOT NULL,
    customer_name       VARCHAR2(100)   NOT NULL,
    customer_phone      VARCHAR2(25)    NOT NULL,
    vehicle_plate       VARCHAR2(20)    NOT NULL,
    registration_date   DATE            DEFAULT SYSDATE NOT NULL,
    account_status      VARCHAR2(20)    DEFAULT 'ACTIVE' NOT NULL,
    CONSTRAINT pk_customers PRIMARY KEY (customer_id),
    CONSTRAINT uq_cust_phone UNIQUE (customer_phone),
    CONSTRAINT uq_cust_plate UNIQUE (vehicle_plate),
    CONSTRAINT chk_cust_status CHECK (account_status IN ('ACTIVE', 'SUSPENDED', 'FLAGGED'))
);

PROMPT Creating Table: BATTERY_MODELS...
CREATE TABLE BATTERY_MODELS (
    model_id            VARCHAR2(20)    NOT NULL,
    model_name          VARCHAR2(50)    NOT NULL,
    capacity_kwh        NUMBER(4,2)     NOT NULL,
    nominal_voltage     VARCHAR2(10)    NOT NULL,
    rated_cycles        NUMBER(5)       DEFAULT 1500 NOT NULL,
    CONSTRAINT pk_battery_models PRIMARY KEY (model_id),
    CONSTRAINT uq_model_name UNIQUE (model_name),
    CONSTRAINT chk_model_capacity CHECK (capacity_kwh > 0),
    CONSTRAINT chk_rated_cycles CHECK (rated_cycles > 0)
);

PROMPT Creating Table: BATTERIES...
CREATE TABLE BATTERIES (
    battery_id          VARCHAR2(20)    NOT NULL,
    serial_number       VARCHAR2(30)    NOT NULL,
    model_id            VARCHAR2(20)    NOT NULL,
    current_station_id  VARCHAR2(20),
    current_soc_pct     NUMBER(3)       DEFAULT 100 NOT NULL,
    health_status       VARCHAR2(25)    DEFAULT 'CHARGED' NOT NULL,
    total_swaps         NUMBER(6)       DEFAULT 0 NOT NULL,
    CONSTRAINT pk_batteries PRIMARY KEY (battery_id),
    CONSTRAINT uq_battery_serial UNIQUE (serial_number),
    CONSTRAINT fk_bat_model FOREIGN KEY (model_id) REFERENCES BATTERY_MODELS(model_id),
    CONSTRAINT fk_bat_station FOREIGN KEY (current_station_id) REFERENCES STATIONS(station_id),
    CONSTRAINT chk_bat_soc CHECK (current_soc_pct BETWEEN 0 AND 100),
    CONSTRAINT chk_bat_status CHECK (health_status IN (
        'CHARGED', 'CHARGING', 'IN_USE', 'PENDING_INSPECTION', 'MAINTENANCE', 'RETIRED'
    )),
    CONSTRAINT chk_bat_swaps CHECK (total_swaps >= 0)
);

PROMPT Creating Table: SWAP_TRANSACTIONS...
CREATE TABLE SWAP_TRANSACTIONS (
    swap_id             VARCHAR2(25)    NOT NULL,
    customer_id         VARCHAR2(20)    NOT NULL,
    station_id          VARCHAR2(20)    NOT NULL,
    battery_in_id       VARCHAR2(20)    NOT NULL,
    battery_out_id      VARCHAR2(20)    NOT NULL,
    returned_soc_pct    NUMBER(3)       NOT NULL,
    issued_soc_pct      NUMBER(3)       NOT NULL,
    energy_consumed_kwh NUMBER(6,2)     NOT NULL,
    swap_time           TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    attendant_name      VARCHAR2(100)   NOT NULL,
    CONSTRAINT pk_swap_transactions PRIMARY KEY (swap_id),
    CONSTRAINT fk_swap_customer FOREIGN KEY (customer_id) REFERENCES CUSTOMERS(customer_id),
    CONSTRAINT fk_swap_station FOREIGN KEY (station_id) REFERENCES STATIONS(station_id),
    CONSTRAINT fk_swap_batin FOREIGN KEY (battery_in_id) REFERENCES BATTERIES(battery_id),
    CONSTRAINT fk_swap_batout FOREIGN KEY (battery_out_id) REFERENCES BATTERIES(battery_id),
    CONSTRAINT chk_soc_in CHECK (returned_soc_pct BETWEEN 0 AND 100),
    CONSTRAINT chk_soc_out CHECK (issued_soc_pct BETWEEN 0 AND 100),
    CONSTRAINT chk_energy CHECK (energy_consumed_kwh >= 0)
);

PROMPT Creating Table: PAYMENTS...
CREATE TABLE PAYMENTS (
    payment_id          VARCHAR2(25)    NOT NULL,
    swap_id             VARCHAR2(25)    NOT NULL,
    amount_rwf          NUMBER(10,2)    NOT NULL,
    payment_method      VARCHAR2(20)    NOT NULL,
    payment_status      VARCHAR2(20)    DEFAULT 'COMPLETED' NOT NULL,
    payment_time        TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    CONSTRAINT pk_payments PRIMARY KEY (payment_id),
    CONSTRAINT uq_payment_swap UNIQUE (swap_id),
    CONSTRAINT fk_pay_swap FOREIGN KEY (swap_id) REFERENCES SWAP_TRANSACTIONS(swap_id) ON DELETE CASCADE,
    CONSTRAINT chk_pay_amount CHECK (amount_rwf >= 0),
    CONSTRAINT chk_pay_method CHECK (payment_method IN ('MTN_MOMO', 'AIRTEL_MONEY', 'CARD', 'CASH')),
    CONSTRAINT chk_pay_status CHECK (payment_status IN ('COMPLETED', 'PENDING', 'FAILED', 'REFUNDED'))
);

PROMPT Creating Table: BATTERY_INSPECTIONS...
CREATE TABLE BATTERY_INSPECTIONS (
    inspection_id       VARCHAR2(25)    NOT NULL,
    battery_id          VARCHAR2(20)    NOT NULL,
    inspector_name      VARCHAR2(100)   NOT NULL,
    inspection_date     TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    physical_result     VARCHAR2(30)    NOT NULL,
    remarks             VARCHAR2(255)   DEFAULT 'Standard inspection passed - no remarks recorded',
    CONSTRAINT pk_inspections PRIMARY KEY (inspection_id),
    CONSTRAINT fk_insp_battery FOREIGN KEY (battery_id) REFERENCES BATTERIES(battery_id),
    CONSTRAINT chk_insp_result CHECK (physical_result IN (
        'PASSED', 'MINOR_SCRATCH', 'VOLTAGE_NORMAL', 'TERMINAL_WEAR', 'FLAGGED_TEST', 'FAILED_DEGRADED'
    ))
);

-- Performance Indexes
CREATE INDEX idx_daily_stn ON STATION_DAILY_METRICS(station_id);
CREATE INDEX idx_daily_date ON STATION_DAILY_METRICS(operation_date);
CREATE INDEX idx_disr_stn ON STATION_DISRUPTIONS(station_id);
CREATE INDEX idx_bat_stn ON BATTERIES(current_station_id);
CREATE INDEX idx_swap_cust ON SWAP_TRANSACTIONS(customer_id);
CREATE INDEX idx_swap_stn ON SWAP_TRANSACTIONS(station_id);
CREATE INDEX idx_pay_swap ON PAYMENTS(swap_id);

PROMPT Tables and indexes created successfully.
