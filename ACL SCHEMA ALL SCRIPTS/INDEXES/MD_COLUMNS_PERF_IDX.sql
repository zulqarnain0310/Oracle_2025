--------------------------------------------------------
--  DDL for Index MD_COLUMNS_PERF_IDX
--------------------------------------------------------

  CREATE INDEX "ACL_RBL_MISDB_PROD"."MD_COLUMNS_PERF_IDX" ON "ACL_RBL_MISDB_PROD"."MD_COLUMNS" ("TABLE_ID_FK", UPPER(TRIM("COLUMN_NAME")), "ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 165 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
