--------------------------------------------------------
--  DDL for Table GTT_SECURITYDETAIL
--------------------------------------------------------

  CREATE GLOBAL TEMPORARY TABLE "MAIN_PRO"."GTT_SECURITYDETAIL" 
   (	"REFCUSTOMERID" VARCHAR2(50 BYTE), 
	"TOTALSECURITY" NUMBER(18,2)
   ) ON COMMIT DELETE ROWS ;
