--------------------------------------------------------
--  DDL for Table TT_BUYOUT_UPLOAD_10
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_BUYOUT_UPLOAD_10" 
   (	"ACCOUNTNO" VARCHAR2(30 BYTE), 
	"FIELDNAME" VARCHAR2(50 BYTE), 
	"SRNO" VARCHAR2(4000 BYTE)
   ) ON COMMIT DELETE ROWS ;
