--------------------------------------------------------
--  DDL for Table TT_TEMP_103
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_103" 
   (	"PRODUCTCODE" VARCHAR2(20 BYTE), 
	"SOURCEALT_KEY" VARCHAR2(20 BYTE), 
	"PRODUCTDESCRIPTION" VARCHAR2(500 BYTE)
   ) ON COMMIT DELETE ROWS ;
