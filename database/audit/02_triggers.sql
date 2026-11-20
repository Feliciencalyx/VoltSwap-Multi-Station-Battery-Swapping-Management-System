/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/audit/02_triggers.sql
  Description:  Enforces business integrity constraints, security restrictions,
                and autonomous auditing triggers.
============================================================================
*/

-- --------------------------------------------------------------------------
-- Trigger 1: TRG_PREVENT_UNINSPECTED_SWAP
-- Type: BEFORE INSERT ON SWAP_TRANSACTIONS
-- Purpose: Ensures outgoing battery is certified CHARGED and has SoC >= 90%
-- --------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_PREVENT_UNINSPECTED_SWAP
BEFORE INSERT ON SWAP_TRANSACTIONS
FOR EACH ROW
DECLARE
    v_bat_status BATTERIES.health_status%TYPE;
    v_bat_soc    BATTERIES.current_soc_pct%TYPE;
BEGIN
    SELECT health_status, current_soc_pct
    INTO v_bat_status, v_bat_soc
    FROM BATTERIES
    WHERE battery_id = :NEW.battery_out_id;

    IF v_bat_status != 'CHARGED' THEN
        log_audit_event(
            p_action_type    => 'DENIED_SWAP_ATTEMPT',
            p_target_table   => 'SWAP_TRANSACTIONS',
            p_record_id      => :NEW.swap_id,
            p_details        => 'Attempted to issue uncertified battery ' || :NEW.battery_out_id || ' with status ' || v_bat_status,
            p_security_level => 'VIOLATION'
        );
        RAISE_APPLICATION_ERROR(-20050, 'INTEGRITY VIOLATION: Battery ' || :NEW.battery_out_id || ' is not certified CHARGED (Status: ' || v_bat_status || '). Swap blocked.');
    END IF;

    IF v_bat_soc < 90 THEN
        log_audit_event(
            p_action_type    => 'DENIED_SWAP_ATTEMPT',
            p_target_table   => 'SWAP_TRANSACTIONS',
            p_record_id      => :NEW.swap_id,
            p_details        => 'Battery ' || :NEW.battery_out_id || ' has insufficient charge: ' || v_bat_soc || '%',
            p_security_level => 'WARNING'
        );
        RAISE_APPLICATION_ERROR(-20051, 'SAFETY VIOLATION: Battery ' || :NEW.battery_out_id || ' charge (' || v_bat_soc || '%) is below the minimum 90% safety threshold.');
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20052, 'Battery ' || :NEW.battery_out_id || ' not found in inventory.');
END;
/

-- --------------------------------------------------------------------------
-- Trigger 2: TRG_RESTRICT_PAYMENT_MUTATION
-- Type: BEFORE UPDATE OR DELETE ON PAYMENTS
-- Purpose: Financial restriction rule - once COMPLETED, payments cannot be altered
-- --------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_RESTRICT_PAYMENT_MUTATION
BEFORE UPDATE OR DELETE ON PAYMENTS
FOR EACH ROW
BEGIN
    IF :OLD.payment_status = 'COMPLETED' THEN
        log_audit_event(
            p_action_type    => CASE WHEN UPDATING THEN 'UNAUTHORIZED_UPDATE' ELSE 'UNAUTHORIZED_DELETE' END,
            p_target_table   => 'PAYMENTS',
            p_record_id      => :OLD.payment_id,
            p_details        => 'User attempted mutation on settled payment of ' || :OLD.amount_rwf || ' RWF (Method: ' || :OLD.payment_method || ')',
            p_security_level => 'CRITICAL'
        );

        RAISE_APPLICATION_ERROR(
            -20060,
            'FINANCIAL INTEGRITY RULE: Completed payment ' || :OLD.payment_id || 
            ' is locked. Tampering or deletion of settled records is strictly prohibited.'
        );
    END IF;
END;
/

-- --------------------------------------------------------------------------
-- Trigger 3: TRG_AUDIT_STATION_MUTATION
-- Type: AFTER UPDATE OF station_status ON STATIONS
-- Purpose: Audits any change in operational station state
-- --------------------------------------------------------------------------
CREATE OR REPLACE TRIGGER TRG_AUDIT_STATION_MUTATION
AFTER UPDATE OF station_status ON STATIONS
FOR EACH ROW
BEGIN
    log_audit_event(
        p_action_type    => 'STATION_STATUS_CHANGE',
        p_target_table   => 'STATIONS',
        p_record_id      => :NEW.station_id,
        p_details        => 'Station ' || :NEW.station_name || ' status changed from ' || :OLD.station_status || ' to ' || :NEW.station_status,
        p_security_level => 'INFO'
    );
END;
/

PROMPT All triggers created successfully.
