--------------------------------------------------------
--  DDL for Table DIMTHRESHOLDMASTER_MOD
--------------------------------------------------------

  CREATE TABLE "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER_MOD" 
   (	"THRESHOLD_SETID" NUMBER(10,0), 
	"LOCATION" VARCHAR2(10 BYTE), 
	"LOCATIONCODE" VARCHAR2(10 BYTE), 
	"MASTERNAMEALT_KEY" NUMBER(10,0), 
	"MASTERALT_KEY" NUMBER(10,0), 
	"EFFECTIVEDT" VARCHAR2(10 BYTE), 
	"INCREASETHRESHOLD" NUMBER(18,2), 
	"DECREASETHRESHOLD" NUMBER(18,2), 
	"AUTHORISATIONSTATUS" VARCHAR2(2 BYTE), 
	"CRMODAPBY" VARCHAR2(20 BYTE), 
	"D2KTIMESTAMP" NUMBER(10,0), 
	"CHANGEFIELDS" VARCHAR2(20 BYTE), 
	"ISMAINTABLE" CHAR(1 BYTE), 
	"THRESHOLD_KEY" VARCHAR2(20 BYTE), 
	"CREATEDBY" VARCHAR2(30 BYTE), 
	"MODIFIEDBY" VARCHAR2(30 BYTE), 
	"ISEDITABLE" NUMBER(5,0)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;
