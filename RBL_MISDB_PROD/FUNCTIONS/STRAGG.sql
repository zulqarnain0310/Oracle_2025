--------------------------------------------------------
--  DDL for Function STRAGG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "RBL_MISDB_PROD"."STRAGG" (input VARCHAR2 ) RETURN VARCHAR2 PARALLEL_ENABLE AGGREGATE USING string_agg_type;

/
