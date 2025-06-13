--------------------------------------------------------
--  DDL for Table TT_PORTFOLIO
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_PORTFOLIO" 
   (	"CUSTOMERID" VARCHAR2(20 CHAR), 
	"BALANCE" NUMBER
   ) ON COMMIT DELETE ROWS ;
