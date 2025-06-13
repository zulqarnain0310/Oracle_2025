--------------------------------------------------------
--  DDL for Trigger TDATA_GENPROCSTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."TDATA_GENPROCSTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_PROCEDURES
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENPROCSTRIG;

/
ALTER TRIGGER "RBL_MISDB_PROD"."TDATA_GENPROCSTRIG" ENABLE;
