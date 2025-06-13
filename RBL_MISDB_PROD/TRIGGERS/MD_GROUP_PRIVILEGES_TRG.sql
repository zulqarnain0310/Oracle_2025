--------------------------------------------------------
--  DDL for Trigger MD_GROUP_PRIVILEGES_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."MD_GROUP_PRIVILEGES_TRG" BEFORE INSERT OR UPDATE ON MD_GROUP_PRIVILEGES
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."MD_GROUP_PRIVILEGES_TRG" ENABLE;
