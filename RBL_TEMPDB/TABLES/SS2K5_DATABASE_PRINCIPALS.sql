--------------------------------------------------------
--  DDL for Table SS2K5_DATABASE_PRINCIPALS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."SS2K5_DATABASE_PRINCIPALS" 
   (	"DB_ID" NUMBER(10,0), 
	"DEFAULT_SCHEMA_NAME" VARCHAR2(256 BYTE), 
	"TYPE" CHAR(1 BYTE), 
	"PRINCIPAL_ID" NUMBER(10,0), 
	"OWNING_PRINCIPAL_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"SID" RAW(85)
   ) ON COMMIT PRESERVE ROWS ;
