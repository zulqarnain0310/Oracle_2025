--------------------------------------------------------
--  DDL for Table SYB12_SYSCOMMENTS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."SYB12_SYSCOMMENTS" 
   (	"DB_ID" NUMBER(10,0), 
	"ID" NUMBER(10,0), 
	"DB_NUMBER" NUMBER(10,0), 
	"COLID" NUMBER(10,0), 
	"TEXTTYPE" NUMBER(10,0), 
	"LANGUAGE" NUMBER(10,0), 
	"TEXT" VARCHAR2(1000 CHAR), 
	"COLID2" NUMBER(10,0), 
	"STATUS" NUMBER(10,0)
   ) ON COMMIT PRESERVE ROWS ;
