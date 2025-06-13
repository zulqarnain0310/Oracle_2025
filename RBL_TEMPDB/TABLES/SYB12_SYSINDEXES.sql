--------------------------------------------------------
--  DDL for Table SYB12_SYSINDEXES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."SYB12_SYSINDEXES" 
   (	"DB_ID" NUMBER(10,0), 
	"TABLE_ID" NUMBER(10,0), 
	"INDEX_NAME" VARCHAR2(256 BYTE), 
	"INDEX_DESC" VARCHAR2(1000 BYTE), 
	"INDEX_KEYS" VARCHAR2(1000 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
