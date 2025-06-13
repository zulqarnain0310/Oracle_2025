--------------------------------------------------------
--  Constraints for Table PACKAGE_AUDIT_MOD
--------------------------------------------------------

  ALTER TABLE "RBL_STGDB"."PACKAGE_AUDIT_MOD" MODIFY ("PACKAGENAME" NOT NULL ENABLE);
  ALTER TABLE "RBL_STGDB"."PACKAGE_AUDIT_MOD" MODIFY ("TABLENAME" NOT NULL ENABLE);
  ALTER TABLE "RBL_STGDB"."PACKAGE_AUDIT_MOD" MODIFY ("EXECUTIONSTATUS" NOT NULL ENABLE);
