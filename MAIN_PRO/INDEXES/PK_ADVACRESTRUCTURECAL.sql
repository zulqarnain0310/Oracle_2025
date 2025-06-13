--------------------------------------------------------
--  DDL for Index PK_ADVACRESTRUCTURECAL
--------------------------------------------------------

  CREATE UNIQUE INDEX "MAIN_PRO"."PK_ADVACRESTRUCTURECAL" ON "MAIN_PRO"."ADVACRESTRUCTURECAL_OLD" ("ENTITYKEY") 
  PCTFREE 10 INITRANS 2 MAXTRANS 255 COMPUTE STATISTICS 
  TABLESPACE "USERS" ;
