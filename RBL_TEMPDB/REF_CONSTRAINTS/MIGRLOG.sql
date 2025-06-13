--------------------------------------------------------
--  Ref Constraints for Table MIGRLOG
--------------------------------------------------------

  ALTER TABLE "RBL_TEMPDB"."MIGRLOG" ADD CONSTRAINT "MIGR_MIGRLOG_FK" FOREIGN KEY ("PARENT_LOG_ID")
	  REFERENCES "RBL_TEMPDB"."MIGRLOG" ("ID") ENABLE;
