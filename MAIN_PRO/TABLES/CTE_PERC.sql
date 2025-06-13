--------------------------------------------------------
--  DDL for Table CTE_PERC
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."CTE_PERC" 
   (	"UCIF_ID" VARCHAR2(50 CHAR), 
	"SYSASSETCLASSALT_KEY" NUMBER, 
	"SYSNPA_DT" VARCHAR2(200 CHAR), 
	"PERCTYPE" VARCHAR2(10 BYTE)
   ) ON COMMIT DELETE ROWS ;
