--------------------------------------------------------
--  DDL for Trigger TDATA_GENSCHEMAKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_TEMPDB"."TDATA_GENSCHEMAKEYTRIG" 
                                BEFORE INSERT ON STAGE_TERADATA_DATABASES
                                FOR EACH ROW 
                                BEGIN
                                  IF :new.MDID IS NULL OR :new.MDID=0 THEN
                                     :new.MDID := MD_META.get_next_id;
                                  END IF;
                                END TDATA_GENSCHEMAKEYTRIG;

/
ALTER TRIGGER "RBL_TEMPDB"."TDATA_GENSCHEMAKEYTRIG" ENABLE;
