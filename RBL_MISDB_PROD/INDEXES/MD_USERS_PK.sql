--------------------------------------------------------
--  DDL for Index MD_USERS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_MISDB_PROD"."MD_USERS_PK" ON "RBL_MISDB_PROD"."MD_USERS" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
