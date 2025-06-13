--------------------------------------------------------
--  DDL for Table TT_TEMP6_2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TEMP6_2" 
   (	"SOURCEALT_KEY" NUMBER(5,0), 
	"SOURCENAME" VARCHAR2(50 CHAR), 
	"CUSTOMERID" VARCHAR2(50 CHAR), 
	"ACLSTATUS" CHAR(7 BYTE)
   ) ON COMMIT DELETE ROWS ;
