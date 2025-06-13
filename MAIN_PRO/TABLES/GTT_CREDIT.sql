--------------------------------------------------------
--  DDL for Table GTT_CREDIT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_CREDIT" 
   (	"CUSTOMERACID" VARCHAR2(20 CHAR), 
	"ACCOUNTENTITYID" NUMBER(10,0), 
	"TXNDATE" VARCHAR2(200 CHAR), 
	"TXNAMOUNT" NUMBER
   ) ON COMMIT DELETE ROWS ;
