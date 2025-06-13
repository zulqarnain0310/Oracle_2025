--------------------------------------------------------
--  DDL for Table SS2K5_SCHEMATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."SS2K5_SCHEMATA" 
   (	"DB_ID" NUMBER(10,0), 
	"SCHEMA_OWNER" VARCHAR2(256 BYTE), 
	"SCHEMA_NAME" VARCHAR2(256 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
