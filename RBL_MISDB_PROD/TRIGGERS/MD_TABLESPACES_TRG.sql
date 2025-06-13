--------------------------------------------------------
--  DDL for Trigger MD_TABLESPACES_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."MD_TABLESPACES_TRG" BEFORE INSERT OR UPDATE ON MD_TABLESPACES
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."MD_TABLESPACES_TRG" ENABLE;
