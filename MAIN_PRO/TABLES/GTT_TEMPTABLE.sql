--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPTABLE" 
   (	"UCIF_ID" VARCHAR2(50 CHAR), 
	"TOTALCOUNT" NUMBER
   ) ON COMMIT DELETE ROWS ;
