--------------------------------------------------------
--  DDL for Table GTT_BILL_OVERDUE_SCF
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_BILL_OVERDUE_SCF" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"BILLDUEDT" VARCHAR2(200 CHAR), 
	"INTERESTOVERDUEDATE" VARCHAR2(200 CHAR), 
	"BALANCE" NUMBER, 
	"OVERDUEINTEREST" NUMBER
   ) ON COMMIT DELETE ROWS ;
