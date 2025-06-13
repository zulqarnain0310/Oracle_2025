--------------------------------------------------------
--  DDL for Table TT_CUSTMOCUPLOAD
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_CUSTMOCUPLOAD" 
   (	"UCICID" VARCHAR2(30 BYTE), 
	"FIELDNAME" VARCHAR2(50 BYTE), 
	"SRNO" VARCHAR2(4000 BYTE)
   ) ON COMMIT DELETE ROWS ;
