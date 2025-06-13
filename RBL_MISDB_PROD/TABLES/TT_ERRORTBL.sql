--------------------------------------------------------
--  DDL for Table TT_ERRORTBL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_ERRORTBL" 
   (	"ERRORMSG" VARCHAR2(4000 BYTE)
   ) ON COMMIT DELETE ROWS ;
