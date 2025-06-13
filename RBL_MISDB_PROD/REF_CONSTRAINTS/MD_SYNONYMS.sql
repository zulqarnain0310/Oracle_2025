--------------------------------------------------------
--  Ref Constraints for Table MD_SYNONYMS
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."MD_SYNONYMS" ADD CONSTRAINT "MD_SYNONYMS_MD_SCHEMAS_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "RBL_MISDB_PROD"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
