--------------------------------------------------------
--  Constraints for Table DIMACTIVITY
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMACTIVITY" MODIFY ("ACTIVITY_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMACTIVITY" MODIFY ("ACTIVITYALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMACTIVITY" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
