--------------------------------------------------------
--  DDL for Table TT_ERRORDATA_3
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_ERRORDATA_3" 
   (	"SRNO" NUMBER(10,0), 
	"CUSTOMERID" VARCHAR2(50 BYTE), 
	"COLUMNNAME" VARCHAR2(100 BYTE), 
	"ERRORDATA" VARCHAR2(100 BYTE), 
	"ERRORDESCRIPTION" VARCHAR2(4000 BYTE)
   ) ON COMMIT DELETE ROWS ;
