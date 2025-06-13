--------------------------------------------------------
--  DDL for Table SS2K5_INDEXES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."SS2K5_INDEXES" 
   (	"DB_ID" NUMBER(10,0), 
	"OBJECT_ID" NUMBER(10,0), 
	"INDEX_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"IS_UNIQUE" NUMBER(1,0), 
	"IS_PRIMARY_KEY" NUMBER(1,0)
   ) ON COMMIT PRESERVE ROWS ;
