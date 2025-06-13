--------------------------------------------------------
--  DDL for Index MD_TABLES_PERF_IDX2
--------------------------------------------------------

  CREATE INDEX "ACL_RBL_MISDB_PROD"."MD_TABLES_PERF_IDX2" ON "ACL_RBL_MISDB_PROD"."MD_VIEWS" (UPPER("VIEW_NAME"), "SCHEMA_ID_FK") 
  PCTFREE 10 INITRANS 2 MAXTRANS 166 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
