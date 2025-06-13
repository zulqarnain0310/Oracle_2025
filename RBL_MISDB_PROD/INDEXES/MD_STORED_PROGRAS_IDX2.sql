--------------------------------------------------------
--  DDL for Index MD_STORED_PROGRAS_IDX2
--------------------------------------------------------

  CREATE INDEX "RBL_MISDB_PROD"."MD_STORED_PROGRAS_IDX2" ON "RBL_MISDB_PROD"."MD_STORED_PROGRAMS" ("SCHEMA_ID_FK", UPPER("NAME")) 
  PCTFREE 10 INITRANS 2 MAXTRANS 166 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
