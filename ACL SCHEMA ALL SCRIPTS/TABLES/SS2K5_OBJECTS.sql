--------------------------------------------------------
--  DDL for Table SS2K5_OBJECTS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."SS2K5_OBJECTS" 
   (	"DB_ID" NUMBER(10,0), 
	"SCHEMA_ID" NUMBER(10,0), 
	"OBJECT_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"TYPE" CHAR(2 BYTE), 
	"PARENT_OBJECT_ID" NUMBER(10,0), 
	"IS_MS_SHIPPED" NUMBER(1,0)
   ) ON COMMIT PRESERVE ROWS ;
