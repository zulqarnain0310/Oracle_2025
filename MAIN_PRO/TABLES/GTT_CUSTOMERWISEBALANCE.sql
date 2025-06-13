--------------------------------------------------------
--  DDL for Table GTT_CUSTOMERWISEBALANCE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_CUSTOMERWISEBALANCE" 
   (	"REFCUSTOMERID" VARCHAR2(50 CHAR), 
	"BALANCE" NUMBER
   ) ON COMMIT DELETE ROWS ;
