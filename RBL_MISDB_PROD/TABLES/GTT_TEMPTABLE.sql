--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_TEMPTABLE" 
   (	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"DPD_INTSERVICE" NUMBER, 
	"DPD_NOCREDIT" NUMBER, 
	"DPD_OVERDRAWN" NUMBER, 
	"DPD_OVERDUE" NUMBER, 
	"DPD_RENEWAL" NUMBER, 
	"DPD_STOCKSTMT" NUMBER
   ) ON COMMIT DELETE ROWS ;
