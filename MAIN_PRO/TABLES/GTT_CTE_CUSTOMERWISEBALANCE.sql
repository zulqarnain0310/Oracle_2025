--------------------------------------------------------
--  DDL for Table GTT_CTE_CUSTOMERWISEBALANCE
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_CTE_CUSTOMERWISEBALANCE" 
   (	"REFCUSTOMERID" VARCHAR2(20 BYTE), 
	"BALANCE" NUMBER(16,2)
   ) ON COMMIT DELETE ROWS ;
