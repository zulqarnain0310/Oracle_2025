--------------------------------------------------------
--  DDL for Procedure EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" 
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_CustomerACID IN VARCHAR2 DEFAULT NULL ,
  v_FlagAlt_Key IN VARCHAR2 DEFAULT NULL 
)
AS
   v_Timekey NUMBER(10,0);
   v_temp NUMBER(1, 0) := 0;
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDayMatrix 
    WHERE  Date_ = UTILS.CONVERT_TO_VARCHAR2(SYSDATE,200);
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE NOT EXISTS ( SELECT A.SourceAlt_Key ,
                                 AccountID ,
                                 CustomerID ,
                                 Date_ ,
                                 MarkingAlt_Key ,
                                 Amount ,
                                 'CustExceptionalDegrationDetails' TableName  
                          FROM ExceptionalDegrationDetail_Mod A
                                 JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = A.SourceAlt_Key
                           WHERE  AccountID = v_CustomerACID
                                    AND FlagAlt_Key = v_FlagAlt_Key
                                    AND A.EffectiveFromTimeKey <= v_Timekey
                                    AND A.EffectiveToTimeKey >= v_Timekey
                                    AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
    );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT ' ' SourceAlt_Key  ,
                ' ' AccountID  ,
                ' ' CustomerID  ,
                ' ' Date_  ,
                ' ' MarkingAlt_Key  ,
                ' ' Amount  ,
                ' ' TableName  ,
                ' ' ValidationPending  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT A.SourceAlt_Key ,
                AccountID ,
                CustomerID ,
                Date_ ,
                MarkingAlt_Key ,
                Amount ,
                'CustExceptionalDegrationDetails' TableName  ,
                'Y' ValidationPending  
           FROM ExceptionalDegrationDetail_Mod A
                  JOIN DIMSOURCEDB ds   ON ds.SourceAlt_Key = A.SourceAlt_Key
          WHERE  AccountID = v_CustomerACID
                   AND FlagAlt_Key = v_FlagAlt_Key
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   BEGIN
      SELECT 1 INTO v_temp
        FROM DUAL
       WHERE NOT EXISTS ( SELECT B.SourceAlt_Key ,
                                 ACID ,
                                 B.RefCustomerId ,
                                 Date_ ,
                                 UploadTypeParameterAlt_Key ,
                                 Amount ,
                                 'CustAccountFlaggingDetails' TableName  
                          FROM AccountFlaggingDetails_Mod A
                                 JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.ACID = B.CustomerACID
                                 JOIN ( SELECT ParameterAlt_Key ,
                                               ParameterName ,
                                               'UploadFlagType' Tablename  
                                        FROM DimParameter 
                                         WHERE  DimParameterName = 'UploadFlagType'
                                                  AND EffectiveFromTimeKey <= v_TimeKey
                                                  AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.UploadTypeParameterAlt_Key
                           WHERE  ACID = v_CustomerACID
                                    AND A.EffectiveFromTimeKey <= v_Timekey
                                    AND A.EffectiveToTimeKey >= v_Timekey
                                    AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
    );
   EXCEPTION
      WHEN OTHERS THEN
         NULL;
   END;

   IF v_temp = 1 THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT ' ' SourceAlt_Key  ,
                ' ' ACID  ,
                ' ' RefCustomerId  ,
                ' ' Date_  ,
                ' ' UploadTypeParameterAlt_Key  ,
                ' ' Amount  ,
                ' ' TableName  ,
                ' ' ValidationPending  
           FROM DUAL  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   ELSE

   BEGIN
      OPEN  v_cursor FOR
         SELECT B.SourceAlt_Key ,
                ACID ,
                B.RefCustomerId ,
                Date_ ,
                UploadTypeParameterAlt_Key ,
                Amount ,
                'CustAccountFlaggingDetails' TableName  ,
                'Y' ValidationPending  
           FROM AccountFlaggingDetails_Mod A
                  JOIN CurDat_RBL_MISDB_PROD.AdvAcBasicDetail B   ON A.ACID = B.CustomerACID
                  JOIN ( SELECT ParameterAlt_Key ,
                                ParameterName ,
                                'UploadFlagType' Tablename  
                         FROM DimParameter 
                          WHERE  DimParameterName = 'UploadFlagType'
                                   AND EffectiveFromTimeKey <= v_TimeKey
                                   AND EffectiveToTimeKey >= v_TimeKey ) H   ON H.ParameterAlt_Key = A.UploadTypeParameterAlt_Key
          WHERE  ACID = v_CustomerACID
                   AND A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP' )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."EXCEPTIONALDEGRATIONACCOUNTFLAGVAILDATION_PROD" TO "ADF_CDR_RBL_STGDB";
