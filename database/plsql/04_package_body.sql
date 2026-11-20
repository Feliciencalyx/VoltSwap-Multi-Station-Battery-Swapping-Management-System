/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/plsql/04_package_body.sql
  Description:  Package body PKG_VOLTSWAP_OPS implementing explicit cursors,
                BULK COLLECT, FORALL, user-defined records, and exception logic.
============================================================================
*/

CREATE OR REPLACE PACKAGE BODY PKG_VOLTSWAP_OPS IS

    -- Cursor Implementation
    CURSOR cur_station_swaps (
        p_station_id   VARCHAR2,
        p_target_date  DATE
    ) RETURN SWAP_TRANSACTIONS%ROWTYPE IS
        SELECT *
        FROM SWAP_TRANSACTIONS
        WHERE station_id = p_station_id
          AND TRUNC(swap_time) = TRUNC(p_target_date)
        ORDER BY swap_time ASC;

    -- ----------------------------------------------------------------------
    -- Procedure: generate_daily_reconciliation
    -- Demonstrates: Explicit cursor, OPEN/FETCH/CLOSE, %ROWTYPE, and summary math
    -- ----------------------------------------------------------------------
    PROCEDURE generate_daily_reconciliation (
        p_station_id   IN VARCHAR2,
        p_target_date  IN DATE DEFAULT TRUNC(SYSDATE)
    ) IS
        v_swap_row          SWAP_TRANSACTIONS%ROWTYPE;
        v_station_name      STATIONS.station_name%TYPE;
        v_count             NUMBER := 0;
        v_total_energy      NUMBER(8,2) := 0;
        v_total_revenue     NUMBER(12,2) := 0;
        v_payment_amount    NUMBER(10,2);
    BEGIN
        SELECT station_name INTO v_station_name
        FROM STATIONS
        WHERE station_id = p_station_id;

        DBMS_OUTPUT.PUT_LINE('================================================================');
        DBMS_OUTPUT.PUT_LINE('VOLTSWAP DAILY STATION RECONCILIATION REPORT');
        DBMS_OUTPUT.PUT_LINE('Station: ' || v_station_name || ' (' || p_station_id || ')');
        DBMS_OUTPUT.PUT_LINE('Date:    ' || TO_CHAR(p_target_date, 'YYYY-MM-DD'));
        DBMS_OUTPUT.PUT_LINE('================================================================');

        OPEN cur_station_swaps(p_station_id, p_target_date);
        LOOP
            FETCH cur_station_swaps INTO v_swap_row;
            EXIT WHEN cur_station_swaps%NOTFOUND;

            v_count := v_count + 1;
            v_total_energy := v_total_energy + v_swap_row.energy_consumed_kwh;

            -- Lookup associated payment
            BEGIN
                SELECT amount_rwf INTO v_payment_amount
                FROM PAYMENTS
                WHERE swap_id = v_swap_row.swap_id;
                v_total_revenue := v_total_revenue + v_payment_amount;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    v_payment_amount := 0;
            END;

            DBMS_OUTPUT.PUT_LINE('Tx ' || v_count || ' | Swap: ' || v_swap_row.swap_id ||
                                 ' | Customer: ' || v_swap_row.customer_id ||
                                 ' | Energy: ' || v_swap_row.energy_consumed_kwh || ' kWh' ||
                                 ' | Billed: ' || v_payment_amount || ' RWF');
        END LOOP;
        CLOSE cur_station_swaps;

        DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('Summary Totals:');
        DBMS_OUTPUT.PUT_LINE('  Total Swaps Completed: ' || v_count);
        DBMS_OUTPUT.PUT_LINE('  Total Energy Dispensed:' || v_total_energy || ' kWh');
        DBMS_OUTPUT.PUT_LINE('  Total Revenue Settled: ' || TO_CHAR(v_total_revenue, '999,999,999') || ' RWF');
        DBMS_OUTPUT.PUT_LINE('================================================================');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF cur_station_swaps%ISOPEN THEN
                CLOSE cur_station_swaps;
            END IF;
            DBMS_OUTPUT.PUT_LINE('Error: Station ID ' || p_station_id || ' does not exist.');
        WHEN OTHERS THEN
            IF cur_station_swaps%ISOPEN THEN
                CLOSE cur_station_swaps;
            END IF;
            RAISE_APPLICATION_ERROR(-20040, 'Error in generate_daily_reconciliation: ' || SQLERRM);
    END generate_daily_reconciliation;

    -- ----------------------------------------------------------------------
    -- Procedure: batch_update_battery_cycles
    -- Demonstrates: BULK COLLECT and FORALL batch DML processing
    -- ----------------------------------------------------------------------
    PROCEDURE batch_update_battery_cycles (
        p_min_swaps IN NUMBER DEFAULT 1
    ) IS
        TYPE t_bat_id_list IS TABLE OF BATTERIES.battery_id%TYPE;
        v_bat_ids t_bat_id_list;
    BEGIN
        -- Collect all active batteries with swap history
        SELECT battery_id
        BULK COLLECT INTO v_bat_ids
        FROM BATTERIES
        WHERE total_swaps >= p_min_swaps;

        IF v_bat_ids.COUNT > 0 THEN
            -- Bulk update recalculating swap tally from swap transactions
            FORALL i IN 1..v_bat_ids.COUNT
                UPDATE BATTERIES b
                SET b.total_swaps = (
                    SELECT COUNT(*)
                    FROM SWAP_TRANSACTIONS s
                    WHERE s.battery_in_id = b.battery_id OR s.battery_out_id = b.battery_id
                )
                WHERE b.battery_id = v_bat_ids(i);

            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Successfully batch-recalculated cycles for ' || v_bat_ids.COUNT || ' batteries.');
        ELSE
            DBMS_OUTPUT.PUT_LINE('No batteries matching criteria.');
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE_APPLICATION_ERROR(-20041, 'Error in batch_update_battery_cycles: ' || SQLERRM);
    END batch_update_battery_cycles;

    -- ----------------------------------------------------------------------
    -- Function: get_network_health_index
    -- Returns percentage of healthy battery stock across all stations
    -- ----------------------------------------------------------------------
    FUNCTION get_network_health_index RETURN NUMBER IS
        v_total_batteries NUMBER := 0;
        v_healthy_count   NUMBER := 0;
        v_health_index    NUMBER(5,2) := 0;
    BEGIN
        SELECT COUNT(*),
               COUNT(CASE WHEN health_status IN ('CHARGED', 'IN_USE', 'CHARGING') THEN 1 END)
        INTO v_total_batteries, v_healthy_count
        FROM BATTERIES;

        IF v_total_batteries > 0 THEN
            v_health_index := ROUND((v_healthy_count / v_total_batteries) * 100, 2);
        END IF;

        RETURN v_health_index;
    END get_network_health_index;

    -- ----------------------------------------------------------------------
    -- Function: get_station_summary_json
    -- Formats station operational state into standard JSON
    -- ----------------------------------------------------------------------
    FUNCTION get_station_summary_json (
        p_station_id IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_rec  t_station_summary_rec;
        v_json VARCHAR2(1000);
    BEGIN
        SELECT s.station_id, s.station_name, s.district,
               COUNT(sw.swap_id),
               NVL(SUM(sw.energy_consumed_kwh), 0),
               NVL(SUM(p.amount_rwf), 0),
               (SELECT COUNT(*) FROM BATTERIES b WHERE b.current_station_id = s.station_id AND b.health_status = 'CHARGED')
        INTO v_rec.station_id, v_rec.station_name, v_rec.district,
             v_rec.total_swaps, v_rec.total_energy_kwh, v_rec.total_revenue_rwf, v_rec.active_batteries
        FROM STATIONS s
        LEFT JOIN SWAP_TRANSACTIONS sw ON s.station_id = sw.station_id
        LEFT JOIN PAYMENTS p ON sw.swap_id = p.swap_id
        WHERE s.station_id = p_station_id
        GROUP BY s.station_id, s.station_name, s.district;

        v_json := '{"station_id":"' || v_rec.station_id || '",' ||
                  '"station_name":"' || v_rec.station_name || '",' ||
                  '"district":"' || v_rec.district || '",' ||
                  '"total_swaps":' || v_rec.total_swaps || ',' ||
                  '"energy_kwh":' || v_rec.total_energy_kwh || ',' ||
                  '"revenue_rwf":' || v_rec.total_revenue_rwf || ',' ||
                  '"charged_ready":' || v_rec.active_batteries || '}';

        RETURN v_json;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN '{"error":"Station not found"}';
    END get_station_summary_json;

END PKG_VOLTSWAP_OPS;
/
