--------------------------------------------------------
--  DDL for Table TT_PRODUCTCODE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_PRODUCTCODE" 
   (	"UNIQUEID" NUMBER(10,0), 
	"BUSINESSCOLVALUES1" CLOB
   ) ON COMMIT DELETE ROWS 
 LOB ("BUSINESSCOLVALUES1") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) ;
