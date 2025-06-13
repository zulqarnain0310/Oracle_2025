--------------------------------------------------------
--  DDL for Table SYB12_SYSCONSTRAINTS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."SYB12_SYSCONSTRAINTS" 
   (	"DB_ID" NUMBER(10,0), 
	"TABLE_ID" NUMBER(10,0), 
	"CONSTRAINT_NAME" VARCHAR2(256 BYTE), 
	"DB_DEFINITION" VARCHAR2(1000 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
