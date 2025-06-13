--------------------------------------------------------
--  Ref Constraints for Table MD_COLUMNS
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_COLUMNS" ADD CONSTRAINT "MD_COLUMNS_MD_TABLES_FK1" FOREIGN KEY ("TABLE_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_TABLES" ("ID") ON DELETE CASCADE ENABLE;
