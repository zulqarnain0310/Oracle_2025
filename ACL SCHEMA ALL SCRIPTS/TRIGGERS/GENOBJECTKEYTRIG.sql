--------------------------------------------------------
--  DDL for Trigger GENOBJECTKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."GENOBJECTKEYTRIG" 
					BEFORE INSERT ON stage_syb12_sysobjects
					FOR EACH ROW 
					BEGIN
					  IF :new.objid_gen is null THEN
					     :new.objid_gen := MD_META.get_next_id;
					  END IF;
					END GenObjectKeyTrig;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."GENOBJECTKEYTRIG" ENABLE;
