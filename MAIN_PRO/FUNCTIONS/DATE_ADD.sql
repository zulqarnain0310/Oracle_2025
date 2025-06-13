--------------------------------------------------------
--  DDL for Function DATE_ADD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "MAIN_PRO"."DATE_ADD" (
DATE_ IN nvarchar2,
  DAYS_ IN NUMBER,
  FINAL_DATE  OUT SYS_REFCURSOR
)
RETURN DATE AS
BEGIN
SELECT TO_DATE((TO_NUMBER(TO_CHAR(DATE_,'YYYYMMDD')) + DAYS_),'YYYYMMDD') FROM DUAL;
END;

/
