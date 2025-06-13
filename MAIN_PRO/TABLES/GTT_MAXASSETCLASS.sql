--------------------------------------------------------
--  DDL for Table GTT_MAXASSETCLASS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_MAXASSETCLASS" 
   (	"COHORT_NO" NUMBER(10,0), 
	"FINALASSETCLASS_ALTKEY" NUMBER, 
	"FINALNPADT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
