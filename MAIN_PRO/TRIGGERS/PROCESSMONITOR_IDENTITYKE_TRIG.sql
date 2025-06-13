--------------------------------------------------------
--  DDL for Trigger PROCESSMONITOR_IDENTITYKE_TRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "MAIN_PRO"."PROCESSMONITOR_IDENTITYKE_TRIG" BEFORE INSERT OR UPDATE ON ProcessMonitor
FOR EACH ROW
DECLARE 
v_newVal NUMBER(12) := 0;
v_incval NUMBER(12) := 0;
BEGIN
  IF INSERTING AND :new.IdentityKey IS NULL THEN
    SELECT  ProcessMonitor_IdentityKey_SEQ.NEXTVAL INTO v_newVal FROM DUAL;
    -- If this is the first time this table have been inserted into (sequence == 1)
    IF v_newVal = 1 THEN 
      --get the max indentity value from the table
      SELECT NVL(max(IdentityKey),0) INTO v_newVal FROM ProcessMonitor;
      v_newVal := v_newVal + 1;
      --set the sequence to that value
      LOOP
           EXIT WHEN v_incval>=v_newVal;
           SELECT ProcessMonitor_IdentityKey_SEQ.nextval INTO v_incval FROM dual;
      END LOOP;
    END IF;
   -- assign the value from the sequence to emulate the identity column
   :new.IdentityKey := v_newVal;
  END IF;
END;
/
ALTER TRIGGER "MAIN_PRO"."PROCESSMONITOR_IDENTITYKE_TRIG" ENABLE;
