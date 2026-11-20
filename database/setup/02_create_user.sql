/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       02_create_user.sql
  Description:  Creates the dedicated PDB admin user, assigns the DBA role,
                and prepares the administrative schema.
============================================================================
*/

WHENEVER SQLERROR EXIT SQL.SQLCODE;

-- Step 1: Switch session into our project's Pluggable Database
ALTER SESSION SET CONTAINER = b_197_felicien_voltswap_db;

-- Confirm current container
SELECT SYS_CONTEXT('USERENV', 'CON_NAME') AS current_container FROM dual;

-- Step 2: Create the PDB admin user following the mandatory convention:
-- Username: firstname_admin  => felicien_admin
-- Password: firstname        => felicien (Lab convention only)
CREATE USER felicien_admin IDENTIFIED BY felicien;

-- Step 3: Grant the DBA role and essential session privileges
GRANT CONNECT, RESOURCE, DBA TO felicien_admin;
GRANT UNLIMITED TABLESPACE TO felicien_admin;

-- Step 4: Verification query
SELECT username, account_status, default_tablespace, created 
FROM dba_users 
WHERE username = UPPER('felicien_admin');

-- Verify granted roles
SELECT grantee, granted_role, admin_option 
FROM dba_role_privs 
WHERE grantee = UPPER('felicien_admin');
