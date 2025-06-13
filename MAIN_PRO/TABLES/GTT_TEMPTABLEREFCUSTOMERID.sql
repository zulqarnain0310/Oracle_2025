--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLEREFCUSTOMERID
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPTABLEREFCUSTOMERID" 
   (	"REFCUSTOMERID" VARCHAR2(50 CHAR), 
	"TOTALCOUNT" NUMBER
   ) ON COMMIT DELETE ROWS ;
