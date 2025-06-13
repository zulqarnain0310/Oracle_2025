--------------------------------------------------------
--  Constraints for Table DIMRELIGION
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMRELIGION" MODIFY ("RELIGION_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMRELIGION" MODIFY ("RELIGIONNAME" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMRELIGION" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
