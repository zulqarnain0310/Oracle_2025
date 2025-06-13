--------------------------------------------------------
--  DDL for Table SS2K5_SCHEMATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."SS2K5_SCHEMATA" 
   (	"DB_ID" NUMBER(10,0), 
	"SCHEMA_OWNER" VARCHAR2(256 BYTE), 
	"SCHEMA_NAME" VARCHAR2(256 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
