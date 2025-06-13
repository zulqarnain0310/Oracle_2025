--------------------------------------------------------
--  DDL for Trigger GENSS2K5INDEXTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5INDEXTRIG" BEFORE
  INSERT ON STAGE_SS2K5_INDEXES FOR EACH ROW BEGIN IF :new.object_id_gen IS NULL THEN :new.object_id_gen := MD_META.get_next_id;
END IF;
END Genss2k5IndexTrig;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."GENSS2K5INDEXTRIG" ENABLE;
