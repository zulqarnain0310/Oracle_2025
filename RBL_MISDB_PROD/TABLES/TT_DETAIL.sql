--------------------------------------------------------
--  DDL for Table TT_DETAIL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_DETAIL" 
   (	"SRNO" NUMBER(10,0), 
	"MENUID" NUMBER(10,0), 
	"PARENTID" NUMBER(10,0), 
	"MENUCAPTION" NVARCHAR2(600), 
	"PARENT" NUMBER(1,0)
   ) ON COMMIT DELETE ROWS ;
