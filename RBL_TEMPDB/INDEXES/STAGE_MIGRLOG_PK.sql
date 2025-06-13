--------------------------------------------------------
--  DDL for Index STAGE_MIGRLOG_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_TEMPDB"."STAGE_MIGRLOG_PK" ON "RBL_TEMPDB"."STAGE_MIGRLOG" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
