--------------------------------------------------------
--  DDL for Package SYB12ALLPLATFORM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "RBL_TEMPDB"."SYB12ALLPLATFORM" AS 
	                     FUNCTION StageCapture(projectId NUMBER, pluginClassIn varchar2, pjExists BOOLEAN := FALSE, p_scratchModel BOOLEAN := FALSE) RETURN VARCHAR2;
	                     FUNCTION GetStatus(iid INTEGER) RETURN varchar2;
                         FUNCTION GetDescription(basename VARCHAR2, precisionin NUMBER, scalein NUMBER, lengthin NUMBER) RETURN VARCHAR2;
                         FUNCTION LOCALSUBSTRB(vin  VARCHAR2) RETURN VARCHAR2; 
	                    END; 

/
