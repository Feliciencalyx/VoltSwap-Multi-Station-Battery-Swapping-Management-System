/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Electric Car Battery Swapping Management System
  Script:       database/tests/test_success_cases.sql
  Description:  Executes comprehensive successful test scenarios for stored
                procedures, functions, and package routines for EV car operations.
============================================================================
*/

SET SERVEROUTPUT ON;
SET LINESIZE 180;

PROMPT ============================================================================
PROMPT TEST 1: FUNCTION calculate_swap_fee (EV CAR HIGH-CAPACITY PACKS)
PROMPT ============================================================================
DECLARE
    v_fee_std  NUMBER;
    v_fee_taxi NUMBER;
    v_fee_corp NUMBER;
BEGIN
    -- Scenario: Return 15% SoC, Issue 95% SoC on EV Car Model MOD_01 (40.0 kWh)
    -- Energy: 40.0 * 0.80 = 32.0 kWh * 350 RWF = 11,200 RWF
    v_fee_std  := calculate_swap_fee(15, 95, 'MOD_01', 'PRIVATE_CAR');
    v_fee_taxi := calculate_swap_fee(15, 95, 'MOD_01', 'COMMERCIAL_TAXI');
    v_fee_corp := calculate_swap_fee(15, 95, 'MOD_01', 'CORPORATE_FLEET');

    DBMS_OUTPUT.PUT_LINE('Fee Private Car (0% discount):       ' || v_fee_std  || ' RWF (Expected: ~11,200)');
    DBMS_OUTPUT.PUT_LINE('Fee Commercial Taxi (10% disc):       ' || v_fee_taxi || ' RWF (Expected: ~10,080)');
    DBMS_OUTPUT.PUT_LINE('Fee Corporate Fleet (15% disc):      ' || v_fee_corp || ' RWF (Expected: ~9,520)');
END;
/

PROMPT
PROMPT ============================================================================
PROMPT TEST 2: FUNCTION check_station_availability (DRIVE-IN BAY STOCK)
PROMPT ============================================================================
DECLARE
    v_avail NUMBER;
BEGIN
    v_avail := check_station_availability('BS007', 'MOD_01');
    DBMS_OUTPUT.PUT_LINE('Available Ready Car Packs at BS007 for MOD_01: ' || v_avail);
END;
/

PROMPT
PROMPT ============================================================================
PROMPT TEST 3: PROCEDURE register_new_customer (ELECTRIC CAR ONBOARDING)
PROMPT ============================================================================
DECLARE
    v_new_cust_id VARCHAR2(20);
BEGIN
    register_new_customer(
        p_name        => 'Jean Bosco Hakizimana (Kigali EV Taxi)',
        p_phone       => '+250788998877',
        p_plate       => 'RAF 999Z',
        o_customer_id => v_new_cust_id
    );
    DBMS_OUTPUT.PUT_LINE('Successfully registered EV driver: ' || v_new_cust_id);
END;
/

PROMPT
PROMPT ============================================================================
PROMPT TEST 4: PROCEDURE process_battery_swap (ATOMIC CAR SWAP TRANSACTION)
PROMPT ============================================================================
DECLARE
    v_swap_id VARCHAR2(25);
    v_fee     NUMBER;
    v_bat_in  VARCHAR2(20);
    v_bat_out VARCHAR2(20);
BEGIN
    -- Prepare a test car battery in CHARGED state at BS007
    SELECT battery_id INTO v_bat_out
    FROM BATTERIES
    WHERE current_station_id = 'BS007'
      AND health_status = 'CHARGED'
      AND current_soc_pct >= 90
      AND ROWNUM = 1;

    -- Pick a battery currently in use or pending inspection to return
    SELECT battery_id INTO v_bat_in
    FROM BATTERIES
    WHERE battery_id != v_bat_out
      AND ROWNUM = 1;

    process_battery_swap(
        p_customer_id    => 'CUST_1001',
        p_station_id     => 'BS007',
        p_battery_in_id  => v_bat_in,
        p_battery_out_id => v_bat_out,
        p_payment_method => 'MTN_MOMO',
        p_attendant_name => 'Bay_Operator_BS007',
        o_swap_id        => v_swap_id,
        o_fee_amount     => v_fee
    );

    DBMS_OUTPUT.PUT_LINE('Car Swap Successfully Executed: ' || v_swap_id || ' | Fee: ' || v_fee || ' RWF');
END;
/

PROMPT
PROMPT ============================================================================
PROMPT TEST 5: PACKAGE PKG_VOLTSWAP_OPS ROUTINES
PROMPT ============================================================================
BEGIN
    PKG_VOLTSWAP_OPS.generate_daily_reconciliation(
        p_station_id  => 'BS007',
        p_target_date => SYSDATE
    );

    DBMS_OUTPUT.PUT_LINE('Overall Network Health Index: ' || PKG_VOLTSWAP_OPS.get_network_health_index() || '%');
    DBMS_OUTPUT.PUT_LINE('Station JSON Telemetry: ' || PKG_VOLTSWAP_OPS.get_station_summary_json('BS007'));
END;
/
