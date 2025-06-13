--------------------------------------------------------
--  Constraints for Table DIMSECURITYCHARGETYPE
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMSECURITYCHARGETYPE" MODIFY ("SECURITYCHARGETYPE_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMSECURITYCHARGETYPE" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
