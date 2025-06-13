--------------------------------------------------------
--  DDL for Table TT_DATA_3
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_DATA_3" 
   (	"PROCESSNAME" VARCHAR2(400 BYTE), 
	"EXECUTIONSTARTTIME" DATE, 
	"EXECUTIONENDTIME" DATE, 
	"TIMEDURATION_SEC" NUMBER(10,0), 
	"EXECUTIONSTATUS" VARCHAR2(15 CHAR)
   ) ON COMMIT DELETE ROWS ;
