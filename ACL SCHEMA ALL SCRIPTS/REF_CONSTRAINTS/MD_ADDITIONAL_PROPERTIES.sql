--------------------------------------------------------
--  Ref Constraints for Table MD_ADDITIONAL_PROPERTIES
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_ADDITIONAL_PROPERTIES" ADD CONSTRAINT "MD_ADDITIONAL_PROPERTIES__FK1" FOREIGN KEY ("CONNECTION_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_CONNECTIONS" ("ID") ON DELETE CASCADE ENABLE;
