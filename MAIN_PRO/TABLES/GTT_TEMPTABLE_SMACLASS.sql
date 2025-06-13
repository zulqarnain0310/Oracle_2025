--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLE_SMACLASS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPTABLE_SMACLASS" 
   (	"CUSTOMERENTITYID" NUMBER(10,0), 
	"MAXSMA_CLASS" NUMBER, 
	"SMA_DT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
