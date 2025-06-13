--------------------------------------------------------
--  DDL for Index MD_PARTITIONS_PK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_MISDB_PROD"."MD_PARTITIONS_PK" ON "RBL_MISDB_PROD"."MD_PARTITIONS" ("ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
