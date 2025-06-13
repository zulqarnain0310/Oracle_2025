--------------------------------------------------------
--  DDL for Table GTT_PC_OVERDUE_FINAL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_PC_OVERDUE_FINAL" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"PCOVERDUE" NUMBER, 
	"PCOVERDUEDUEDT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
