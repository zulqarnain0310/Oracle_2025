--------------------------------------------------------
--  DDL for Table GTT_CTE_B
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ETL_TEMP_RBL_TEMPDB"."GTT_CTE_B" 
   (	"CUSTOMER_ID" VARCHAR2(20 CHAR), 
	"COLLATERALID" VARCHAR2(30 CHAR), 
	"SECVALUE_FINAL" NUMBER
   ) ON COMMIT DELETE ROWS ;
