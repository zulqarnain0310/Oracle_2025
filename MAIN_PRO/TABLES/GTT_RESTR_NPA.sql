--------------------------------------------------------
--  DDL for Table GTT_RESTR_NPA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_RESTR_NPA" 
   (	"UCIFENTITYID" NUMBER(10,0), 
	"FINALNPADT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
