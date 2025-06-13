--------------------------------------------------------
--  DDL for Index MD_USER_PRIVILEGES_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "ACL_RBL_MISDB_PROD"."MD_USER_PRIVILEGES_PK" ON "ACL_RBL_MISDB_PROD"."MD_USER_PRIVILEGES" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
