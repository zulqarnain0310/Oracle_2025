--------------------------------------------------------
--  DDL for Table TT_CUSTACDATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_CUSTACDATA" 
   (	"CUSTOMERENTITYID" NUMBER(10,0), 
	"AUTHORISATIONSTATUS" VARCHAR2(20 BYTE)
   ) ON COMMIT DELETE ROWS ;
