--------------------------------------------------------
--  DDL for Trigger STAGE_MIGRLOG_LOG_DATE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."STAGE_MIGRLOG_LOG_DATE_TRG" BEFORE INSERT OR UPDATE ON STAGE_MIGRLOG
FOR EACH ROW
BEGIN
  if inserting and :new.log_date is null then
        :new.log_date := systimestamp;
    end if;
END;

/
ALTER TRIGGER "RBL_TEMPDB"."STAGE_MIGRLOG_LOG_DATE_TRG" ENABLE;
