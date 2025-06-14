--------------------------------------------------------
--  DDL for Table DIMTHRESHOLDMASTER
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ALERT_RBL_MISDB_PROD"."DIMTHRESHOLDMASTER" 
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
	"CREATEDBY" VARCHAR2(30 BYTE), 
	"MODIFIEDBY" VARCHAR2(30 BYTE), 
	"ISEDITABLE" NUMBER(5,0)
   ) ON COMMIT DELETE ROWS ;
