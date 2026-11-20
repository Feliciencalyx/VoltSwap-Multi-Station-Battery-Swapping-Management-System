/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/plsql/02_procedures.sql
  Description:  Core business stored procedures executing transactional
                swapping, customer onboarding, and quality inspection triage.
============================================================================
*/

-- --------------------------------------------------------------------------
-- Procedure 1: process_battery_swap
-- Atomic execution of multi-table swap transaction
-- --------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE process_battery_swap (
    p_customer_id       IN  VARCHAR2,
    p_station_id        IN  VARCHAR2,
    p_battery_in_id     IN  VARCHAR2,
    p_battery_out_id    IN  VARCHAR2,
    p_payment_method    IN  VARCHAR2,
    p_attendant_name    IN  VARCHAR2,
    o_swap_id           OUT VARCHAR2,
    o_fee_amount        OUT NUMBER
)
IS
    v_cust_status       CUSTOMERS.account_status%TYPE;
    v_bat_out_status    BATTERIES.health_status%TYPE;
    v_bat_out_stn       BATTERIES.current_station_id%TYPE;
    v_bat_out_soc       BATTERIES.current_soc_pct%TYPE;
    v_bat_out_model     BATTERIES.model_id%TYPE;
    v_bat_in_soc        BATTERIES.current_soc_pct%TYPE;
    v_capacity_kwh      BATTERY_MODELS.capacity_kwh%TYPE;
    v_net_energy_kwh    NUMBER(6,2);
    v_seq_num           NUMBER;
    v_new_swap_id       VARCHAR2(25);
    v_new_pay_id        VARCHAR2(25);
BEGIN
    -- 1. Validate Customer Status
    SELECT account_status INTO v_cust_status
    FROM CUSTOMERS
    WHERE customer_id = p_customer_id;

    IF v_cust_status != 'ACTIVE' THEN
        RAISE_APPLICATION_ERROR(-20020, 'Customer ' || p_customer_id || ' is ' || v_cust_status || '. Swap denied.');
    END IF;

    -- 2. Validate Outgoing Battery Eligibility
    SELECT health_status, current_station_id, current_soc_pct, model_id
    INTO v_bat_out_status, v_bat_out_stn, v_bat_out_soc, v_bat_out_model
    FROM BATTERIES
    WHERE battery_id = p_battery_out_id;

    IF v_bat_out_status != 'CHARGED' THEN
        RAISE_APPLICATION_ERROR(-20021, 'Battery ' || p_battery_out_id || ' is not CHARGED (current: ' || v_bat_out_status || ').');
    END IF;

    IF v_bat_out_stn != p_station_id THEN
        RAISE_APPLICATION_ERROR(-20022, 'Battery ' || p_battery_out_id || ' is not located at station ' || p_station_id || '.');
    END IF;

    IF v_bat_out_soc < 90 THEN
        RAISE_APPLICATION_ERROR(-20023, 'Battery ' || p_battery_out_id || ' charge (' || v_bat_out_soc || '%) is below minimum release threshold (90%).');
    END IF;

    -- 3. Read Incoming Battery SoC
    SELECT current_soc_pct INTO v_bat_in_soc
    FROM BATTERIES
    WHERE battery_id = p_battery_in_id;

    -- 4. Calculate Net Energy and Fee
    SELECT capacity_kwh INTO v_capacity_kwh
    FROM BATTERY_MODELS
    WHERE model_id = v_bat_out_model;

    v_net_energy_kwh := ROUND(v_capacity_kwh * ((v_bat_out_soc - v_bat_in_soc) / 100.0), 2);
    IF v_net_energy_kwh < 0 THEN
        v_net_energy_kwh := 0.50; -- Minimum nominal energy charge
    END IF;

    o_fee_amount := calculate_swap_fee(v_bat_in_soc, v_bat_out_soc, v_bat_out_model, 'STANDARD');

    -- 5. Generate Transaction Identifiers
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(swap_id, 5))), 10000) + 1
    INTO v_seq_num
    FROM SWAP_TRANSACTIONS;

    v_new_swap_id := 'SWP_' || TO_CHAR(v_seq_num);
    v_new_pay_id  := 'PAY_' || TO_CHAR(v_seq_num);

    -- 6. Insert SWAP_TRANSACTION
    INSERT INTO SWAP_TRANSACTIONS (
        swap_id, customer_id, station_id, battery_in_id, battery_out_id,
        returned_soc_pct, issued_soc_pct, energy_consumed_kwh, swap_time, attendant_name
    ) VALUES (
        v_new_swap_id, p_customer_id, p_station_id, p_battery_in_id, p_battery_out_id,
        v_bat_in_soc, v_bat_out_soc, v_net_energy_kwh, SYSTIMESTAMP, p_attendant_name
    );

    -- 7. Insert PAYMENT
    INSERT INTO PAYMENTS (
        payment_id, swap_id, amount_rwf, payment_method, payment_status, payment_time
    ) VALUES (
        v_new_pay_id, v_new_swap_id, o_fee_amount, UPPER(TRIM(p_payment_method)), 'COMPLETED', SYSTIMESTAMP
    );

    -- 8. Update Incoming Battery State (Now at station, needs inspection)
    UPDATE BATTERIES
    SET current_station_id = p_station_id,
        health_status      = 'PENDING_INSPECTION',
        total_swaps        = total_swaps + 1
    WHERE battery_id = p_battery_in_id;

    -- 9. Update Outgoing Battery State (Now in use on road)
    UPDATE BATTERIES
    SET current_station_id = NULL,
        health_status      = 'IN_USE',
        total_swaps        = total_swaps + 1
    WHERE battery_id = p_battery_out_id;

    o_swap_id := v_new_swap_id;
    COMMIT;

EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR(-20025, 'process_battery_swap failed and rolled back: ' || SQLERRM);
END process_battery_swap;
/

-- --------------------------------------------------------------------------
-- Procedure 2: register_new_customer
-- Customer onboarding with contact format verification
-- --------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE register_new_customer (
    p_name        IN  VARCHAR2,
    p_phone       IN  VARCHAR2,
    p_plate       IN  VARCHAR2,
    o_customer_id OUT VARCHAR2
)
IS
    v_next_num NUMBER;
BEGIN
    -- Validate phone format (+2507... or 07...)
    IF NOT (p_phone LIKE '+2507%' OR p_phone LIKE '07%') THEN
        RAISE_APPLICATION_ERROR(-20030, 'Invalid Rwandan phone format. Must begin with +2507 or 07.');
    END IF;

    SELECT NVL(MAX(TO_NUMBER(SUBSTR(customer_id, 6))), 1000) + 1
    INTO v_next_num
    FROM CUSTOMERS;

    o_customer_id := 'CUST_' || TO_CHAR(v_next_num);

    INSERT INTO CUSTOMERS (
        customer_id, customer_name, customer_phone, vehicle_plate, registration_date, account_status
    ) VALUES (
        o_customer_id, TRIM(p_name), TRIM(p_phone), UPPER(TRIM(p_plate)), SYSDATE, 'ACTIVE'
    );

    COMMIT;
END register_new_customer;
/

-- --------------------------------------------------------------------------
-- Procedure 3: log_battery_inspection
-- Quality technician bench inspection recording and battery state transition
-- --------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE log_battery_inspection (
    p_battery_id      IN VARCHAR2,
    p_inspector_name  IN VARCHAR2,
    p_physical_result IN VARCHAR2,
    p_remarks         IN VARCHAR2
)
IS
    v_seq_num     NUMBER;
    v_new_insp_id VARCHAR2(25);
    v_new_status  VARCHAR2(25);
BEGIN
    SELECT NVL(MAX(TO_NUMBER(SUBSTR(inspection_id, 5))), 10000) + 1
    INTO v_seq_num
    FROM BATTERY_INSPECTIONS;

    v_new_insp_id := 'INS_' || TO_CHAR(v_seq_num);

    INSERT INTO BATTERY_INSPECTIONS (
        inspection_id, battery_id, inspector_name, inspection_date, physical_result, remarks
    ) VALUES (
        v_new_insp_id, p_battery_id, TRIM(p_inspector_name), SYSTIMESTAMP, UPPER(TRIM(p_physical_result)), p_remarks
    );

    -- Transition battery status based on test result
    IF UPPER(TRIM(p_physical_result)) IN ('PASSED', 'VOLTAGE_NORMAL') THEN
        v_new_status := 'CHARGING';
    ELSIF UPPER(TRIM(p_physical_result)) = 'MINOR_SCRATCH' THEN
        v_new_status := 'CHARGING';
    ELSE
        v_new_status := 'MAINTENANCE';
    END IF;

    UPDATE BATTERIES
    SET health_status = v_new_status
    WHERE battery_id = p_battery_id;

    COMMIT;
END log_battery_inspection;
/
