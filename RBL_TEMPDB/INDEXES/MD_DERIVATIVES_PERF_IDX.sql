--------------------------------------------------------
--  DDL for Index MD_DERIVATIVES_PERF_IDX
--------------------------------------------------------

  CREATE INDEX "RBL_TEMPDB"."MD_DERIVATIVES_PERF_IDX" ON "RBL_TEMPDB"."MD_DERIVATIVES" ("SRC_ID", "DERIVED_CONNECTION_ID_FK") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
