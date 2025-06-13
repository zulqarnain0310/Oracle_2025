--------------------------------------------------------
--  Ref Constraints for Table MD_MIGR_DEPENDENCY
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_MIGR_DEPENDENCY" ADD CONSTRAINT "MIGR_DEPENDENCY_FK" FOREIGN KEY ("CONNECTION_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_CONNECTIONS" ("ID") ON DELETE CASCADE ENABLE;
