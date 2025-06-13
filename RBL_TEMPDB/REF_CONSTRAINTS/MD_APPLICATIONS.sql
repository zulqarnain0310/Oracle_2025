--------------------------------------------------------
--  Ref Constraints for Table MD_APPLICATIONS
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_APPLICATIONS" ADD CONSTRAINT "MD_APP_PROJ_FK" FOREIGN KEY ("PROJECT_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_PROJECTS" ("ID") ON DELETE CASCADE ENABLE;
