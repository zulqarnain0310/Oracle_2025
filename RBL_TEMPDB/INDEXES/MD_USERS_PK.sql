--------------------------------------------------------
--  DDL for Index MD_USERS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_TEMPDB"."MD_USERS_PK" ON "RBL_TEMPDB"."MD_USERS" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
