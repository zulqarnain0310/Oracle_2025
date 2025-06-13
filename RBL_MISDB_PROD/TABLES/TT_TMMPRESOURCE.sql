--------------------------------------------------------
--  DDL for Table TT_TMMPRESOURCE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TMMPRESOURCE" 
   (	"CONTROLID" NUMBER(10,0), 
	"LABLE" NVARCHAR2(1000), 
	"TABLENAME" VARCHAR2(10 CHAR)
   ) ON COMMIT DELETE ROWS ;
