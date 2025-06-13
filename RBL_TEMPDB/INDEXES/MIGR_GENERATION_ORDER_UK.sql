--------------------------------------------------------
--  DDL for Index MIGR_GENERATION_ORDER_UK
--------------------------------------------------------

  CREATE UNIQUE INDEX "RBL_TEMPDB"."MIGR_GENERATION_ORDER_UK" ON "RBL_TEMPDB"."MIGR_GENERATION_ORDER" ("OBJECT_ID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
