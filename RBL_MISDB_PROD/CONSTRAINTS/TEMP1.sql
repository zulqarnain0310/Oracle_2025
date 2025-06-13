--------------------------------------------------------
--  Constraints for Table TEMP1
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."TEMP1" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."TEMP1" ADD CONSTRAINT "PK__TEMP1__3213E83F79E2FDE4" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS"  ENABLE;
