--------------------------------------------------------
--  DDL for Table SS2K5_SCHEMAS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."SS2K5_SCHEMAS" 
   (	"DB_ID" NUMBER(10,0), 
	"SCHEMA_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
