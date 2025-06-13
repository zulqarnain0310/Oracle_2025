--------------------------------------------------------
--  Constraints for Table USERS
--------------------------------------------------------

  ALTER TABLE "RBL_MISDB_PROD"."USERS" MODIFY ("USER_ID1" NOT NULL ENABLE);
  ALTER TABLE "RBL_MISDB_PROD"."USERS" ADD PRIMARY KEY ("USER_ID1")
  USING INDEX PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS"  ENABLE;
