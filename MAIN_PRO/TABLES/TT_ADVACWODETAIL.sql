--------------------------------------------------------
--  DDL for Table TT_ADVACWODETAIL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_ADVACWODETAIL" 
   (	"CUSTOMERACID" VARCHAR2(30 CHAR), 
	"AMOUNTOFWRITEOFF" NUMBER(18,2)
   ) ON COMMIT DELETE ROWS ;
