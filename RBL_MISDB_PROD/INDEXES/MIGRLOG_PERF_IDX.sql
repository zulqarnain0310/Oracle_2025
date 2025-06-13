--------------------------------------------------------
--  DDL for Index MIGRLOG_PERF_IDX
--------------------------------------------------------

  CREATE INDEX "RBL_MISDB_PROD"."MIGRLOG_PERF_IDX" ON "RBL_MISDB_PROD"."MIGRLOG" ("REF_OBJECT_ID", "SEVERITY") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
