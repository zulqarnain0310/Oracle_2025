--------------------------------------------------------
--  DDL for Table TT_TMMPRESOURCE_2
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TMMPRESOURCE_2" 
   (	"CONTROLID" NUMBER(10,0), 
	"LABLE" NVARCHAR2(1000), 
	"TABLENAME" VARCHAR2(10 CHAR)
   ) ON COMMIT DELETE ROWS ;
