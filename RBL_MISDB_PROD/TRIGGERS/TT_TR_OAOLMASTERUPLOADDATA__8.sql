--------------------------------------------------------
--  DDL for Trigger TT_TR_OAOLMASTERUPLOADDATA__8
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__8" BEFORE INSERT 
   ON tt_OAOLMasterUploadData_8
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_OAOLMasterUploadData__8.NEXTVAL INTO :NEW.EntityId
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__8" ENABLE;
