--------------------------------------------------------
--  DDL for Table SS2K5_SERVER_PRINCIPALS
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "RBL_MISDB_PROD"."SS2K5_SERVER_PRINCIPALS" 
   (	"DB_ID" NUMBER(10,0), 
	"NAME" VARCHAR2(256 BYTE), 
	"SID" RAW(85), 
	"TYPE" CHAR(2 BYTE)
   ) ON COMMIT PRESERVE ROWS ;
