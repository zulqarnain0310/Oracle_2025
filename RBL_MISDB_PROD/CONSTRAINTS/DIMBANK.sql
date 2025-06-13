--------------------------------------------------------
--  Constraints for Table DIMBANK
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMBANK" MODIFY ("BANK_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMBANK" MODIFY ("BANKALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMBANK" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
