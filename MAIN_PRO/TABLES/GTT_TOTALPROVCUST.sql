--------------------------------------------------------
--  DDL for Table GTT_TOTALPROVCUST
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_TOTALPROVCUST" 
   (	"CUSTOMERENTITYID" NUMBER(10,0), 
	"TOTALPROVISION" NUMBER, 
	"BANKTOTPROVISION" NUMBER, 
	"RBITOTPROVISION" NUMBER
   ) ON COMMIT DELETE ROWS ;
