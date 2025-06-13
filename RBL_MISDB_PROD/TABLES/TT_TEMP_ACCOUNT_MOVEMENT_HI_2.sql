--------------------------------------------------------
--  DDL for Table TT_TEMP_ACCOUNT_MOVEMENT_HI_2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_ACCOUNT_MOVEMENT_HI_2" 
   (	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"MOVEMENTFROMDATE" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
