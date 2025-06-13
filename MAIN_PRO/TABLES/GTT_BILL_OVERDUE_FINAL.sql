--------------------------------------------------------
--  DDL for Table GTT_BILL_OVERDUE_FINAL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_BILL_OVERDUE_FINAL" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"BILOVERDUE" NUMBER, 
	"BILLOVERDUEDT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
