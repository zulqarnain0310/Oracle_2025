--------------------------------------------------------
--  DDL for Index MIGR_WEAKDEP_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "ACL_RBL_MISDB_PROD"."MIGR_WEAKDEP_PK" ON "ACL_RBL_MISDB_PROD"."MD_MIGR_WEAKDEP" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
