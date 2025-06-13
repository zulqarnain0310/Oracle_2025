--------------------------------------------------------
--  DDL for Table GTT_TEMPTABLE_ADHARCARD
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TEMPTABLE_ADHARCARD" 
   (	"AADHARCARDNO" VARCHAR2(14 CHAR), 
	"SYSASSETCLASSALT_KEY" NUMBER, 
	"SYSNPA_DT" VARCHAR2(200 CHAR), 
	"SOURCEDBNAME" VARCHAR2(100 CHAR)
   ) ON COMMIT DELETE ROWS ;
