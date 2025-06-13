--------------------------------------------------------
--  DDL for Trigger GENCONNKEYTRIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE TRIGGER "ACL_RBL_MISDB_PROD"."GENCONNKEYTRIG" 
					BEFORE INSERT ON stage_serverdetail 
					FOR EACH ROW 
					BEGIN
					  IF :new.project_id is null THEN
					     :new.project_id := MD_META.get_next_id;
					  END IF;
					  IF :new.svrid is null THEN
					     :new.svrid := MD_META.get_next_id;     
					  END IF;    
					END GenConnKeyTrig;

/
ALTER TRIGGER "ACL_RBL_MISDB_PROD"."GENCONNKEYTRIG" ENABLE;
