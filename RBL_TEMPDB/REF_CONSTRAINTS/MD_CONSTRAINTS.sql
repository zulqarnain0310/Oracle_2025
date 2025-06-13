--------------------------------------------------------
--  Ref Constraints for Table MD_CONSTRAINTS
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_CONSTRAINTS" ADD CONSTRAINT "MD_CONSTRAINTS_MD_TABLES_FK1" FOREIGN KEY ("TABLE_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_TABLES" ("ID") ON DELETE CASCADE ENABLE;
