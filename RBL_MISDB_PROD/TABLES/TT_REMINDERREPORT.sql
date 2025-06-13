--------------------------------------------------------
--  DDL for Table TT_REMINDERREPORT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_REMINDERREPORT" 
   (	"ACCOUNTID" VARCHAR2(30 BYTE), 
	"FLAGALT_KEY" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
