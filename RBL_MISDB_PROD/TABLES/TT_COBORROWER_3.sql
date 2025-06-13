--------------------------------------------------------
--  DDL for Table TT_COBORROWER_3
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_COBORROWER_3" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"NPA_UCIC_ID" VARCHAR2(50 CHAR), 
	"COHORT_NO" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
