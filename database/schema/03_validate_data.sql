/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/schema/03_validate_data.sql
  Description:  Data validation queries for Phase IV checking row counts,
                referential integrity, and constraint adherence.
============================================================================
*/

SET LINESIZE 180;
SET PAGESIZE 100;

PROMPT ============================================================================
PROMPT TABLE ROW COUNTS POST-LOAD
PROMPT ============================================================================
SELECT 'CUSTOMERS' AS table_name, COUNT(*) AS row_count FROM CUSTOMERS
UNION ALL
SELECT 'STATIONS', COUNT(*) FROM STATIONS
UNION ALL
SELECT 'BATTERY_MODELS', COUNT(*) FROM BATTERY_MODELS
UNION ALL
SELECT 'BATTERIES', COUNT(*) FROM BATTERIES
UNION ALL
SELECT 'SWAP_TRANSACTIONS', COUNT(*) FROM SWAP_TRANSACTIONS
UNION ALL
SELECT 'PAYMENTS', COUNT(*) FROM PAYMENTS
UNION ALL
SELECT 'BATTERY_INSPECTIONS', COUNT(*) FROM BATTERY_INSPECTIONS;

PROMPT
PROMPT ============================================================================
PROMPT REFERENTIAL INTEGRITY CHECK (LOOKING FOR ORPHANED TRANSACTIONS)
PROMPT ============================================================================
-- Check 1: Swaps without valid customer
SELECT COUNT(*) AS orphaned_customer_swaps
FROM SWAP_TRANSACTIONS s
WHERE NOT EXISTS (SELECT 1 FROM CUSTOMERS c WHERE c.customer_id = s.customer_id);

-- Check 2: Swaps without valid station
SELECT COUNT(*) AS orphaned_station_swaps
FROM SWAP_TRANSACTIONS s
WHERE NOT EXISTS (SELECT 1 FROM STATIONS st WHERE st.station_id = s.station_id);

-- Check 3: Payments without matching swap
SELECT COUNT(*) AS orphaned_payments
FROM PAYMENTS p
WHERE NOT EXISTS (SELECT 1 FROM SWAP_TRANSACTIONS s WHERE s.swap_id = p.swap_id);

PROMPT
PROMPT ============================================================================
PROMPT REVENUE AND ENERGY RECONCILIATION SUMMARY
PROMPT ============================================================================
SELECT 
    COUNT(s.swap_id) AS total_swaps_completed,
    ROUND(SUM(s.energy_consumed_kwh), 2) AS total_energy_kwh,
    ROUND(AVG(s.energy_consumed_kwh), 2) AS avg_kwh_per_swap,
    TO_CHAR(SUM(p.amount_rwf), '999,999,999') || ' RWF' AS total_revenue_rwf,
    p.payment_method,
    COUNT(p.payment_id) AS payment_transactions
FROM SWAP_TRANSACTIONS s
JOIN PAYMENTS p ON s.swap_id = p.swap_id
GROUP BY p.payment_method;
