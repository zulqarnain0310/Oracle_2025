--------------------------------------------------------
--  DDL for Table CURRENCY_RATE_MASTER
--------------------------------------------------------

  CREATE TABLE "DWH_STG"."CURRENCY_RATE_MASTER" 
   (	"RATE" NUMBER(18,2), 
	"RATE_DATE" DATE, 
	"CCY_CODE1" VARCHAR2(30 BYTE), 
	"CCY_CODE2" VARCHAR2(30 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;
