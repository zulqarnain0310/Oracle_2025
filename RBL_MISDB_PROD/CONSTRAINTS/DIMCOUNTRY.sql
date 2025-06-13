--------------------------------------------------------
--  Constraints for Table DIMCOUNTRY
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMCOUNTRY" MODIFY ("COUNTRY_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMCOUNTRY" MODIFY ("COUNTRYALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMCOUNTRY" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
