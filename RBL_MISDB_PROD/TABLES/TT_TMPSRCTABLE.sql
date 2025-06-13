--------------------------------------------------------
--  DDL for Table TT_TMPSRCTABLE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."TT_TMPSRCTABLE" 
   (	"ROWID_" NUMBER(3,0), 
	"SOURCETABLE" VARCHAR2(50 BYTE)
   ) ON COMMIT DELETE ROWS ;
