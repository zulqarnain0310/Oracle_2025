--------------------------------------------------------
--  DDL for Table SYB12_SYSUSERS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."SYB12_SYSUSERS" 
   (	"DB_ID" NUMBER(10,0), 
	"SUID" NUMBER(10,0), 
	"DB_UID" NUMBER(10,0), 
	"GID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"ENVIRON" VARCHAR2(256 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
