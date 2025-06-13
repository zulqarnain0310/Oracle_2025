--------------------------------------------------------
--  DDL for Procedure WILLFULLDEFAULTQUICKSEARCHLIST_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" 
(
  v_ReportedBy IN VARCHAR2 DEFAULT ' ' ,
  iv_CustomerId IN VARCHAR2 DEFAULT ' ' ,
  iv_PartyName IN VARCHAR2 DEFAULT ' ' ,
  iv_PAN IN VARCHAR2 DEFAULT ' ' ,
  v_OperationFlag IN NUMBER
)
AS
   v_CustomerId VARCHAR2(20) := iv_CustomerId;
   v_PartyName VARCHAR2(20) := iv_PartyName;
   v_PAN VARCHAR2(12) := iv_PAN;
   v_Timekey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';

   BEGIN
      DBMS_OUTPUT.PUT_LINE(v_Timekey);
      IF ( ( v_CustomerId = ' ' )
        AND ( v_PartyName = ' ' )
        AND ( v_PAN = ' ' )
        AND ( v_operationflag NOT IN ( 16,20 )
       ) ) THEN

      BEGIN
         DBMS_OUTPUT.PUT_LINE('111');
         OPEN  v_cursor FOR
            SELECT v_ReportedBy ReportedBy  ,
                   A.CustomerID ,
                   E.CustomerName ,
                   A.OSAmountinlacs OSAmountinlacs  ,
                   A.ReportingSerialNo ReportingSerialNo  ,
                   B.ParameterName SuitFiled  ,
                   C.BranchName OtherBankInvolved  ,
                   D.ParameterName CustomerType  ,
                   ' ' ACTION  ,
                   'WillfullDefault' TableName  
              FROM WillfulDefaulters_mod A
                     LEFT JOIN ( SELECT ParameterAlt_Key ,
                                        ParameterName ,
                                        'SuitFiled' Tablename  
                                 FROM DimParameter 
                                  WHERE  DimParameterName = 'DimSuitAction'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.SuitFiledorNotAlt_Key = B.ParameterAlt_Key
                     LEFT JOIN DimBranch C   ON C.BranchAlt_Key = A.NameofOtherBanksFIAlt_Key
                     AND C.EffectiveFromTimeKey <= v_TimeKey
                     AND C.EffectiveToTimeKey >= v_TimeKey
                     LEFT JOIN ( SELECT ParameterAlt_Key ,
                                        ParameterName ,
                                        'SuitFiled' Tablename  
                                 FROM DimParameter 
                                  WHERE  DimParameterName = 'CustomerType'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.CustomerTypeAlt_Key = B.ParameterAlt_Key
                     LEFT JOIN CustomerBasicDetail E   ON A.CustomerID = E.CustomerId
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey ;
            DBMS_SQL.RETURN_RESULT(v_cursor);
         RETURN;

      END;
      END IF;
      IF v_CustomerId = ' ' THEN
       v_CustomerId := NULL ;
      END IF;
      IF v_PartyName = ' ' THEN
       v_PartyName := NULL ;
      END IF;
      IF v_PAN = ' ' THEN
       v_PAN := NULL ;
      END IF;
      IF ( v_OperationFlag NOT IN ( 16,20 )
       ) THEN

      BEGIN
         OPEN  v_cursor FOR
            SELECT v_ReportedBy ReportedBy  ,
                   A.CustomerID ,
                   E.CustomerName ,
                   A.OSAmountinlacs OSAmountinlacs  ,
                   A.ReportingSerialNo ReportingSerialNo  ,
                   B.ParameterName SuitFiled  ,
                   C.BranchName OtherBankInvolved  ,
                   D.ParameterName CustomerType  ,
                   ' ' ACTION  ,
                   'WillfullDefault' TableName  
              FROM WillfulDefaulters_mod A
                     LEFT JOIN ( SELECT ParameterAlt_Key ,
                                        ParameterName ,
                                        'SuitFiled' Tablename  
                                 FROM DimParameter 
                                  WHERE  DimParameterName = 'DimSuitAction'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.SuitFiledorNotAlt_Key = B.ParameterAlt_Key
                     LEFT JOIN DimBranch C   ON C.BranchAlt_Key = A.NameofOtherBanksFIAlt_Key
                     AND C.EffectiveFromTimeKey <= v_TimeKey
                     AND C.EffectiveToTimeKey >= v_TimeKey
                     LEFT JOIN ( SELECT ParameterAlt_Key ,
                                        ParameterName ,
                                        'SuitFiled' Tablename  
                                 FROM DimParameter 
                                  WHERE  DimParameterName = 'CustomerType'
                                           AND EffectiveFromTimeKey <= v_TimeKey
                                           AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.CustomerTypeAlt_Key = B.ParameterAlt_Key
                     LEFT JOIN CustomerBasicDetail E   ON A.CustomerID = E.CustomerId
                     AND E.EffectiveFromTimeKey <= v_TimeKey
                     AND E.EffectiveToTimeKey >= v_TimeKey
             WHERE  A.EffectiveFromTimeKey <= v_Timekey
                      AND A.EffectiveToTimeKey >= v_Timekey
                      AND ( A.CustomerID = v_CustomerId
                      OR A.PartyName = v_PartyName
                      OR A.PAN = v_PAN ) ;
            DBMS_SQL.RETURN_RESULT(v_cursor);

      END;
      END IF;

   END;
   IF ( v_OperationFlag IN ( 16 )
    ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT v_ReportedBy ReportedBy  ,
                A.CustomerID ,
                E.CustomerName ,
                A.OSAmountinlacs OSAmountinlacs  ,
                A.ReportingSerialNo ReportingSerialNo  ,
                B.ParameterName SuitFiled  ,
                C.BranchName OtherBankInvolved  ,
                D.ParameterName CustomerType  ,
                ' ' ACTION  ,
                'WillfullDefault' TableName  
           FROM WillfulDefaulters_mod A
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     ParameterName ,
                                     'SuitFiled' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'DimSuitAction'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.SuitFiledorNotAlt_Key = B.ParameterAlt_Key
                  LEFT JOIN DimBranch C   ON C.BranchAlt_Key = A.NameofOtherBanksFIAlt_Key
                  AND C.EffectiveFromTimeKey <= v_TimeKey
                  AND C.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     ParameterName ,
                                     'SuitFiled' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'CustomerType'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.CustomerTypeAlt_Key = B.ParameterAlt_Key
                  LEFT JOIN CustomerBasicDetail E   ON A.CustomerID = E.CustomerId
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') IN ( 'NP','MP','DP','RM' )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   END IF;
   --AND  (A.AccountID=@ACID
   --OR B.RefCustomerId=@CustomerId
   --   OR B.CustomerName like '%' + @CustomerName+ '%'
   --   OR B.UCIF_ID=@UCICID)
   IF ( v_OperationFlag IN ( 20 )
    ) THEN

   BEGIN
      OPEN  v_cursor FOR
         SELECT v_ReportedBy ReportedBy  ,
                A.CustomerID ,
                E.CustomerName ,
                A.OSAmountinlacs OSAmountinlacs  ,
                A.ReportingSerialNo ReportingSerialNo  ,
                B.ParameterName SuitFiled  ,
                C.BranchName OtherBankInvolved  ,
                D.ParameterName CustomerType  ,
                ' ' ACTION  ,
                'WillfullDefault' TableName  
           FROM WillfulDefaulters_mod A
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     ParameterName ,
                                     'SuitFiled' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'DimSuitAction'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) B   ON A.SuitFiledorNotAlt_Key = B.ParameterAlt_Key
                  LEFT JOIN DimBranch C   ON C.BranchAlt_Key = A.NameofOtherBanksFIAlt_Key
                  AND C.EffectiveFromTimeKey <= v_TimeKey
                  AND C.EffectiveToTimeKey >= v_TimeKey
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     ParameterName ,
                                     'SuitFiled' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'CustomerType'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.CustomerTypeAlt_Key = B.ParameterAlt_Key
                  LEFT JOIN CustomerBasicDetail E   ON A.CustomerID = E.CustomerId
                  AND E.EffectiveFromTimeKey <= v_TimeKey
                  AND E.EffectiveToTimeKey >= v_TimeKey
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND NVL(A.AuthorisationStatus, 'A') IN ( '1A' )
       ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--AND  (A.AccountID=@ACID
      --OR B.RefCustomerId=@CustomerId
      --   OR B.CustomerName like '%' + @CustomerName+ '%'
      --   OR B.UCIF_ID=@UCICID)

   END;
   END IF;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."WILLFULLDEFAULTQUICKSEARCHLIST_04122023" TO "ADF_CDR_RBL_STGDB";
