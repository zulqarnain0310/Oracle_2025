--------------------------------------------------------
--  DDL for Index MIGRLOG_PERF_IDX
--------------------------------------------------------

  CREATE INDEX "RBL_TEMPDB"."MIGRLOG_PERF_IDX" ON "RBL_TEMPDB"."MIGRLOG" ("REF_OBJECT_ID", "SEVERITY") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
