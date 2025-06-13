--------------------------------------------------------
--  Ref Constraints for Table MD_APPLICATIONFILES
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_APPLICATIONFILES" ADD CONSTRAINT "MD_FILE_APP_FK" FOREIGN KEY ("APPLICATIONS_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_APPLICATIONS" ("ID") ON DELETE CASCADE ENABLE;
