/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/schema/03_validate_data.sql
  Description:  Data validation queries checking row counts, referential
                integrity, and empirical metric reconciliations.
============================================================================
*/

SET LINESIZE 180;
SET PAGESIZE 100;

PROMPT ============================================================================
PROMPT TABLE ROW COUNTS POST-LOAD (EMBSCS EMPIRICAL DATASET)
PROMPT ============================================================================
SELECT 'STATIONS (Target: 34)' AS table_name, COUNT(*) AS row_count FROM STATIONS
UNION ALL
SELECT 'STATION_DAILY_METRICS (Target: 3,128)', COUNT(*) FROM STATION_DAILY_METRICS
UNION ALL
SELECT 'STATION_DISRUPTIONS', COUNT(*) FROM STATION_DISRUPTIONS
UNION ALL
SELECT 'BATTERY_MODELS', COUNT(*) FROM BATTERY_MODELS
UNION ALL
SELECT 'BATTERIES', COUNT(*) FROM BATTERIES
UNION ALL
SELECT 'CUSTOMERS', COUNT(*) FROM CUSTOMERS
UNION ALL
SELECT 'SWAP_TRANSACTIONS', COUNT(*) FROM SWAP_TRANSACTIONS
UNION ALL
SELECT 'PAYMENTS', COUNT(*) FROM PAYMENTS
UNION ALL
SELECT 'BATTERY_INSPECTIONS', COUNT(*) FROM BATTERY_INSPECTIONS;

PROMPT
PROMPT ============================================================================
PROMPT EMPIRICAL TELEMETRY AGGREGATION RECONCILIATION
PROMPT ============================================================================
SELECT 
    COUNT(DISTINCT station_id) AS active_reporting_stations,
    MIN(operation_date) AS earliest_date,
    MAX(operation_date) AS latest_date,
    SUM(swap_throughput) AS grand_total_swaps,
    ROUND(AVG(swap_throughput), 1) AS avg_daily_swaps_per_hub,
    ROUND(AVG(avg_swap_time_min), 2) AS network_avg_swap_time_mins,
    ROUND(AVG(avg_soc_pct), 1) AS network_avg_arrival_soc_pct
FROM STATION_DAILY_METRICS;

PROMPT
PROMPT ============================================================================
PROMPT TOP 5 HIGHEST VOLUME STATIONS (92-DAY EMPIRICAL DATA)
PROMPT ============================================================================
SELECT 
    s.station_id,
    s.station_name,
    s.district,
    s.total_bays,
    SUM(m.swap_throughput) AS cumulative_swaps,
    ROUND(AVG(m.swap_throughput), 1) AS daily_avg_swaps
FROM STATIONS s
JOIN STATION_DAILY_METRICS m ON s.station_id = m.station_id
GROUP BY s.station_id, s.station_name, s.district, s.total_bays
ORDER BY cumulative_swaps DESC
FETCH FIRST 5 ROWS ONLY;
