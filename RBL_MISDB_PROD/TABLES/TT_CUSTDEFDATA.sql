--------------------------------------------------------
--  DDL for Table TT_CUSTDEFDATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_CUSTDEFDATA" 
   (	"CUSTOMERENTITYID" NUMBER(10,0), 
	"AUTHORISATIONSTATUS" VARCHAR2(20 BYTE)
   ) ON COMMIT DELETE ROWS ;
