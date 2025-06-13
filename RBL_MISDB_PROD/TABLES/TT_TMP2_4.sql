--------------------------------------------------------
--  DDL for Table TT_TMP2_4
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TMP2_4" 
   (	"TYPE1" VARCHAR2(50 BYTE), 
	"DETAILS" VARCHAR2(1000 BYTE), 
	"TABLENAME" VARCHAR2(20 BYTE)
   ) ON COMMIT DELETE ROWS ;
