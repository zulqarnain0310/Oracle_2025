--------------------------------------------------------
--  DDL for Table STAGE_SS2K5_INDEX_COLUMNS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."STAGE_SS2K5_INDEX_COLUMNS" 
   (	"SVRID_FK" NUMBER(38,0), 
	"DBID_GEN_FK" NUMBER(38,0), 
	"OBJECT_ID_GEN" NUMBER(38,0), 
	"INDEX_COLUMN_ID" NUMBER(38,0), 
	"OBJECT_ID" NUMBER(38,0), 
	"INDEX_ID" NUMBER(38,0), 
	"COLUMN_ID" NUMBER(38,0), 
	"IS_DESCENDING_KEY" NUMBER(38,0)
   ) ON COMMIT PRESERVE ROWS ;
