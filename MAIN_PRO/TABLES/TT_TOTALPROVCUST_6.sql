--------------------------------------------------------
--  DDL for Table TT_TOTALPROVCUST_6
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_TOTALPROVCUST_6" 
   (	"CUSTOMERENTITYID" NUMBER(10,0), 
	"TOTALPROVISION" NUMBER, 
	"BANKTOTPROVISION" NUMBER, 
	"RBITOTPROVISION" NUMBER
   ) ON COMMIT DELETE ROWS ;
