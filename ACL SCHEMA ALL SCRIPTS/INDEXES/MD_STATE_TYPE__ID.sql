--------------------------------------------------------
--  DDL for Index MD_STATE_TYPE__ID
--------------------------------------------------------

  CREATE INDEX "ACL_RBL_MISDB_PROD"."MD_STATE_TYPE__ID" ON "ACL_RBL_MISDB_PROD"."MD_APPLICATIONFILES" ("STATE", "TYPE", "ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
