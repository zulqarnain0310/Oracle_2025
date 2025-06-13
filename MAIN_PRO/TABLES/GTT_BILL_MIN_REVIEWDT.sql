--------------------------------------------------------
--  DDL for Table GTT_BILL_MIN_REVIEWDT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_BILL_MIN_REVIEWDT" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"REVIEWDUEDATE" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
