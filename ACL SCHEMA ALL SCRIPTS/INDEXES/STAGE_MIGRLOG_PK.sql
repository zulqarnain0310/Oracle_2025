--------------------------------------------------------
--  DDL for Index STAGE_MIGRLOG_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "ACL_RBL_MISDB_PROD"."STAGE_MIGRLOG_PK" ON "ACL_RBL_MISDB_PROD"."STAGE_MIGRLOG" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
