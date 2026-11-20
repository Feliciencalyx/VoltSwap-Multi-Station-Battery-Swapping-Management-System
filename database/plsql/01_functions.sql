/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/plsql/01_functions.sql
  Description:  Core business logic stored functions: tariff fee calculation,
                inventory stock checking, and battery health grading.
============================================================================
*/

-- --------------------------------------------------------------------------
-- Function 1: calculate_swap_fee
-- Calculates dynamic energy tariff based on net kWh replenished and customer tier
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION calculate_swap_fee (
    p_returned_soc   IN NUMBER,
    p_issued_soc     IN NUMBER,
    p_model_id       IN VARCHAR2,
    p_customer_tier  IN VARCHAR2 DEFAULT 'STANDARD'
) RETURN NUMBER
IS
    v_capacity_kwh   BATTERY_MODELS.capacity_kwh%TYPE;
    v_net_energy_kwh NUMBER(6,2);
    v_base_rate_rwf  CONSTANT NUMBER := 900; -- Standard tariff: 900 RWF per kWh
    v_discount_pct   NUMBER := 0;
    v_total_fee      NUMBER(10,2);
BEGIN
    -- Input validations
    IF p_returned_soc >= p_issued_soc THEN
        RAISE_APPLICATION_ERROR(-20010, 'Invalid SoC: Issued battery charge must exceed returned charge.');
    END IF;

    -- Retrieve model nominal capacity
    SELECT capacity_kwh INTO v_capacity_kwh
    FROM BATTERY_MODELS
    WHERE model_id = p_model_id;

    -- Compute net energy dispensed: (SoC_out - SoC_in)% * Capacity
    v_net_energy_kwh := ROUND(v_capacity_kwh * ((p_issued_soc - p_returned_soc) / 100.0), 2);

    -- Apply customer loyalty / fleet tier discount
    CASE UPPER(TRIM(p_customer_tier))
        WHEN 'COMMERCIAL_MOTO' THEN v_discount_pct := 0.10; -- 10% discount for moto taxi riders
        WHEN 'VIP_FLEET'       THEN v_discount_pct := 0.15; -- 15% discount for corporate logistics
        ELSE v_discount_pct := 0.00;
    END CASE;

    -- Calculate fee rounded to nearest Rwandan Franc
    v_total_fee := ROUND(v_net_energy_kwh * v_base_rate_rwf * (1.0 - v_discount_pct), 0);

    RETURN v_total_fee;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20011, 'Specified battery model ' || p_model_id || ' does not exist.');
    WHEN OTHERS THEN
        RAISE_APPLICATION_ERROR(-20012, 'Error in calculate_swap_fee: ' || SQLERRM);
END calculate_swap_fee;
/

-- --------------------------------------------------------------------------
-- Function 2: check_station_availability
-- Returns total ready charged packs (SoC >= 90% and status CHARGED)
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION check_station_availability (
    p_station_id IN VARCHAR2,
    p_model_id   IN VARCHAR2
) RETURN NUMBER
IS
    v_available_count NUMBER := 0;
BEGIN
    SELECT COUNT(*)
    INTO v_available_count
    FROM BATTERIES
    WHERE current_station_id = p_station_id
      AND model_id = p_model_id
      AND health_status = 'CHARGED'
      AND current_soc_pct >= 90;

    RETURN v_available_count;
END check_station_availability;
/

-- --------------------------------------------------------------------------
-- Function 3: get_battery_health_grade
-- Classifies battery degradation based on swap cycle count and inspections
-- --------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION get_battery_health_grade (
    p_battery_id IN VARCHAR2
) RETURN VARCHAR2
IS
    v_total_swaps  NUMBER;
    v_rated_cycles NUMBER;
    v_degraded_cnt NUMBER;
    v_cycle_ratio  NUMBER;
BEGIN
    SELECT b.total_swaps, m.rated_cycles
    INTO v_total_swaps, v_rated_cycles
    FROM BATTERIES b
    JOIN BATTERY_MODELS m ON b.model_id = m.model_id
    WHERE b.battery_id = p_battery_id;

    -- Check if battery had any failed/degraded inspection
    SELECT COUNT(*)
    INTO v_degraded_cnt
    FROM BATTERY_INSPECTIONS
    WHERE battery_id = p_battery_id
      AND physical_result = 'FAILED_DEGRADED';

    IF v_degraded_cnt > 0 THEN
        RETURN 'RETIRE_IMMEDIATE';
    END IF;

    v_cycle_ratio := (v_total_swaps / NULLIF(v_rated_cycles, 0)) * 100;

    IF v_cycle_ratio < 40 THEN
        RETURN 'GRADE_A_EXCELLENT';
    ELSIF v_cycle_ratio < 75 THEN
        RETURN 'GRADE_B_GOOD';
    ELSIF v_cycle_ratio < 95 THEN
        RETURN 'GRADE_C_MONITOR';
    ELSE
        RETURN 'GRADE_D_RETIRE_CANDIDATE';
    END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RETURN 'BATTERY_NOT_FOUND';
END get_battery_health_grade;
/
