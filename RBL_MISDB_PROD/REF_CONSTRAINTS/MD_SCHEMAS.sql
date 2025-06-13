--------------------------------------------------------
--  Ref Constraints for Table MD_SCHEMAS
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."MD_SCHEMAS" ADD CONSTRAINT "MD_SCHEMAS_MD_CATALOGS_FK1" FOREIGN KEY ("CATALOG_ID_FK")
	  REFERENCES "RBL_MISDB_PROD"."MD_CATALOGS" ("ID") ON DELETE CASCADE ENABLE;
