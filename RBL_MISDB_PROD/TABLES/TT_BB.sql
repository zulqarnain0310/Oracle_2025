--------------------------------------------------------
--  DDL for Table TT_BB
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_BB" 
   (	"PROCESS_DATE" VARCHAR2(4000 BYTE), 
	"HOST_SYSTEM" VARCHAR2(50 CHAR), 
	"COUNT" NUMBER
   ) ON COMMIT DELETE ROWS ;
