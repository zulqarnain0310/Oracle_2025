--------------------------------------------------------
--  DDL for Table TT_MAINTBL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_MAINTBL" 
   (	"DBNAME" VARCHAR2(4000 BYTE), 
	"SCHEMANAME" VARCHAR2(4000 BYTE), 
	"TABLENAME" VARCHAR2(4000 BYTE), 
	"CREATE_DATE" VARCHAR2(200 BYTE), 
	"MODIFY_DATE" VARCHAR2(200 BYTE), 
	"RNNO" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
