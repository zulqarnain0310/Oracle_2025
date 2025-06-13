--------------------------------------------------------
--  DDL for Table GTT_DIMREGION
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "ALERT_RBL_MISDB_PROD"."GTT_DIMREGION" 
   (	"ZONENAME" VARCHAR2(50 CHAR), 
	"ZONEALT_KEY" NUMBER(5,0), 
	"REGIONNAME" VARCHAR2(50 CHAR), 
	"REGIONALT_KEY" VARCHAR2(10 CHAR)
   ) ON COMMIT DELETE ROWS ;
