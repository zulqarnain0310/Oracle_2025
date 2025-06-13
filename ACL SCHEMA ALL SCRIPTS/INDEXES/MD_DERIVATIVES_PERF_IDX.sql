--------------------------------------------------------
--  DDL for Index MD_DERIVATIVES_PERF_IDX
--------------------------------------------------------

  CREATE INDEX "ACL_RBL_MISDB_PROD"."MD_DERIVATIVES_PERF_IDX" ON "ACL_RBL_MISDB_PROD"."MD_DERIVATIVES" ("SRC_ID", "DERIVED_CONNECTION_ID_FK") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
