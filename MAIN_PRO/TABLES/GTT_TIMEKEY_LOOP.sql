--------------------------------------------------------
--  DDL for Table GTT_TIMEKEY_LOOP
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TIMEKEY_LOOP" 
   (	"TIMEKEY" NUMBER(10,0), 
	"DATE_" TIMESTAMP (6), 
	"ROWID_" NUMBER
   ) ON COMMIT DELETE ROWS ;
