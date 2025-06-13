--------------------------------------------------------
--  DDL for Table TT_TEMP1
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP1" 
   (	"TIMEKEY" VARCHAR2(20 CHAR), 
	"DATE_" DATE, 
	"RN" NUMBER
   ) ON COMMIT DELETE ROWS ;
