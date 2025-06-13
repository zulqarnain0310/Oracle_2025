--------------------------------------------------------
--  DDL for Table TT_TEMP_32
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_32" 
   (	"SECURITYALT_KEY" NUMBER(10,0), 
	"SOURCEALT_KEY" VARCHAR2(20 BYTE), 
	"SECURITYNAME" VARCHAR2(100 BYTE)
   ) ON COMMIT DELETE ROWS ;
