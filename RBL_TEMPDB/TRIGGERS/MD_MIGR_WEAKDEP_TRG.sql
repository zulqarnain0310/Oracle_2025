--------------------------------------------------------
--  DDL for Trigger MD_MIGR_WEAKDEP_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."MD_MIGR_WEAKDEP_TRG" BEFORE INSERT OR UPDATE ON MD_MIGR_WEAKDEP
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_TEMPDB"."MD_MIGR_WEAKDEP_TRG" ENABLE;
