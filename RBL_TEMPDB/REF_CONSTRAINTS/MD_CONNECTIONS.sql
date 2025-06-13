--------------------------------------------------------
--  Ref Constraints for Table MD_CONNECTIONS
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_CONNECTIONS" ADD CONSTRAINT "MD_CONNECTIONS_MD_PROJECT_FK1" FOREIGN KEY ("PROJECT_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_PROJECTS" ("ID") ON DELETE CASCADE ENABLE;
