--------------------------------------------------------
--  Ref Constraints for Table MD_SEQUENCES
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_SEQUENCES" ADD CONSTRAINT "MD_SEQUENCES_MD_SCHEMAS_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
