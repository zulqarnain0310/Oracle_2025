--------------------------------------------------------
--  DDL for Table TT_TEMP_92
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_92" 
   (	"PRODUCTCODE" VARCHAR2(30 BYTE), 
	"SOURCEALT_KEY" VARCHAR2(20 BYTE), 
	"PRODUCTNAME" VARCHAR2(200 BYTE)
   ) ON COMMIT DELETE ROWS ;
