--------------------------------------------------------
--  DDL for Table GTT_CCOD_90DAYS_INTT_CR_AMT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_CCOD_90DAYS_INTT_CR_AMT" 
   (	"CUSTOMERACID" VARCHAR2(20 CHAR), 
	"INTERESTAMT" NUMBER, 
	"CREDITAMT" NUMBER
   ) ON COMMIT DELETE ROWS ;
