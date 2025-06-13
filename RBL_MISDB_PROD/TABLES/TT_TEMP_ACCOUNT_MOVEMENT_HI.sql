--------------------------------------------------------
--  DDL for Table TT_TEMP_ACCOUNT_MOVEMENT_HI
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP_ACCOUNT_MOVEMENT_HI" 
   (	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"MOVEMENTFROMDATE1" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
