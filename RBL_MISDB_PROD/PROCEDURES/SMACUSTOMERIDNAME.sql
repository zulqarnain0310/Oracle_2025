--------------------------------------------------------
--  DDL for Procedure SMACUSTOMERIDNAME
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" 
(
  --Declare
  v_ACCID IN VARCHAR2 DEFAULT 'ABCD1234' ,
  v_Flag IN NUMBER DEFAULT 1 
)
AS
   v_Timekey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   IF ( v_Flag = 1 ) THEN
    DECLARE
      v_temp NUMBER(1, 0) := 0;

   BEGIN
      DBMS_OUTPUT.PUT_LINE('A');
      BEGIN
         SELECT 1 INTO v_temp
           FROM DUAL
          WHERE NOT EXISTS ( SELECT A.CustomerACID ,
                                    A.CustomerId ,
                                    A.CustomerName ,
                                    'AccountDetails' TableName  
                             FROM DimSMA A

                             --INNER JOIN curdat.CustomerBasicDetail B  

                             --ON A.CustomerId=B.CustomerId 

                             --AND B.EffectiveFromTimeKey <= @Timekey  

                             --AND  B.EffectiveToTimeKey >= @Timekey
                             WHERE  A.CustomerACID = v_ACCID
                                      AND A.EffectiveFromTimeKey <= v_Timekey
                                      AND A.EffectiveToTimeKey >= v_Timekey );
      EXCEPTION
         WHEN OTHERS THEN
            NULL;
      END;

      IF v_temp = 1 THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT 'Account ID does not Exists' Error  ,
                   'AccountDetails' TableName  
              FROM DUAL  ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      ELSE

      BEGIN
         OPEN  v_cursor FOR
            SELECT A.CustomerACID ,
                   A.CustomerId ,
                   A.CustomerName ,
                   B.SourceName ,
                   B.SourceAlt_Key ,
                   'AccountDetails' TableName  
              FROM DimSMA A
                     JOIN DIMSOURCEDB b   ON a.SourceAlt_Key = b.SourceAlt_Key

            --INNER JOIN curdat.CustomerBasicDetail B  

            --ON A.CustomerId=B.CustomerId 

            --AND B.EffectiveFromTimeKey <= @Timekey  

            --AND  B.EffectiveToTimeKey >= @Timekey
            WHERE  A.CustomerACID = v_ACCID
                     AND A.EffectiveFromTimeKey <= v_Timekey
                     AND A.EffectiveToTimeKey >= v_Timekey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   ELSE
      IF ( v_Flag = 0 ) THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT A.CustomerACID ,
                   B.CustomerId ,
                   B.CustomerName ,
                   C.SourceName ,
                   C.SourceAlt_Key ,
                   'AccountDetails1' TableName  
              FROM CurDat_RBL_MISDB_PROD.AdvAcBasicDetail A
                     JOIN CurDat_RBL_MISDB_PROD.CustomerBasicDetail B   ON A.RefCustomerId = B.CustomerId
                     AND B.EffectiveFromTimeKey <= v_Timekey
                     AND B.EffectiveToTimeKey >= v_Timekey
                     JOIN DIMSOURCEDB C   ON C.SourceAlt_Key = A.SourceAlt_Key
             WHERE  A.CustomerACID = v_ACCID
                      AND A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SMACUSTOMERIDNAME" TO "ADF_CDR_RBL_STGDB";
