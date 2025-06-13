--------------------------------------------------------
--  Ref Constraints for Table MD_CONNECTIONS
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_CONNECTIONS" ADD CONSTRAINT "MD_CONNECTIONS_MD_PROJECT_FK1" FOREIGN KEY ("PROJECT_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_PROJECTS" ("ID") ON DELETE CASCADE ENABLE;
