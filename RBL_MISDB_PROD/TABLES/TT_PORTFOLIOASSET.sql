--------------------------------------------------------
--  DDL for Table TT_PORTFOLIOASSET
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_PORTFOLIOASSET" 
   (	"CUSTOMERID" VARCHAR2(20 CHAR), 
	"SYSASSETCLASSALT_KEY" NUMBER(5,0)
   ) ON COMMIT DELETE ROWS ;
