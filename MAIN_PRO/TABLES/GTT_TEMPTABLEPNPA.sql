--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLEPNPA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPTABLEPNPA" 
   (	"CUSTOMERENTITYID" NUMBER(10,0), 
	"PNPA_DATE" VARCHAR2(200 CHAR), 
	"PNPA_CLASS_KEY" NUMBER
   ) ON COMMIT DELETE ROWS ;
