--------------------------------------------------------
--  DDL for Trigger GENSS2K5SCHEMAKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5SCHEMAKEYTRIG" BEFORE
  INSERT ON STAGE_SS2K5_SCHEMAS FOR EACH ROW BEGIN IF :new.suid_gen IS NULL THEN :new.suid_gen := MD_META.get_next_id;
END IF;
END Genss2k5SchemaKeyTrig;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5SCHEMAKEYTRIG" ENABLE;
