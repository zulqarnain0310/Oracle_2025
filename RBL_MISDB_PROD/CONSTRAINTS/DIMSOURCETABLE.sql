--------------------------------------------------------
--  Constraints for Table DIMSOURCETABLE
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMSOURCETABLE" MODIFY ("SOURCETABLE_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMSOURCETABLE" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
