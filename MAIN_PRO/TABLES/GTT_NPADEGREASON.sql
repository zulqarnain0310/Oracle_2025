--------------------------------------------------------
--  DDL for Table GTT_NPADEGREASON
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_NPADEGREASON" 
   (	"UCIFENTITYID" NUMBER(10,0), 
	"DEGREASON" CLOB
   ) ON COMMIT DELETE ROWS 
 LOB ("DEGREASON") STORE AS BASICFILE (
  ENABLE STORAGE IN ROW CHUNK 8192 RETENTION 
  NOCACHE ) ;
