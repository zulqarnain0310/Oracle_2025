--------------------------------------------------------
--  DDL for Index MIGR_WEAKDEP_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_TEMPDB"."MIGR_WEAKDEP_PK" ON "RBL_TEMPDB"."MD_MIGR_WEAKDEP" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
