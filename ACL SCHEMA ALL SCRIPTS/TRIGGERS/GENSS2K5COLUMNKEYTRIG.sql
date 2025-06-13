--------------------------------------------------------
--  DDL for Trigger GENSS2K5COLUMNKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5COLUMNKEYTRIG" BEFORE
  INSERT ON STAGE_SS2K5_COLUMNS FOR EACH ROW BEGIN IF :new.colid_gen IS NULL THEN :new.colid_gen := MD_META.get_next_id;
END IF;
END Genss2k5ColumnKeyTrig;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5COLUMNKEYTRIG" ENABLE;
