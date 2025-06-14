--------------------------------------------------------
--  DDL for Table GTT_CUST_PREMOC_INVESTMENT
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."GTT_CUST_PREMOC_INVESTMENT" 
   (	"INVENTITYID" NUMBER(10,0), 
	"CUSTOMERID" VARCHAR2(30 CHAR), 
	"CUSTOMERNAME" VARCHAR2(100 CHAR), 
	"ACCOUNTID" VARCHAR2(30 CHAR), 
	"FRAUDDATE" VARCHAR2(200 CHAR), 
	"TWODATE" VARCHAR2(200 CHAR), 
	"INTERESTRECEIVABLE" NUMBER, 
	"ASSETCLASSALT_KEY" NUMBER, 
	"NPADATE" VARCHAR2(200 CHAR), 
	"SECURITYVALUE" NUMBER, 
	"UCICID" VARCHAR2(30 CHAR), 
	"ADDITIONALPROVISION" NUMBER, 
	"SOURCEALT_KEY" NUMBER
   ) ON COMMIT DELETE ROWS ;
