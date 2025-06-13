--------------------------------------------------------
--  DDL for Table GTT_ACCOUNTBAL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_ACCOUNTBAL" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"CUSTOMERACID" VARCHAR2(20 CHAR), 
	"BALANCE" NUMBER(16,2)
   ) ON COMMIT DELETE ROWS ;
