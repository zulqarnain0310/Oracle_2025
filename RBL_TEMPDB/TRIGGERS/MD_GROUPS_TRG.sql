--------------------------------------------------------
--  DDL for Trigger MD_GROUPS_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."MD_GROUPS_TRG" BEFORE INSERT OR UPDATE ON MD_GROUPS
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_TEMPDB"."MD_GROUPS_TRG" ENABLE;
