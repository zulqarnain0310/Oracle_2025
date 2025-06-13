--------------------------------------------------------
--  Ref Constraints for Table MD_INDEXES
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."MD_INDEXES" ADD CONSTRAINT "MD_INDEXES_MD_TABLES_FK1" FOREIGN KEY ("TABLE_ID_FK")
	  REFERENCES "RBL_MISDB_PROD"."MD_TABLES" ("ID") ON DELETE CASCADE ENABLE;
