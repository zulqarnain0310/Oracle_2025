--------------------------------------------------------
--  DDL for Procedure FRAUD_VIEW_HISTORY
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" 
-- [Cust_grid_PUI] '1714222715864042'
 ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

(
  v_AccountID IN VARCHAR2
)
AS
   --declare @ProcessDate Datetime
   --declare @ProcessDateold Datetime
   --Set @ProcessDate =(select DataEffectiveFromDate from SysDataMatrix where CurrentStatus='C')
   v_Timekey NUMBER(10,0);
   v_cursor SYS_REFCURSOR;

BEGIN

   SELECT TimeKey 

     INTO v_Timekey
     FROM SysDataMatrix 
    WHERE  CurrentStatus = 'C';
   --SET @ProcessDateold=@ProcessDate-15

   BEGIN
      OPEN  v_cursor FOR
         SELECT RefCustomerACID ,
                'FraudHistory' TableName  ,
                RefCustomerID ,
                D.ParameterName RFA_ReportingByBank  ,
                RFA_DateReportingByBank ,
                E.ParameterName RFA_OtherBankAltKey  ,
                RFA_OtherBankDate ,
                FraudOccuranceDate ,
                FraudDeclarationDate ,
                FraudNature ,
                FraudArea ,
                CurrentAssetClassAltKey ,
                F.ParameterName ProvPref  ,
                NPA_DateAtFraud ,
                AssetClassAtFraudAltKey ,
                A.AuthorisationStatus ,
                A.EffectiveFromTimeKey ,
                A.EffectiveToTimeKey ,
                A.CreatedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateCreated,20,p_style=>103) DateCreated  ,
                A.ModifiedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateModified,20,p_style=>103) DateModified  ,
                A.ApprovedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.DateApproved,20,p_style=>103) DateApproved  ,
                A.FirstLevelApprovedBy ,
                UTILS.CONVERT_TO_VARCHAR2(A.FirstLevelDateApproved,20,p_style=>103) FirstLevelDateApproved  ,
                A.FraudAccounts_ChangeFields ,
                A.screenFlag 
           FROM Fraud_Details_Mod A
                  JOIN SysDayMatrix S1   ON S1.TimeKey = A.EffectiveFromTimeKey
                  JOIN SysDayMatrix S2   ON S2.TimeKey = A.EffectiveToTimeKey
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     CASE 
                                          WHEN ParameterName = 'NO' THEN 'N'
                                     ELSE 'Y'
                                        END ParameterName  ,
                                     'RFA_Reported_By_Bank' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'DimYesNo'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) D   ON A.RFA_ReportingByBank = D.ParameterAlt_Key
                  LEFT JOIN ( SELECT BankRPAlt_Key ParameterAlt_Key  ,
                                     BankName ParameterName  ,
                                     'Name_of_Other_Banks_Reporting_RFA' Tablename  
                              FROM DimBankRP 
                               WHERE  EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) E   ON A.RFA_OtherBankAltKey = E.ParameterAlt_Key
                  LEFT JOIN ( SELECT ParameterAlt_Key ,
                                     ParameterName ,
                                     'Provision_Proference' Tablename  
                              FROM DimParameter 
                               WHERE  DimParameterName = 'DimProvisionPreference'
                                        AND EffectiveFromTimeKey <= v_TimeKey
                                        AND EffectiveToTimeKey >= v_TimeKey ) F   ON A.ProvPref = F.ParameterAlt_Key
          WHERE  A.EffectiveFromTimeKey <= v_Timekey
                   AND A.EffectiveToTimeKey >= v_Timekey
                   AND A.RefCustomerACID = v_AccountID
                   AND NVL(A.AuthorisationStatus, 'A') = 'A' ;
         DBMS_SQL.RETURN_RESULT(v_cursor);--And Convert(date,A.Actual_Write_Off_Date)>=  Convert(Date,@ProcessDateold)
      --and Convert(date,A.Actual_Write_Off_Date)<=  Convert(Date,@ProcessDate)

   END;

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."FRAUD_VIEW_HISTORY" TO "ADF_CDR_RBL_STGDB";
