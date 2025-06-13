--------------------------------------------------------
--  DDL for Index MD_TABLES_PERF_IDX2
--------------------------------------------------------

  CREATE INDEX "RBL_TEMPDB"."MD_TABLES_PERF_IDX2" ON "RBL_TEMPDB"."MD_VIEWS" (UPPER("VIEW_NAME"), "SCHEMA_ID_FK") 
  PCTFREE 10 INITRANS 2 MAXTRANS 166 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
