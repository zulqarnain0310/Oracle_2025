--------------------------------------------------------
--  DDL for Table TT_TEMP2_32
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP2_32" 
   (	"SOURCEALT_KEY" NUMBER(10,0), 
	"SOURCENAME" VARCHAR2(100 BYTE), 
	"CNT" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
