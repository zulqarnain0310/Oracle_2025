--------------------------------------------------------
--  DDL for Table TT_TEMPINSERT_11
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMPINSERT_11" 
   (	"PD_UCIC_ID" VARCHAR2(100 BYTE), 
	"PD_CUST_ID" VARCHAR2(100 BYTE), 
	"CD_UCIC" VARCHAR2(100 BYTE), 
	"CD_CUST_ID" VARCHAR2(100 BYTE), 
	"SOURCESYSTEM" VARCHAR2(100 BYTE)
   ) ON COMMIT DELETE ROWS ;
