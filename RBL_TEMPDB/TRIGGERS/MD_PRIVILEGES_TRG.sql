--------------------------------------------------------
--  DDL for Trigger MD_PRIVILEGES_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."MD_PRIVILEGES_TRG" BEFORE INSERT OR UPDATE ON MD_PRIVILEGES
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_TEMPDB"."MD_PRIVILEGES_TRG" ENABLE;
