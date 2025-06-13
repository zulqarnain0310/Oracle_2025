--------------------------------------------------------
--  DDL for Trigger MIGRLOG_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."MIGRLOG_TRG" BEFORE INSERT OR UPDATE ON MIGRLOG
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."MIGRLOG_TRG" ENABLE;
