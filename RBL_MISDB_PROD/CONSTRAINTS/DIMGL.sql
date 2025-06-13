--------------------------------------------------------
--  Constraints for Table DIMGL
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMGL" MODIFY ("GL_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMGL" MODIFY ("GLALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMGL" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
