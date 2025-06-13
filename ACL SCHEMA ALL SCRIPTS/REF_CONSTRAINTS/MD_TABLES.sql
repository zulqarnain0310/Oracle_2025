--------------------------------------------------------
--  Ref Constraints for Table MD_TABLES
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_TABLES" ADD CONSTRAINT "MD_TABLES_MD_SCHEMAS_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
