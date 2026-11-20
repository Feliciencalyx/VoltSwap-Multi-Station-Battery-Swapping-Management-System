/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/tests/test_error_cases.sql
  Description:  Executes negative test cases demonstrating business constraint
                enforcement, exception handling, and autonomous audit logging.
============================================================================
*/

SET SERVEROUTPUT ON;
SET LINESIZE 180;

PROMPT ============================================================================
PROMPT ERROR TEST 1: ISSUING UNINSPECTED / DEGRADED BATTERY (TRIGGER 1)
PROMPT ============================================================================
DECLARE
    v_bad_bat VARCHAR2(20);
BEGIN
    -- Mark a dummy battery as PENDING_INSPECTION
    UPDATE BATTERIES SET health_status = 'PENDING_INSPECTION' WHERE battery_id = 'BAT_0163';
    COMMIT;

    -- Attempt to insert swap with uninspected battery
    INSERT INTO SWAP_TRANSACTIONS (
        swap_id, customer_id, station_id, battery_in_id, battery_out_id,
        returned_soc_pct, issued_soc_pct, energy_consumed_kwh, attendant_name
    ) VALUES (
        'SWP_ERR01', 'CUST_1042', 'STN_01', 'BAT_0188', 'BAT_0163', 15, 95, 2.50, 'Attendant_Test'
    );

    DBMS_OUTPUT.PUT_LINE('FAILED: Trigger TRG_PREVENT_UNINSPECTED_SWAP did not fire!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXPECTED SUCCESS: Trigger caught violation -> ' || SQLERRM);
END;
/

PROMPT
PROMPT ============================================================================
PROMPT ERROR TEST 2: ISSUING BATTERY WITH INSUFFICIENT CHARGE (<90%) (TRIGGER 1)
PROMPT ============================================================================
BEGIN
    UPDATE BATTERIES SET health_status = 'CHARGED', current_soc_pct = 75 WHERE battery_id = 'BAT_0163';
    COMMIT;

    INSERT INTO SWAP_TRANSACTIONS (
        swap_id, customer_id, station_id, battery_in_id, battery_out_id,
        returned_soc_pct, issued_soc_pct, energy_consumed_kwh, attendant_name
    ) VALUES (
        'SWP_ERR02', 'CUST_1042', 'STN_01', 'BAT_0188', 'BAT_0163', 15, 75, 1.90, 'Attendant_Test'
    );

    DBMS_OUTPUT.PUT_LINE('FAILED: Charge threshold trigger did not fire!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXPECTED SUCCESS: Trigger caught charge violation -> ' || SQLERRM);
END;
/

PROMPT
PROMPT ============================================================================
PROMPT ERROR TEST 3: TAMPERING WITH COMPLETED PAYMENT RECORD (TRIGGER 2)
PROMPT ============================================================================
BEGIN
    UPDATE PAYMENTS
    SET amount_rwf = 100
    WHERE payment_status = 'COMPLETED' AND ROWNUM = 1;

    DBMS_OUTPUT.PUT_LINE('FAILED: Payment security trigger did not block mutation!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXPECTED SUCCESS: Payment lock trigger caught tampering -> ' || SQLERRM);
END;
/

PROMPT
PROMPT ============================================================================
PROMPT ERROR TEST 4: INVALID RWANDAN PHONE FORMAT ON ONBOARDING
PROMPT ============================================================================
DECLARE
    v_id VARCHAR2(20);
BEGIN
    register_new_customer(
        p_name        => 'Invalid Phone Test',
        p_phone       => '+14155551234', -- US number, not +2507
        p_plate       => 'RAD 001A',
        o_customer_id => v_id
    );
    DBMS_OUTPUT.PUT_LINE('FAILED: Procedure permitted invalid phone number!');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('EXPECTED SUCCESS: Validation rejected invalid phone -> ' || SQLERRM);
END;
/

PROMPT
PROMPT ============================================================================
PROMPT ERROR TEST 5: VERIFY SECURITY AUDIT TRAIL
PROMPT ============================================================================
SELECT log_id, log_timestamp, db_user, action_type, target_table, security_level, details
FROM AUDIT_LOG
ORDER BY log_id DESC
FETCH FIRST 5 ROWS ONLY;
