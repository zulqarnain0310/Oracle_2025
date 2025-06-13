--------------------------------------------------------
--  DDL for Trigger GENSS2K5DB2KEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5DB2KEYTRIG" BEFORE
  INSERT ON STAGE_SS2K5_DATABASES FOR EACH ROW BEGIN IF :new.dbid_gen IS NULL THEN :new.dbid_gen := MD_META.get_next_id;
END IF;
END Genss2k5Db2KeyTrig;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5DB2KEYTRIG" ENABLE;
