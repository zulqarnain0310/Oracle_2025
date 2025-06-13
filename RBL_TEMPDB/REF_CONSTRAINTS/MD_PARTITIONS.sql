--------------------------------------------------------
--  Ref Constraints for Table MD_PARTITIONS
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MD_PARTITIONS" ADD CONSTRAINT "MD_PARTITIONS_MD_TABLES_FK1" FOREIGN KEY ("TABLE_ID_FK")
	  REFERENCES "RBL_TEMPDB"."MD_TABLES" ("ID") ON DELETE CASCADE ENABLE;
