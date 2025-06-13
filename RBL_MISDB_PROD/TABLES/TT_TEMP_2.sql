--------------------------------------------------------
--  DDL for Table TT_TEMP_2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_2" 
   (	"ACBUSEGMENTCODE" VARCHAR2(20 BYTE), 
	"SOURCEALT_KEY" VARCHAR2(30 BYTE), 
	"ACBUSEGMENTDESCRIPTION" VARCHAR2(100 BYTE)
   ) ON COMMIT DELETE ROWS ;
