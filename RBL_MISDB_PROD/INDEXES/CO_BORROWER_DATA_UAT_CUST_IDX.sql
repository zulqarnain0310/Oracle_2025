--------------------------------------------------------
--  DDL for Index CO_BORROWER_DATA_UAT_CUST_IDX
--------------------------------------------------------

  CREATE INDEX "RBL_MISDB_PROD"."CO_BORROWER_DATA_UAT_CUST_IDX" ON "RBL_MISDB_PROD"."CO_BORROWER_DATA_UAT_OLD" ("CUSTID") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
