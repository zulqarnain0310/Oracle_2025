--------------------------------------------------------
--  DDL for Table TT_MAXASSETCLASS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_MAXASSETCLASS" 
   (	"COHORT_NO" NUMBER(10,0), 
	"FINALASSETCLASS_ALTKEY" NUMBER(5,0), 
	"FINALNPADT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
