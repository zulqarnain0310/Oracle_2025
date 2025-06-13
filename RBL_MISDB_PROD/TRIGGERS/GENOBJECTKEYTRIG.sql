--------------------------------------------------------
--  DDL for Trigger GENOBJECTKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "RBL_MISDB_PROD"."GENOBJECTKEYTRIG" 
					BEFORE INSERT ON stage_syb12_sysobjects
					FOR EACH ROW 
					BEGIN
					  IF :new.objid_gen is null THEN
					     :new.objid_gen := MD_META.get_next_id;
					  END IF;
					END GenObjectKeyTrig;

/
ALTER TRIGGER "RBL_MISDB_PROD"."GENOBJECTKEYTRIG" ENABLE;
