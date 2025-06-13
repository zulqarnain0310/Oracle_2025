--------------------------------------------------------
--  DDL for Package TDALLPLATFORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "RBL_MISDB_PROD"."TDALLPLATFORM" AS 
    FUNCTION StageCapture(p_projectId NUMBER,
                          p_pluginClassIn varchar2,
                          p_jExists BOOLEAN := FALSE,
                          p_scratchModel BOOLEAN := FALSE) RETURN VARCHAR2;
    FUNCTION GetStatus(iid INTEGER) RETURN varchar2;
END TDALLPLATFORM;

/
