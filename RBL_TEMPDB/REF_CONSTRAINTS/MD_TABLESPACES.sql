--------------------------------------------------------
--  Ref Constraints for Table MD_TABLESPACES
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_TABLESPACES" ADD CONSTRAINT "MD_TABLESPACES_MD_SCHEMAS_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
