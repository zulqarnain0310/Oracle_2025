--------------------------------------------------------
--  DDL for Procedure MIFINGOLDMASTER
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "ETL_MAIN_RBL_MISDB_PROD"."MIFINGOLDMASTER" 
AS

BEGIN

   EXECUTE IMMEDIATE ' DELETE FROM RBL_MISDB_PROD.MIFINGOLDMASTER ';
   INSERT INTO RBL_MISDB_PROD.MIFINGOLDMASTER
     ( DateofData, CaratMarket, Rate )
     ( SELECT DateofData ,
              CaratMarket ,
              Rate 
       FROM RBL_TEMPDB.TEMPMIFINGOLDMASTER  );

EXCEPTION WHEN NO_DATA_FOUND THEN DBMS_OUTPUT.PUT_LINE('NO DATA FOUND');
            WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/
