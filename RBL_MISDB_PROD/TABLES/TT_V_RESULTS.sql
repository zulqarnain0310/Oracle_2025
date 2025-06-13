--------------------------------------------------------
--  DDL for Table TT_V_RESULTS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_V_RESULTS" 
   (	"SNO" NUMBER(10,0), 
	"ITEMS" NVARCHAR2(2000)
   ) ON COMMIT DELETE ROWS ;
