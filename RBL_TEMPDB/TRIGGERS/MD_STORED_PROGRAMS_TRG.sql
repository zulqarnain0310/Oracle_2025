--------------------------------------------------------
--  DDL for Trigger MD_STORED_PROGRAMS_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."MD_STORED_PROGRAMS_TRG" BEFORE INSERT OR UPDATE ON MD_STORED_PROGRAMS
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_TEMPDB"."MD_STORED_PROGRAMS_TRG" ENABLE;
