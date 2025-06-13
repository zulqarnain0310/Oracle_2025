--------------------------------------------------------
--  Constraints for Table DIMZONE
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMZONE" MODIFY ("ZONE_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMZONE" MODIFY ("ZONEALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMZONE" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
