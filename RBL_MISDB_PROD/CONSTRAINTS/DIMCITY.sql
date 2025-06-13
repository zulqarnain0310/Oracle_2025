--------------------------------------------------------
--  Constraints for Table DIMCITY
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMCITY" MODIFY ("CITY_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMCITY" MODIFY ("CITYALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMCITY" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
