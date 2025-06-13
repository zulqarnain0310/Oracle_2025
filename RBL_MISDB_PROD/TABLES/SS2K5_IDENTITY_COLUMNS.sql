--------------------------------------------------------
--  DDL for Table SS2K5_IDENTITY_COLUMNS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."SS2K5_IDENTITY_COLUMNS" 
   (	"DB_ID" NUMBER(20,0), 
	"SEED_VALUE" NUMBER(20,0), 
	"INCREMENT_VALUE" NUMBER(20,0), 
	"LAST_VALUE" NUMBER(20,0), 
	"OBJECT_ID" NUMBER(20,0), 
	"COLUMN_ID" NUMBER(20,0)
   ) ON COMMIT PRESERVE ROWS ;
