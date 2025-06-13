--------------------------------------------------------
--  DDL for Trigger GENSS2K5CHKCONSTTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5CHKCONSTTRIG" BEFORE
  INSERT ON STAGE_SS2K5_TABLES FOR EACH ROW BEGIN IF :new.objid_gen IS NULL THEN :new.objid_gen := MD_META.get_next_id;
END IF;
END Genss2k5ChkConstTrig;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5CHKCONSTTRIG" ENABLE;
