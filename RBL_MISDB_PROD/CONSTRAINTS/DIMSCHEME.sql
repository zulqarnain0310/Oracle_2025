--------------------------------------------------------
--  Constraints for Table DIMSCHEME
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMSCHEME" MODIFY ("SCHEME_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMSCHEME" MODIFY ("SCHEMEALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMSCHEME" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
