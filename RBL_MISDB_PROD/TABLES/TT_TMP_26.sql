--------------------------------------------------------
--  DDL for Table TT_TMP_26
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TMP_26" 
   (	"RECENTROWNUMBER" NUMBER, 
	"ENTITY_KEY" NUMBER(10,0), 
	"CUSTOMERID" CLOB
   ) ON COMMIT DELETE ROWS 
 LOB ("CUSTOMERID") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) ;
