--------------------------------------------------------
--  DDL for Table TT_ACCOUNTCOUNT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_ACCOUNTCOUNT" 
   (	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"ACCOUNTENTITYID" NUMBER(10,0), 
	"CNT" NUMBER
   ) ON COMMIT DELETE ROWS ;
