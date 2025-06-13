--------------------------------------------------------
--  Ref Constraints for Table MD_DERIVATIVES
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_DERIVATIVES" ADD CONSTRAINT "MD_DERIVATIVES_MD_CONNECT_FK1" FOREIGN KEY ("DERIVED_CONNECTION_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_CONNECTIONS" ("ID") ON DELETE CASCADE ENABLE;
