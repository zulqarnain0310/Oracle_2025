--------------------------------------------------------
--  DDL for Index MD_TABLESPACES_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_MISDB_PROD"."MD_TABLESPACES_PK" ON "RBL_MISDB_PROD"."MD_TABLESPACES" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
