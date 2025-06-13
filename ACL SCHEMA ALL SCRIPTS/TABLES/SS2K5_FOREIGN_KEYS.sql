--------------------------------------------------------
--  DDL for Table SS2K5_FOREIGN_KEYS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."SS2K5_FOREIGN_KEYS" 
   (	"DB_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"OBJECT_ID" NUMBER(10,0)
   ) ON COMMIT PRESERVE ROWS ;
