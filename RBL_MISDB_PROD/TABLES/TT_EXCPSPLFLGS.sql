--------------------------------------------------------
--  DDL for Table TT_EXCPSPLFLGS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_EXCPSPLFLGS" 
   (	"CUSTOMERID" VARCHAR2(50 CHAR), 
	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"SPLFLG" VARCHAR2(17 BYTE), 
	"FLGVALUE" CHAR(1 CHAR), 
	"SPLFLGALTKEY" NUMBER, 
	"FLGDATE" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
