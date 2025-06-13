--------------------------------------------------------
--  DDL for Table TT_TEMPTABLEDPD_2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_TEMPTABLEDPD_2" 
   (	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"DPD_INTSERVICE" NUMBER, 
	"DPD_NOCREDIT" NUMBER, 
	"DPD_OVERDRAWN" NUMBER, 
	"DPD_OVERDUE" NUMBER, 
	"DPD_RENEWAL" NUMBER, 
	"DPD_STOCKSTMT" NUMBER
   ) ON COMMIT DELETE ROWS ;
