--------------------------------------------------------
--  DDL for Table GTT_BILL_OVERDUE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_BILL_OVERDUE" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"BILLENTITYID" NUMBER(10,0), 
	"BALANCE" NUMBER(16,2), 
	"BILLDUEDT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
