--------------------------------------------------------
--  DDL for Index MD_STATE_TYPE__ID
--------------------------------------------------------

  CREATE INDEX "RBL_TEMPDB"."MD_STATE_TYPE__ID" ON "RBL_TEMPDB"."MD_APPLICATIONFILES" ("STATE", "TYPE", "ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
