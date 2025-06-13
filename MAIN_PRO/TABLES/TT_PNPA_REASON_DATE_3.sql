--------------------------------------------------------
--  DDL for Table TT_PNPA_REASON_DATE_3
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_PNPA_REASON_DATE_3" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"PNPA_DATE" VARCHAR2(200 BYTE), 
	"PNPA_REASON" VARCHAR2(500 BYTE)
   ) ON COMMIT DELETE ROWS ;
