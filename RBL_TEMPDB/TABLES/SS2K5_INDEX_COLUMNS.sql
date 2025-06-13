--------------------------------------------------------
--  DDL for Table SS2K5_INDEX_COLUMNS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."SS2K5_INDEX_COLUMNS" 
   (	"DB_ID" NUMBER(10,0), 
	"INDEX_COLUMN_ID" NUMBER(10,0), 
	"OBJECT_ID" NUMBER(10,0), 
	"INDEX_ID" NUMBER(10,0), 
	"COLUMN_ID" NUMBER(10,0)
   ) ON COMMIT PRESERVE ROWS ;
