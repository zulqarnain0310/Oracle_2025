--------------------------------------------------------
--  DDL for Table TT_TOTALPROVCUST_3
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."TT_TOTALPROVCUST_3" 
   (	"CUSTOMERENTITYID" NUMBER(10,0), 
	"TOTALPROVISION" NUMBER, 
	"BANKTOTPROVISION" NUMBER, 
	"RBITOTPROVISION" NUMBER
   ) ON COMMIT DELETE ROWS ;
