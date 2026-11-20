/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       04_archive_log.sql
  Description:  Archive log mode management and CDB vs PDB architectural scope.
============================================================================
*/

/*
----------------------------------------------------------------------------
ARCHITECTURAL EXPLANATION: CDB VS. PDB ARCHIVELOG SCOPE
----------------------------------------------------------------------------
In Oracle Multitenant Architecture, the redo log files and the Log Writer (LGWR)
background process exist exclusively at the Container Database (CDB$ROOT) level.
Individual Pluggable Databases (PDBs) share the common system redo log thread 
and do not possess private redo log groups or independent background archivers.
Because redo generation and archiving are instance-wide physical operations,
ARCHIVELOG mode can only be enabled or disabled for the entire CDB as a whole,
never for an isolated individual PDB.
----------------------------------------------------------------------------
*/

-- Step 1: Check Current Database Archive Mode (Run from CDB$ROOT as SYSDBA)
ALTER SESSION SET CONTAINER = CDB$ROOT;

SELECT name, log_mode, open_mode FROM v$database;

-- Detailed archive status
ARCHIVE LOG LIST;

-- ============================================================================
-- Step 2: Enabling ARCHIVELOG Mode (Executed on Local Developer Machine Only)
-- WARNING: Do not execute shutdown on shared AUCA university lab servers!
-- ============================================================================
/*
-- 1. Ensure clean shutdown of all connected sessions
SHUTDOWN IMMEDIATE;

-- 2. Mount the CDB root instance without opening the database
STARTUP MOUNT;

-- 3. Switch database into ARCHIVELOG mode
ALTER DATABASE ARCHIVELOG;

-- 4. Open the CDB
ALTER DATABASE OPEN;

-- 5. Open all pluggable databases
ALTER PLUGGABLE DATABASE ALL OPEN;
*/

-- Step 3: Re-verify Database Archive Mode
SELECT name, log_mode, checkpoint_change# FROM v$database;
ARCHIVE LOG LIST;

-- ============================================================================
-- Step 4: Configure Enterprise Manager Express HTTPS Port
-- Formula: 55xx where xx is the last 2 digits of Student ID (20251SEN197 -> 97)
-- Port: 5597
-- ============================================================================
ALTER SESSION SET CONTAINER = b_197_felicien_voltswap_db;

EXEC DBMS_XDB_CONFIG.SETHTTPSPORT(5597);

-- Verify the port configured for this PDB
SELECT DBMS_XDB_CONFIG.GETHTTPSPORT() AS em_express_port FROM dual;
