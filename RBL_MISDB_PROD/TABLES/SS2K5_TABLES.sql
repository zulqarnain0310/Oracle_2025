--------------------------------------------------------
--  DDL for Table SS2K5_TABLES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."SS2K5_TABLES" 
   (	"DB_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"OBJECT_ID" NUMBER(10,0), 
	"SCHEMA_ID" NUMBER(10,0), 
	"TYPE" CHAR(2 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
