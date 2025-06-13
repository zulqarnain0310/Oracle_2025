--------------------------------------------------------
--  DDL for Trigger TDATA_GENCHECKTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."TDATA_GENCHECKTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_SHOWTBLCHECKS
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENCHECKTRIG;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."TDATA_GENCHECKTRIG" ENABLE;
