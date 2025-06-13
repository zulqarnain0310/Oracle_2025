--------------------------------------------------------
--  DDL for Table GTT_CTE_CUSTOMERWISEBALANCE_EROSION
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_CTE_CUSTOMERWISEBALANCE_EROSION" 
   (	"REFCUSTOMERID" VARCHAR2(20 BYTE), 
	"NETBALANCE" NUMBER(16,2)
   ) ON COMMIT DELETE ROWS ;
