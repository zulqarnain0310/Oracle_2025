--------------------------------------------------------
--  DDL for Table TT_LENDERCUSTOMER
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_LENDERCUSTOMER" 
   (	"CUSTOMERID" VARCHAR2(20 CHAR), 
	"DEFAULTDATE" DATE
   ) ON COMMIT DELETE ROWS ;
