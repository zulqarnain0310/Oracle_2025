--------------------------------------------------------
--  DDL for Table GTT_TEMP_DWH2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_TEMP_DWH2" 
   (	"RN_COUNT" NUMBER, 
	"DWHSOURCESYSTEMS" CHAR(21 BYTE), 
	"DATE_OF_DATA" VARCHAR2(4000 BYTE)
   ) ON COMMIT DELETE ROWS ;
