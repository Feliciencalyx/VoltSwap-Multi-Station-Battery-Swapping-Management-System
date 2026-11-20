/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       03_tablespaces.sql
  Description:  Configures project data, index, and temporary tablespaces,
                sets user defaults, and allocates storage quotas.
============================================================================
*/

WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Step 1: Ensure session is in the VoltSwap Pluggable Database
ALTER SESSION SET CONTAINER = b_197_felicien_voltswap_db;

-- Step 2: Create Data Tablespace: <project>_data
-- Sizing: 100M initial, AUTOEXTEND ON NEXT 10M MAXSIZE 1G
CREATE TABLESPACE voltswap_data
  DATAFILE 'voltswap_data01.dbf' SIZE 100M
  AUTOEXTEND ON NEXT 10M MAXSIZE 1G
  EXTENT MANAGEMENT LOCAL
  SEGMENT SPACE MANAGEMENT AUTO;

-- Step 3: Create Index Tablespace: <project>_idx
-- Sizing: 50M initial, AUTOEXTEND ON NEXT 10M MAXSIZE 500M
CREATE TABLESPACE voltswap_idx
  DATAFILE 'voltswap_idx01.dbf' SIZE 50M
  AUTOEXTEND ON NEXT 10M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL
  SEGMENT SPACE MANAGEMENT AUTO;

-- Step 4: Create Temporary Tablespace: <project>_temp
-- Sizing: 50M initial, AUTOEXTEND ON NEXT 10M MAXSIZE 500M
CREATE TEMPORARY TABLESPACE voltswap_temp
  TEMPFILE 'voltswap_temp01.dbf' SIZE 50M
  AUTOEXTEND ON NEXT 10M MAXSIZE 500M
  EXTENT MANAGEMENT LOCAL;

-- Step 5: Configure Admin User Defaults and Storage Quotas
-- Default tablespace -> voltswap_data
-- Temporary tablespace -> voltswap_temp
ALTER USER felicien_admin DEFAULT TABLESPACE voltswap_data;
ALTER USER felicien_admin TEMPORARY TABLESPACE voltswap_temp;

-- Unlimited quota on both Data and Index tablespaces
ALTER USER felicien_admin QUOTA UNLIMITED ON voltswap_data;
ALTER USER felicien_admin QUOTA UNLIMITED ON voltswap_idx;

-- Step 6: Verify Tablespaces and Datafile Configurations
SELECT tablespace_name, status, contents, extent_management, allocation_type
FROM dba_tablespaces
WHERE tablespace_name IN ('VOLTSWAP_DATA', 'VOLTSWAP_IDX', 'VOLTSWAP_TEMP');

SELECT file_name, tablespace_name, bytes/1024/1024 AS size_mb, maxbytes/1024/1024 AS max_mb, autoextensible
FROM dba_data_files
WHERE tablespace_name IN ('VOLTSWAP_DATA', 'VOLTSWAP_IDX')
UNION ALL
SELECT file_name, tablespace_name, bytes/1024/1024 AS size_mb, maxbytes/1024/1024 AS max_mb, autoextensible
FROM dba_temp_files
WHERE tablespace_name = 'VOLTSWAP_TEMP';

-- Check user quota allocation
SELECT username, tablespace_name, bytes/1024/1024 AS used_mb, max_bytes
FROM dba_ts_quotas
WHERE username = UPPER('felicien_admin');
