--------------------------------------------------------
--  DDL for Table GTT_TEMPCURRENCY
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_STGDB"."GTT_TEMPCURRENCY" 
   (	"CURRENCY" VARCHAR2(5 CHAR), 
	"DATE_" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
