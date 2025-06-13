--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLEPANCARD
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPTABLEPANCARD" 
   (	"PANNO" VARCHAR2(12 CHAR), 
	"SYSASSETCLASSALT_KEY" NUMBER, 
	"SYSNPA_DT" VARCHAR2(200 CHAR), 
	"SOURCEDBNAME" VARCHAR2(20 BYTE)
   ) ON COMMIT DELETE ROWS ;
