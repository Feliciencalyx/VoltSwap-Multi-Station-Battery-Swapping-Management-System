/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       05_verify.sql
  Description:  Comprehensive verification queries for Phase III deliverables:
                PDB status, admin user privileges, tablespaces, and archive mode.
============================================================================
*/

SET LINESIZE 200;
SET PAGESIZE 100;
SET FEEDBACK ON;

PROMPT ============================================================================
PROMPT CHECK 1: PDB EXISTENCE AND OPEN STATUS
PROMPT ============================================================================
SELECT con_id, name, open_mode, restricted, total_size/1024/1024 AS size_mb
FROM v$pdbs
WHERE name = UPPER('b_197_felicien_voltswap_db');

PROMPT
PROMPT ============================================================================
PROMPT CHECK 2: PDB ADMIN USER DEFAULTS AND PRIVILEGES
PROMPT ============================================================================
ALTER SESSION SET CONTAINER = b_197_felicien_voltswap_db;

SELECT username, account_status, default_tablespace, temporary_tablespace, created
FROM dba_users
WHERE username = UPPER('felicien_admin');

-- Verify DBA role assignment
SELECT grantee, granted_role, admin_option, default_role
FROM dba_role_privs
WHERE grantee = UPPER('felicien_admin');

PROMPT
PROMPT ============================================================================
PROMPT CHECK 3: TABLESPACES, DATAFILES, SIZING AND AUTOEXTEND SETTINGS
PROMPT ============================================================================
SELECT 
    d.tablespace_name,
    d.file_name,
    d.bytes / (1024*1024) AS current_size_mb,
    d.increment_by * 8192 / (1024*1024) AS next_extent_mb,
    d.maxbytes / (1024*1024) AS max_size_mb,
    d.autoextensible
FROM dba_data_files d
WHERE d.tablespace_name IN ('VOLTSWAP_DATA', 'VOLTSWAP_IDX')
UNION ALL
SELECT 
    t.tablespace_name,
    t.file_name,
    t.bytes / (1024*1024) AS current_size_mb,
    t.increment_by * 8192 / (1024*1024) AS next_extent_mb,
    t.maxbytes / (1024*1024) AS max_size_mb,
    t.autoextensible
FROM dba_temp_files t
WHERE t.tablespace_name = 'VOLTSWAP_TEMP';

PROMPT
PROMPT ============================================================================
PROMPT CHECK 4: ADMIN USER STORAGE QUOTAS
PROMPT ============================================================================
SELECT username, tablespace_name, bytes/1024/1024 AS used_mb, max_bytes
FROM dba_ts_quotas
WHERE username = UPPER('felicien_admin');

PROMPT
PROMPT ============================================================================
PROMPT CHECK 5: CONTAINER DATABASE ARCHIVELOG MODE
PROMPT ============================================================================
ALTER SESSION SET CONTAINER = CDB$ROOT;

SELECT name, log_mode, open_mode 
FROM v$database;

ARCHIVE LOG LIST;
