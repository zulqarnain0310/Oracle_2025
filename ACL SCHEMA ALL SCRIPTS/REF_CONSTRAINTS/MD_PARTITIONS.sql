--------------------------------------------------------
--  Ref Constraints for Table MD_PARTITIONS
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MD_PARTITIONS" ADD CONSTRAINT "MD_PARTITIONS_MD_TABLES_FK1" FOREIGN KEY ("TABLE_ID_FK")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MD_TABLES" ("ID") ON DELETE CASCADE ENABLE;
