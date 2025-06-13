--------------------------------------------------------
--  DDL for Table TT_TEMP_63
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_63" 
   (	"INDUSTRYALT_KEY" NUMBER(10,0), 
	"SOURCEALT_KEY" VARCHAR2(20 BYTE), 
	"INDUSTRYNAME" VARCHAR2(100 BYTE)
   ) ON COMMIT DELETE ROWS ;
