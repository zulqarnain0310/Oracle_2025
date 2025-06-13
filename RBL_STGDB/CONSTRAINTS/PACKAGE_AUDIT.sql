--------------------------------------------------------
--  Constraints for Table PACKAGE_AUDIT
--------------------------------------------------------

  ALTER TABLE "RBL_STGDB"."PACKAGE_AUDIT" MODIFY ("PACKAGENAME" NOT NULL ENABLE);
  ALTER TABLE "RBL_STGDB"."PACKAGE_AUDIT" MODIFY ("TABLENAME" NOT NULL ENABLE);
  ALTER TABLE "RBL_STGDB"."PACKAGE_AUDIT" MODIFY ("EXECUTIONSTATUS" NOT NULL ENABLE);
