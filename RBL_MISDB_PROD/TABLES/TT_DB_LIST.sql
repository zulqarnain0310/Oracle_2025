--------------------------------------------------------
--  DDL for Table TT_DB_LIST
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_DB_LIST" 
   (	"DBNAME" VARCHAR2(50 BYTE), 
	"ID" NUMBER(3,0)
   ) ON COMMIT DELETE ROWS ;
