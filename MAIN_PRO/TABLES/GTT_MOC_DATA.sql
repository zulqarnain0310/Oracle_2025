--------------------------------------------------------
--  DDL for Table GTT_MOC_DATA
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_MOC_DATA" 
   (	"UCIFENTITYID" NUMBER(10,0), 
	"SYSASSETCLASSALT_KEY" NUMBER, 
	"SYSNPA_DT" VARCHAR2(200 CHAR), 
	"MOCTYPE" CHAR(6 BYTE), 
	"EFFECTIVEFROMTIMEKEY" NUMBER(10,0)
   ) ON COMMIT DELETE ROWS ;
