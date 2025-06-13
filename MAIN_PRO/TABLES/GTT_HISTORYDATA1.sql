--------------------------------------------------------
--  DDL for Table GTT_HISTORYDATA1
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_HISTORYDATA1" 
   (	"UCIFID" VARCHAR2(30 CHAR), 
	"STATUSDATE" VARCHAR2(200 CHAR), 
	"STATUSTYPE" VARCHAR2(30 CHAR)
   ) ON COMMIT DELETE ROWS ;
