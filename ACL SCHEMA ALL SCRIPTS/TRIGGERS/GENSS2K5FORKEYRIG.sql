--------------------------------------------------------
--  DDL for Trigger GENSS2K5FORKEYRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5FORKEYRIG" BEFORE
  INSERT ON STAGE_SS2K5_FN_KEYS FOR EACH ROW BEGIN IF :new.OBJECT_ID_gen IS NULL THEN :new.OBJECT_ID_gen := MD_META.get_next_id;
END IF;
END Genss2k5ForKeyTrig;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5FORKEYRIG" ENABLE;
