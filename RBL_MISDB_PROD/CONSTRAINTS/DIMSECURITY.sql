--------------------------------------------------------
--  Constraints for Table DIMSECURITY
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMSECURITY" MODIFY ("SECURITY_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMSECURITY" MODIFY ("SECURITYALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMSECURITY" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
