--------------------------------------------------------
--  Ref Constraints for Table MIGR_GENERATION_ORDER
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MIGR_GENERATION_ORDER" ADD CONSTRAINT "MIGR_GENERATION_ORDER_MD__FK1" FOREIGN KEY ("CONNECTION_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_CONNECTIONS" ("ID") ON DELETE CASCADE ENABLE;
