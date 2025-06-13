--------------------------------------------------------
--  DDL for Trigger TT_TR_OAOLMASTERUPLOADDATA__2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__2" BEFORE INSERT 
   ON tt_OAOLMasterUploadData_2
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_OAOLMasterUploadData__2.NEXTVAL INTO :NEW.EntityId
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_OAOLMASTERUPLOADDATA__2" ENABLE;
