--------------------------------------------------------
--  DDL for Index MD_STATE_TYPE__ID
--------------------------------------------------------

  CREATE INDEX "RBL_MISDB_PROD"."MD_STATE_TYPE__ID" ON "RBL_MISDB_PROD"."MD_APPLICATIONFILES" ("STATE", "TYPE", "ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
