--------------------------------------------------------
--  DDL for Index MD_DERIVATIVES_PERF_IDX1
--------------------------------------------------------

  CREATE INDEX "ACL_RBL_MISDB_PROD"."MD_DERIVATIVES_PERF_IDX1" ON "ACL_RBL_MISDB_PROD"."MD_DERIVATIVES" ("SRC_TYPE", "DERIVATIVE_REASON") 
  PCTFREE 10 INITRANS 2 MAXTRANS 167 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
