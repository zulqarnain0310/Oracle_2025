--------------------------------------------------------
--  DDL for Table GTT_CTE_A
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ETL_TEMP_RBL_TEMPDB"."GTT_CTE_A" 
   (	"CUSTOMER_ID" VARCHAR2(20 CHAR), 
	"SECVALUE_FINAL" NUMBER(16,2), 
	"COLLATERALID" VARCHAR2(30 CHAR), 
	"SECURITYVALUE" NUMBER(16,2), 
	"RID" NUMBER
   ) ON COMMIT DELETE ROWS ;
