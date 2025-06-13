--------------------------------------------------------
--  DDL for Trigger GENSS2K5SQLTABTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."GENSS2K5SQLTABTRIG" BEFORE
  INSERT ON STAGE_SS2K5_SQL_MODULES FOR EACH ROW BEGIN IF :new.OBJID_GEN IS NULL THEN :new.OBJID_GEN := MD_META.get_next_id;
END IF;
END Genss2k5SqlTabTrig;

/
ALTER TRIGGER "RBL_TEMPDB"."GENSS2K5SQLTABTRIG" ENABLE;
