--------------------------------------------------------
--  DDL for Trigger MIGR_GENERATION_ORDER_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."MIGR_GENERATION_ORDER_TRG" BEFORE INSERT OR UPDATE ON MIGR_GENERATION_ORDER
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_TEMPDB"."MIGR_GENERATION_ORDER_TRG" ENABLE;
