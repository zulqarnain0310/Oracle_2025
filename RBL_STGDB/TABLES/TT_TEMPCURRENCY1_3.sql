--------------------------------------------------------
--  DDL for Table TT_TEMPCURRENCY1_3
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_STGDB"."TT_TEMPCURRENCY1_3" 
   (	"DATE_" VARCHAR2(200 CHAR), 
	"CURRENCY" VARCHAR2(5 CHAR), 
	"RATE" NUMBER(8,4)
   ) ON COMMIT DELETE ROWS ;
