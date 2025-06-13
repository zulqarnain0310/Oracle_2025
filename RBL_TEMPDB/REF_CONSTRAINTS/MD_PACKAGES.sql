--------------------------------------------------------
--  Ref Constraints for Table MD_PACKAGES
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_PACKAGES" ADD CONSTRAINT "MD_PACKAGES_MD_SCHEMAS_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
