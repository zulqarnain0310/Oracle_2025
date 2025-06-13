--------------------------------------------------------
--  DDL for Table SS2K5_SYSPROPERTIES
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_TEMPDB"."SS2K5_SYSPROPERTIES" 
   (	"DB_ID" NUMBER(5,0), 
	"MAJOR_ID" NUMBER(5,0), 
	"MINOR_ID" NUMBER(5,0), 
	"NAME" VARCHAR2(500 BYTE), 
	"VALUE" VARCHAR2(1000 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
