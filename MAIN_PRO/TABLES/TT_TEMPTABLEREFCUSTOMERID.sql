--------------------------------------------------------
--  DDL for Table TT_TEMPTABLEREFCUSTOMERID
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_TEMPTABLEREFCUSTOMERID" 
   (	"REFCUSTOMERID" VARCHAR2(50 CHAR), 
	"TOTALCOUNT" NUMBER
   ) ON COMMIT DELETE ROWS ;
