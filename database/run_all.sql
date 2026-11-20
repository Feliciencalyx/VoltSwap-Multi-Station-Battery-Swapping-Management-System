/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/run_all.sql
  Description:  Master deployment script running Schema (Phase IV), 
                PL/SQL Logic (Phase V), Auditing & Triggers (Phase VI),
                and Comprehensive Test Suites in order.
============================================================================
*/

PROMPT ============================================================================
PROMPT STARTING FULL VOLTSWAP DATABASE DEPLOYMENT
PROMPT ============================================================================
SET ECHO ON;
SET FEEDBACK ON;
SET SERVEROUTPUT ON;

PROMPT
PROMPT >>> STEP 1: Creating 3NF Relational Tables & Constraints (Phase IV)...
@database/schema/01_tables.sql;

PROMPT
PROMPT >>> STEP 2: Loading Cleaned Operational Data (Phase IV ETL)...
@database/schema/02_insert_clean_data.sql;

PROMPT
PROMPT >>> STEP 3: Validating Data Loading and Integrity (Phase IV)...
@database/schema/03_validate_data.sql;

PROMPT
PROMPT >>> STEP 4: Compiling Stored Functions (Phase V)...
@database/plsql/01_functions.sql;

PROMPT
PROMPT >>> STEP 5: Compiling Stored Procedures (Phase V)...
@database/plsql/02_procedures.sql;

PROMPT
PROMPT >>> STEP 6: Compiling Package Specification (Phase V)...
@database/plsql/03_package_spec.sql;

PROMPT
PROMPT >>> STEP 7: Compiling Package Body (Phase V)...
@database/plsql/04_package_body.sql;

PROMPT
PROMPT >>> STEP 8: Creating Audit Log Table and Autonomous Procedures (Phase VI)...
@database/audit/01_audit_tables.sql;

PROMPT
PROMPT >>> STEP 9: Creating Business & Security Restriction Triggers (Phase VI)...
@database/audit/02_triggers.sql;

PROMPT
PROMPT >>> STEP 10: Running Success Test Suite...
@database/tests/test_success_cases.sql;

PROMPT
PROMPT >>> STEP 11: Running Negative & Security Error Test Suite...
@database/tests/test_error_cases.sql;

PROMPT
PROMPT ============================================================================
PROMPT FULL VOLTSWAP DATABASE DEPLOYMENT COMPLETED SUCCESSFULLY!
PROMPT ============================================================================
