--------------------------------------------------------
--  DDL for Index MIGRLOG_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_TEMPDB"."MIGRLOG_PK" ON "RBL_TEMPDB"."MIGRLOG" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
