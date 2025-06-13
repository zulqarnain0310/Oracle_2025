--------------------------------------------------------
--  DDL for Trigger TDATA_GENTABLEKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."TDATA_GENTABLEKEYTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_TABLES
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENTABLEKEYTRIG;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."TDATA_GENTABLEKEYTRIG" ENABLE;
