--------------------------------------------------------
--  DDL for Table MD_NUMROW$TARGET
--------------------------------------------------------

  CREATE TABLE "RBL_MISDB_PROD"."MD_NUMROW$TARGET" 
   (	"NUMROWS" NUMBER(10,0), 
	"NAME" VARCHAR2(4000 BYTE), 
	"OBJID" NUMBER(10,0)
   ) SEGMENT CREATION DEFERRED 
  PCTFREE 10 PCTUSED 40 INITRANS 1 MAXTRANS 255 
 NOCOMPRESS LOGGING
  TABLESPACE "USERS" ;
