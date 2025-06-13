--------------------------------------------------------
--  DDL for Table TT_CCOD_INDEFAULT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_CCOD_INDEFAULT" 
   (	"CUSTOMERACID" VARCHAR2(50 CHAR), 
	"MOVEMENTFROMDATECCOD_IN" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
