--------------------------------------------------------
--  DDL for Trigger MD_PACKAGES_TRG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."MD_PACKAGES_TRG" BEFORE INSERT OR UPDATE ON MD_PACKAGES
FOR EACH ROW
BEGIN
  if inserting and :new.id is null then
        :new.id := MD_META.get_next_id;
    end if;
END;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."MD_PACKAGES_TRG" ENABLE;
