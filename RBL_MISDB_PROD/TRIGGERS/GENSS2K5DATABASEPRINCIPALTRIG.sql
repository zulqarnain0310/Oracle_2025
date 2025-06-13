--------------------------------------------------------
--  DDL for Trigger GENSS2K5DATABASEPRINCIPALTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."GENSS2K5DATABASEPRINCIPALTRIG" BEFORE
  INSERT ON STAGE_SS2K5_DB_PRINCIPALS FOR EACH ROW BEGIN IF :new.prinid_gen IS NULL THEN :new.prinid_gen := MD_META.get_next_id;
END IF;
END Genss2k5DatabasePrincipalTrig;

/
ALTER TRIGGER "RBL_MISDB_PROD"."GENSS2K5DATABASEPRINCIPALTRIG" ENABLE;
