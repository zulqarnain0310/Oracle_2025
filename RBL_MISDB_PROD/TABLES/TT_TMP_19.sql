--------------------------------------------------------
--  DDL for Table TT_TMP_19
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TMP_19" 
   (	"RECENTROWNUMBER" NUMBER, 
	"ENTITYKEY" NUMBER(10,0), 
	"ACCOUNTNO" CLOB
   ) ON COMMIT DELETE ROWS 
 LOB ("ACCOUNTNO") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) ;
