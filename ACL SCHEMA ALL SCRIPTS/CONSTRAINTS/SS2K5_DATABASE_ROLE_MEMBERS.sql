--------------------------------------------------------
--  Constraints for Table SS2K5_DATABASE_ROLE_MEMBERS
--------------------------------------------------------

  ALTER TABLE "ACL_RBL_MISDB_PROD"."SS2K5_DATABASE_ROLE_MEMBERS" MODIFY ("MEMBER_PRINCIPAL_ID" NOT NULL ENABLE);
  ALTER TABLE "ACL_RBL_MISDB_PROD"."SS2K5_DATABASE_ROLE_MEMBERS" MODIFY ("ROLE_PRINCIPAL_ID" NOT NULL ENABLE);
