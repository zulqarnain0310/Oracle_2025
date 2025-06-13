--------------------------------------------------------
--  Ref Constraints for Table MD_COLUMNS
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_COLUMNS" ADD CONSTRAINT "MD_COLUMNS_MD_TABLES_FK1" FOREIGN KEY ("TABLE_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_TABLES" ("ID") ON DELETE CASCADE ENABLE;
