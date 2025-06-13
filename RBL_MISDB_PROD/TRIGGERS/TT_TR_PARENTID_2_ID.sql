--------------------------------------------------------
--  DDL for Trigger TT_TR_PARENTID_2_ID
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TT_TR_PARENTID_2_ID" BEFORE INSERT 
   ON tt_ParentID_2
   FOR EACH ROW
   BEGIN
      SELECT tt_SQ_ParentID_2_ID.NEXTVAL INTO :NEW.ID
        FROM DUAL;
   END;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TT_TR_PARENTID_2_ID" ENABLE;
