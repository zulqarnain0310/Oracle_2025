--------------------------------------------------------
--  DDL for Table GTT_HISTORYDATA2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_HISTORYDATA2" 
   (	"UCIFID" VARCHAR2(30 CHAR), 
	"ACID" VARCHAR2(20 CHAR), 
	"STATUSTYPE" VARCHAR2(30 CHAR)
   ) ON COMMIT DELETE ROWS ;
