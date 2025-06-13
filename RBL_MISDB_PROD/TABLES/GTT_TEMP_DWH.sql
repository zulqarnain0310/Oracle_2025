--------------------------------------------------------
--  DDL for Table GTT_TEMP_DWH
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_TEMP_DWH" 
   (	"DWHSOURCESYSTEMS" CHAR(21 BYTE), 
	"DATE_OF_DATA" VARCHAR2(10 CHAR)
   ) ON COMMIT DELETE ROWS ;
