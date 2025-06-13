--------------------------------------------------------
--  Constraints for Table TEMP2
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."TEMP2" MODIFY ("ID" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."TEMP2" ADD CONSTRAINT "PK__TEMP2__3213E83FC72C2D29" PRIMARY KEY ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS"  ENABLE;
