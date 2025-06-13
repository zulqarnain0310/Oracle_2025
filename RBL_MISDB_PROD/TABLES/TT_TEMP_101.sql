--------------------------------------------------------
--  DDL for Table TT_TEMP_101
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_101" 
   (	"PRODUCTCODE" VARCHAR2(20 BYTE), 
	"SOURCEALT_KEY" VARCHAR2(20 BYTE), 
	"PRODUCTDESCRIPTION" VARCHAR2(500 BYTE)
   ) ON COMMIT DELETE ROWS ;
