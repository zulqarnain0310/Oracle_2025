--------------------------------------------------------
--  DDL for Index MD_TABLES_PERF_IDX1
--------------------------------------------------------

  CREATE INDEX "RBL_MISDB_PROD"."MD_TABLES_PERF_IDX1" ON "RBL_MISDB_PROD"."MD_TABLES" (UPPER("TABLE_NAME"), "SCHEMA_ID_FK") 
  PCTFREE 10 INITRANS 2 MAXTRANS 166 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
