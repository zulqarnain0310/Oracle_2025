--------------------------------------------------------
--  DDL for Trigger MIGR_DATATYPE_MAP_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."MIGR_DATATYPE_MAP_TRG" BEFORE INSERT OR UPDATE ON MIGR_DATATYPE_TRANSFORM_MAP
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "RBL_TEMPDB"."MIGR_DATATYPE_MAP_TRG" ENABLE;
