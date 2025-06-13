--------------------------------------------------------
--  DDL for Table TT_CCOD_ACCOUNT_SMA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_CCOD_ACCOUNT_SMA" 
   (	"CUSTOMERACID" VARCHAR2(50 CHAR), 
	"MOVEMENTFROMDATE_ACCSMA" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
