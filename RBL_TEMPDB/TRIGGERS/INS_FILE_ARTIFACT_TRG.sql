--------------------------------------------------------
--  DDL for Trigger INS_FILE_ARTIFACT_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."INS_FILE_ARTIFACT_TRG" BEFORE INSERT OR UPDATE ON MD_FILE_ARTIFACTS
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_TEMPDB"."INS_FILE_ARTIFACT_TRG" ENABLE;
