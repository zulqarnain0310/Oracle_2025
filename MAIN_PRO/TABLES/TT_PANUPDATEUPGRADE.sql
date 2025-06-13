--------------------------------------------------------
--  DDL for Table TT_PANUPDATEUPGRADE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_PANUPDATEUPGRADE" 
   (	"PANNO" VARCHAR2(12 CHAR), 
	"TOTALCOUNTMAX" NUMBER, 
	"TOTALCOUNT" NUMBER
   ) ON COMMIT DELETE ROWS ;
