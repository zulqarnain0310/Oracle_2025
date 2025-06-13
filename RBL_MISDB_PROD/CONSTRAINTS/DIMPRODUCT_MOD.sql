--------------------------------------------------------
--  Constraints for Table DIMPRODUCT_MOD
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMPRODUCT_MOD" MODIFY ("PRODUCT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMPRODUCT_MOD" MODIFY ("PRODUCTALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMPRODUCT_MOD" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
