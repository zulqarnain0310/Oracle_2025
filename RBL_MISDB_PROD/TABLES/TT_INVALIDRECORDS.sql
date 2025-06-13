--------------------------------------------------------
--  DDL for Table TT_INVALIDRECORDS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_INVALIDRECORDS" 
   (	"SR_NO" VARCHAR2(10 BYTE), 
	"UCIC_ID" VARCHAR2(100 BYTE), 
	"CUSTOMER_ID" VARCHAR2(100 BYTE), 
	"ACCOUNT_ID" VARCHAR2(100 BYTE)
   ) ON COMMIT DELETE ROWS ;
