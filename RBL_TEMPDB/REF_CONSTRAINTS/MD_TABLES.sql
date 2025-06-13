--------------------------------------------------------
--  Ref Constraints for Table MD_TABLES
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_TABLES" ADD CONSTRAINT "MD_TABLES_MD_SCHEMAS_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
