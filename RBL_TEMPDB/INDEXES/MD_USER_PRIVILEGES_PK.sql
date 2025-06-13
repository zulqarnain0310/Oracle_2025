--------------------------------------------------------
--  DDL for Index MD_USER_PRIVILEGES_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_TEMPDB"."MD_USER_PRIVILEGES_PK" ON "RBL_TEMPDB"."MD_USER_PRIVILEGES" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
