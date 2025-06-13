--------------------------------------------------------
--  DDL for Trigger TDATA_GENTRIGGERKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TDATA_GENTRIGGERKEYTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_TRIGGERS
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENTRIGGERKEYTRIG;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TDATA_GENTRIGGERKEYTRIG" ENABLE;
