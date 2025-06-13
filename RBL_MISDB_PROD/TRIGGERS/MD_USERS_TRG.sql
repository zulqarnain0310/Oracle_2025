--------------------------------------------------------
--  DDL for Trigger MD_USERS_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."MD_USERS_TRG" BEFORE INSERT OR UPDATE ON MD_USERS
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."MD_USERS_TRG" ENABLE;
