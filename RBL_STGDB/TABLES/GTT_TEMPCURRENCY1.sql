--------------------------------------------------------
--  DDL for Table GTT_TEMPCURRENCY1
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_STGDB"."GTT_TEMPCURRENCY1" 
   (	"DATE_" VARCHAR2(200 CHAR), 
	"CURRENCY" VARCHAR2(5 CHAR), 
	"RATE" NUMBER(8,4)
   ) ON COMMIT DELETE ROWS ;
