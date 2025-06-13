--------------------------------------------------------
--  DDL for Table GTT_PRVQTRPROV
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_PRVQTRPROV" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"PROVISIONALT_KEY" NUMBER(10,0), 
	"PROVISIONSECURED" NUMBER(5,2)
   ) ON COMMIT DELETE ROWS ;
