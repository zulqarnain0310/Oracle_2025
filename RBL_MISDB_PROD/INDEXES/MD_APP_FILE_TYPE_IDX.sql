--------------------------------------------------------
--  DDL for Index MD_APP_FILE_TYPE_IDX
--------------------------------------------------------

  CREATE INDEX "RBL_MISDB_PROD"."MD_APP_FILE_TYPE_IDX" ON "RBL_MISDB_PROD"."MD_APPLICATIONFILES" ("TYPE", "ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
