--------------------------------------------------------
--  DDL for Table USERS
--------------------------------------------------------

  CREATE TABLE "RBL_MISDB_PROD"."USERS" 
   (	"USER_ID1" NUMBER(10,0), 
	"FIRSTNAME" VARCHAR2(100 BYTE), 
	"LASTNAME" VARCHAR2(100 BYTE), 
	"CITY" VARCHAR2(10 BYTE)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;
