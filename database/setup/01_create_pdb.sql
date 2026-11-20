/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       01_create_pdb.sql
  Description:  Creates and opens the Pluggable Database (PDB) and preserves 
                its open state across CDB instance restarts.
============================================================================
*/

-- Step 1: Connect as SYSDBA at the Container Database (CDB$ROOT) level
-- Example: CONNECT sys/password@localhost:1521/FREE as SYSDBA;

WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Ensure session is in the CDB root
ALTER SESSION SET CONTAINER = CDB$ROOT;

-- Check existing PDBs
SELECT name, open_mode, restricted FROM v$pdbs;

-- Step 2: Create the Pluggable Database following the mandatory naming convention:
-- Pattern: GroupName_StudentID_FirstName_ProjectName_DB
-- Name: b_197_felicien_voltswap_db (25 characters <= 30 character limit)
CREATE PLUGGABLE DATABASE b_197_felicien_voltswap_db
  ADMIN USER pdbadmin IDENTIFIED BY PdbAdminPass123
  ROLES = (DBA)
  FILE_NAME_CONVERT = ('pdbseed', 'b_197_felicien_voltswap_db');

-- Step 3: Open the Pluggable Database in READ WRITE mode
ALTER PLUGGABLE DATABASE b_197_felicien_voltswap_db OPEN;

-- Step 4: Save the PDB open state so it automatically restarts when the CDB boots
ALTER PLUGGABLE DATABASE b_197_felicien_voltswap_db SAVE STATE;

-- Step 5: Verify creation and open state
SELECT con_id, name, open_mode, restricted 
FROM v$pdbs 
WHERE name = UPPER('b_197_felicien_voltswap_db');
