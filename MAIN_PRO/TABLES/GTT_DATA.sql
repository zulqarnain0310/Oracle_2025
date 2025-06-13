--------------------------------------------------------
--  DDL for Table GTT_DATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_DATA" 
   (	"DEGREASON" CLOB, 
	"UCIFENTITYID" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS 
 LOB ("DEGREASON") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) ;
