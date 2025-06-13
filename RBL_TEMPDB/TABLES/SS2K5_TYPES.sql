--------------------------------------------------------
--  DDL for Table SS2K5_TYPES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."SS2K5_TYPES" 
   (	"DB_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"USER_TYPE_ID" NUMBER(10,0), 
	"SYSTEM_TYPE_ID" NUMBER(3,0)
   ) ON COMMIT PRESERVE ROWS ;
