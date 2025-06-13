--------------------------------------------------------
--  DDL for Table TT_TEMP_110
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_110" 
   (	"CUSTOMERID" VARCHAR2(30 BYTE), 
	"VALUEALT_KEY" VARCHAR2(100 BYTE), 
	"CUSTOMERNAME" VARCHAR2(200 BYTE)
   ) ON COMMIT DELETE ROWS ;
