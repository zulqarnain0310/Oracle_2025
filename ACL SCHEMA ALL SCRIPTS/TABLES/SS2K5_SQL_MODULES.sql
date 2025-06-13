--------------------------------------------------------
--  DDL for Table SS2K5_SQL_MODULES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ACL_RBL_MISDB_PROD"."SS2K5_SQL_MODULES" 
   (	"DB_ID" NUMBER(10,0), 
	"DEFINITION" CLOB, 
	"OBJECT_ID" NUMBER(10,0)
   ) ON COMMIT PRESERVE ROWS 
 LOB ("DEFINITION") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) ;
