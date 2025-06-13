--------------------------------------------------------
--  DDL for Table TT_TEMPBRDATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMPBRDATA" 
   (	"BRANCHCODE" VARCHAR2(100 BYTE), 
	"BRANCHNAME" VARCHAR2(255 BYTE)
   ) ON COMMIT DELETE ROWS ;
