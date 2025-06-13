--------------------------------------------------------
--  DDL for Table GTT_TEMPMINASSETCLASS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPMINASSETCLASS" 
   (	"UCIFID" VARCHAR2(30 CHAR), 
	"FINALASSETCLASSALT_KEY" NUMBER(10,0), 
	"NPIDT" VARCHAR2(200 CHAR)
   ) ON COMMIT DELETE ROWS ;
