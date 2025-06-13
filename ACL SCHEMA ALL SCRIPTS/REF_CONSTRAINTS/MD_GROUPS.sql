--------------------------------------------------------
--  Ref Constraints for Table MD_GROUPS
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_GROUPS" ADD CONSTRAINT "MD_GROUPS_MD_SCHEMAS_FK1" FOREIGN KEY ("SCHEMA_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_SCHEMAS" ("ID") ON DELETE CASCADE ENABLE;
