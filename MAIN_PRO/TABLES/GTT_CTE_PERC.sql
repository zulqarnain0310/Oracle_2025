--------------------------------------------------------
--  DDL for Table GTT_CTE_PERC
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_CTE_PERC" 
   (	"UCIF_ID" VARCHAR2(50 CHAR), 
	"SYSASSETCLASSALT_KEY" NUMBER, 
	"SYSNPA_DT" VARCHAR2(200 CHAR), 
	"PERCTYPE" CHAR(3 BYTE)
   ) ON COMMIT DELETE ROWS ;
