--------------------------------------------------------
--  Ref Constraints for Table MIGRLOG
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."MIGRLOG" ADD CONSTRAINT "MIGR_MIGRLOG_FK" FOREIGN KEY ("PARENT_LOG_ID")
	  REFERENCES "ACL_RBL_MISDB_PROD"."MIGRLOG" ("ID") ENABLE;
