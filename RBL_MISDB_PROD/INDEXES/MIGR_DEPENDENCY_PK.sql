--------------------------------------------------------
--  DDL for Index MIGR_DEPENDENCY_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_MISDB_PROD"."MIGR_DEPENDENCY_PK" ON "RBL_MISDB_PROD"."MD_MIGR_DEPENDENCY" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
