--------------------------------------------------------
--  DDL for Function STRING_AGG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "MAIN_PRO"."STRING_AGG" (i_query VARCHAR2,
i_seperator VARCHAR2 DEFAULT ',')
RETURN VARCHAR2
AS
  l_return CLOB:='';
  l_temp VARCHAR(32000);
  TYPE r_cursor is REF CURSOR;
  rc r_cursor;
BEGIN
  OPEN rc FOR i_query;
  LOOP
    FETCH rc
    INTO L_TEMP;
    EXIT WHEN RC%NOTFOUND;
    l_return:=l_return||L_TEMP||i_seperator;
  END LOOP;
  RETURN RTRIM(l_return,i_seperator);
END;

/
