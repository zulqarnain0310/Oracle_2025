--------------------------------------------------------
--  DDL for Table GTT_PNPA_REASON_DATE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_PNPA_REASON_DATE" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"PNPA_DATE" VARCHAR2(200 CHAR), 
	"PNPA_REASON" VARCHAR2(150 BYTE)
   ) ON COMMIT DELETE ROWS ;
