--------------------------------------------------------
--  DDL for Trigger INS_APPLICATIONFILE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."INS_APPLICATIONFILE_TRG" BEFORE INSERT OR UPDATE ON MD_APPLICATIONFILES
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."INS_APPLICATIONFILE_TRG" ENABLE;
