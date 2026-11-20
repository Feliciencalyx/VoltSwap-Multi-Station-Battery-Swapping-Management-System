/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/plsql/03_package_spec.sql
  Description:  Package specification PKG_VOLTSWAP_OPS defining operational
                cursors, record structures, collections, and management APIs.
============================================================================
*/

CREATE OR REPLACE PACKAGE PKG_VOLTSWAP_OPS IS

    -- 1. User-Defined Record Type
    TYPE t_station_summary_rec IS RECORD (
        station_id          VARCHAR2(20),
        station_name        VARCHAR2(100),
        district            VARCHAR2(50),
        total_swaps         NUMBER,
        total_energy_kwh    NUMBER(8,2),
        total_revenue_rwf   NUMBER(12,2),
        active_batteries    NUMBER
    );

    -- 2. PL/SQL Collection Type (Associative Array)
    TYPE t_swap_summary_list IS TABLE OF t_station_summary_rec INDEX BY PLS_INTEGER;

    -- 3. Explicit Parameterized Cursor
    CURSOR cur_station_swaps (
        p_station_id   VARCHAR2,
        p_target_date  DATE
    ) RETURN SWAP_TRANSACTIONS%ROWTYPE;

    -- 4. Public Procedures and Functions
    PROCEDURE generate_daily_reconciliation (
        p_station_id   IN VARCHAR2,
        p_target_date  IN DATE DEFAULT TRUNC(SYSDATE)
    );

    PROCEDURE batch_update_battery_cycles (
        p_min_swaps    IN NUMBER DEFAULT 1
    );

    FUNCTION get_network_health_index 
        RETURN NUMBER;

    FUNCTION get_station_summary_json (
        p_station_id   IN VARCHAR2
    ) RETURN VARCHAR2;

END PKG_VOLTSWAP_OPS;
/
