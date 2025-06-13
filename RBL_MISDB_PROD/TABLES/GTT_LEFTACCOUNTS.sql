--------------------------------------------------------
--  DDL for Table GTT_LEFTACCOUNTS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_LEFTACCOUNTS" 
   (	"UCIF_ID" VARCHAR2(50 CHAR), 
	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"REFCUSTOMERID" VARCHAR2(50 CHAR), 
	"COHORT_NO" NUMBER(10,0), 
	"TIMEKEY" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
