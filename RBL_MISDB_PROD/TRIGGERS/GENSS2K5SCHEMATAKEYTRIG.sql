--------------------------------------------------------
--  DDL for Trigger GENSS2K5SCHEMATAKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."GENSS2K5SCHEMATAKEYTRIG" BEFORE
  INSERT ON STAGE_SS2K5_SCHEMATA FOR EACH ROW BEGIN IF :new.suid_gen IS NULL THEN :new.suid_gen := MD_META.get_next_id;
END IF;
END Genss2k5SchemayaKeyTrig;

/
ALTER TRIGGER "RBL_MISDB_PROD"."GENSS2K5SCHEMATAKEYTRIG" ENABLE;
