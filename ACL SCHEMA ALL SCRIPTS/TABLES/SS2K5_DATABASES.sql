--------------------------------------------------------
--  DDL for Table SS2K5_DATABASES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."SS2K5_DATABASES" 
   (	"DB_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"DATABASE_ID" NUMBER(10,0)
   ) ON COMMIT PRESERVE ROWS ;
