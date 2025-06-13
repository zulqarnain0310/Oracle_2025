--------------------------------------------------------
--  DDL for Trigger MIGR_DATATYPE_RULE_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."MIGR_DATATYPE_RULE_TRG" BEFORE INSERT OR UPDATE ON MIGR_DATATYPE_TRANSFORM_RULE
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."MIGR_DATATYPE_RULE_TRG" ENABLE;
