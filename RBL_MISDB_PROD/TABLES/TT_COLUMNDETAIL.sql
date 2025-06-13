--------------------------------------------------------
--  DDL for Table TT_COLUMNDETAIL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_COLUMNDETAIL" 
   (	"SPNAME" VARCHAR2(500 CHAR), 
	"ISALLCOLUMNSFOUND" NUMBER
   ) ON COMMIT DELETE ROWS ;
