--------------------------------------------------------
--  DDL for Trigger STAGE_MIGRLOG_ID_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."STAGE_MIGRLOG_ID_TRG" BEFORE INSERT OR UPDATE ON STAGE_MIGRLOG
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."STAGE_MIGRLOG_ID_TRG" ENABLE;
