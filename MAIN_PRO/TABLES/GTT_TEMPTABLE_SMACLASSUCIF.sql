--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLE_SMACLASSUCIF
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPTABLE_SMACLASSUCIF" 
   (	"UCIF_ID" VARCHAR2(50 CHAR), 
	"MAXSMA_CLASS" NUMBER, 
	"SMA_DT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
