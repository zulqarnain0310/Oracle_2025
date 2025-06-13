--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLEDPD
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPTABLEDPD" 
   (	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"DPD_INTSERVICE" NUMBER, 
	"DPD_NOCREDIT" NUMBER, 
	"DPD_OVERDRAWN" NUMBER, 
	"DPD_OVERDUE" NUMBER, 
	"DPD_RENEWAL" NUMBER, 
	"DPD_STOCKSTMT" NUMBER
   ) ON COMMIT DELETE ROWS ;
