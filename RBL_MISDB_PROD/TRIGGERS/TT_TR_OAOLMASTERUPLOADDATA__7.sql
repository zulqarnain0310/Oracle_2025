--------------------------------------------------------
--  DDL for Trigger TT_TR_OAOLMASTERUPLOADDATA__7
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__7" BEFORE INSERT 
   ON tt_OAOLMasterUploadData_7
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_OAOLMasterUploadData__7.NEXTVAL INTO :NEW.EntityId
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__7" ENABLE;
