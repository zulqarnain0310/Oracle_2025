--------------------------------------------------------
--  Constraints for Table EMP
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."EMP" MODIFY ("SAL" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."EMP" ADD CONSTRAINT "UQ__EMP__3213E83E30DFE7FC" UNIQUE ("ID")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS"  ENABLE;
