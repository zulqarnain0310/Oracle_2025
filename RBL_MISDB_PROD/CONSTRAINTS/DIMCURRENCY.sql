--------------------------------------------------------
--  Constraints for Table DIMCURRENCY
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMCURRENCY" MODIFY ("CURRENCY_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMCURRENCY" MODIFY ("CURRENCYALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMCURRENCY" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
