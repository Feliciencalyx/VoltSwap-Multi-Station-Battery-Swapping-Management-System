/*
============================================================================
  Course:       INSY 8311 – Database Development with PL/SQL
  Student Name: NSHIMYUMUKIZA Felicien
  Student ID:   20251SEN197
  Group:        Group B
  Project Name: VoltSwap Multi-Station Battery Swapping Management System
  Script:       database/audit/01_audit_tables.sql
  Description:  Creates the security auditing table AUDIT_LOG and autonomous
                logging procedure to track transactional anomalies and violations.
============================================================================
*/

PROMPT Creating Table: AUDIT_LOG...

CREATE TABLE AUDIT_LOG (
    log_id          NUMBER GENERATED ALWAYS AS IDENTITY,
    log_timestamp   TIMESTAMP       DEFAULT SYSTIMESTAMP NOT NULL,
    db_user         VARCHAR2(50)    DEFAULT USER NOT NULL,
    os_user         VARCHAR2(50),
    client_terminal VARCHAR2(50),
    action_type     VARCHAR2(30)    NOT NULL,
    target_table    VARCHAR2(50)    NOT NULL,
    record_id       VARCHAR2(50),
    details         VARCHAR2(500),
    security_level  VARCHAR2(20)    DEFAULT 'INFO' NOT NULL,
    CONSTRAINT pk_audit_log PRIMARY KEY (log_id),
    CONSTRAINT chk_audit_sec CHECK (security_level IN ('INFO', 'WARNING', 'VIOLATION', 'CRITICAL'))
);

CREATE INDEX idx_audit_time ON AUDIT_LOG(log_timestamp);
CREATE INDEX idx_audit_target ON AUDIT_LOG(target_table);

-- --------------------------------------------------------------------------
-- Autonomous Transaction Procedure: log_audit_event
-- Writes to AUDIT_LOG independently of parent transaction commit/rollback
-- --------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE log_audit_event (
    p_action_type    IN VARCHAR2,
    p_target_table   IN VARCHAR2,
    p_record_id      IN VARCHAR2,
    p_details        IN VARCHAR2,
    p_security_level IN VARCHAR2 DEFAULT 'INFO'
) IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO AUDIT_LOG (
        log_timestamp, db_user, os_user, client_terminal,
        action_type, target_table, record_id, details, security_level
    ) VALUES (
        SYSTIMESTAMP,
        USER,
        SYS_CONTEXT('USERENV', 'OS_USER'),
        SYS_CONTEXT('USERENV', 'TERMINAL'),
        p_action_type,
        p_target_table,
        p_record_id,
        p_details,
        p_security_level
    );
    COMMIT;
EXCEPTION
    WHEN OTHERS THEN
        ROLLBACK;
END log_audit_event;
/

PROMPT Audit log table and autonomous logger created.
