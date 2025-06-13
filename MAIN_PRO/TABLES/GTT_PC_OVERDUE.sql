--------------------------------------------------------
--  DDL for Table GTT_PC_OVERDUE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_PC_OVERDUE" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"PCREFNO" VARCHAR2(20 CHAR), 
	"BALANCE" NUMBER(16,2), 
	"PCOVERDUEDUEDT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
