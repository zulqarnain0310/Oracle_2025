--------------------------------------------------------
--  DDL for Table GTT_STOCK
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_STOCK" 
   (	"ACCOUNTENTITYID" NUMBER(10,0), 
	"STKSMTDT" DATE, 
	"TYPE" CHAR(1 BYTE)
   ) ON COMMIT DELETE ROWS ;
