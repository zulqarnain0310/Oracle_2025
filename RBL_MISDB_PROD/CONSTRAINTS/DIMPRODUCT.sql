--------------------------------------------------------
--  Constraints for Table DIMPRODUCT
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."DIMPRODUCT" MODIFY ("PRODUCTALT_KEY" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMPRODUCT" MODIFY ("D2KTIMESTAMP" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."DIMPRODUCT" MODIFY ("PRODUCT_KEY" NOT NULL ENABLE);
