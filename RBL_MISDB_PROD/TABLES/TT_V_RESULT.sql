--------------------------------------------------------
--  DDL for Table TT_V_RESULT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_V_RESULT" 
   (	"MONTHLASTDATE" VARCHAR2(10 BYTE), 
	"MONTHFIRSTDATE" VARCHAR2(10 BYTE)
   ) ON COMMIT DELETE ROWS ;
