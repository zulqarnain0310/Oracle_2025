--------------------------------------------------------
--  DDL for Table GTT_COBORROWER
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_COBORROWER" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"NPA_UCIC_ID" VARCHAR2(50 CHAR), 
	"COHORT_NO" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
