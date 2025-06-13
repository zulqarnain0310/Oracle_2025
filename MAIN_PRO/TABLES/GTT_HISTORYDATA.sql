--------------------------------------------------------
--  DDL for Table GTT_HISTORYDATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_HISTORYDATA" 
   (	"ACID" VARCHAR2(20 CHAR), 
	"STATUSTYPE" VARCHAR2(30 CHAR), 
	"STATUSDATE" VARCHAR2(200 CHAR), 
	"EFFECTIVEFROMTIMEKEY" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
