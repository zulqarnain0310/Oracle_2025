--------------------------------------------------------
--  DDL for Procedure RPT_029_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_029_04122023" 
(
  v_TimeKey IN NUMBER,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   --      @TimeKey AS INT=25992,
   --	  @Cost    AS FLOAT=1
   v_Date VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TimeKey = v_TimeKey );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey = v_TimeKey );
   v_cursor SYS_REFCURSOR;

BEGIN

   -----------------------------------Provision
   OPEN  v_cursor FOR
      SELECT v_Date Process_date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CustomerID  ,
             CustomerName ,
             B.BranchCode ,
             BranchName ,
             CustomerAcID ,
             SourceName ,
             B.FacilityType ,
             SchemeType ,
             B.ProductCode ,
             ProductName ,
             ActSegmentCode ,
             AcBuSegmentDescription ,
             AcBuRevisedSegmentCode ,
             DPD_Max ,
             CASE 
                  WHEN A.SourceAlt_Key = 6 THEN 'CD'
             ELSE ' '
                END Cycle_Past_due  ,
             UTILS.CONVERT_TO_VARCHAR2(FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
             A2.AssetClassName FinalAssetName  ,
             NPANorms ,
             NVL(B.NetBalance, 0) / v_Cost NetBalance  ,
             NVL(SecurityValue, 0) / v_Cost SecurityValue  ,
             NVL(ApprRV, 0) / v_Cost ApprRV  ,
             NVL(B.SecuredAmt, 0) / v_Cost SecuredAmt  ,
             NVL(B.UnSecuredAmt, 0) / v_Cost UnSecuredAmt  ,
             NVL(B.TotalProvision, 0) / v_Cost TotalProvision  ,
             NVL(B.Provsecured, 0) / v_Cost Provsecured  ,
             NVL(B.ProvUnsecured, 0) / v_Cost ProvUnsecured  ,
             (NVL(B.NetBalance, 0) - NVL(B.TotalProvision, 0)) / v_Cost Net_NPA  ,
             (NVL(B.Provsecured, 0) / NULLIF(B.SecuredAmt, 0)) * 100 ProvisionSecured_  ,
             (NVL(B.ProvUnsecured, 0) / NULLIF(B.UnSecuredAmt, 0)) * 100 ProvisionUnSecured_  ,
             (NVL(B.TotalProvision, 0) / NULLIF(B.NetBalance, 0)) * 100 ProvisionTotal_  ,
             NVL(Y.NetBalance, 0) / v_Cost Prev_Qtr_Balance_Outstanding  ,
             NVL(Y.SecuredAmt, 0) / v_Cost Prev_Qtr_Secured_Outstanding  ,
             NVL(Y.UnSecuredAmt, 0) / v_Cost Prev_Qtr_Unsecured_Outstanding  ,
             NVL(Y.TotalProvision, 0) / v_Cost Prev_Qtr_Provision_Total  ,
             NVL(Y.Provsecured, 0) / v_Cost Prev_Qtr_Provision_Secured  ,
             NVL(Y.ProvUnsecured, 0) / v_Cost Prev_Qtr_Provision_Unsecured  ,
             NVL(Y.NetNPA, 0) / v_Cost Prev_Qtr_Net_NPA  ,
             (CASE 
                   WHEN (NVL(B.NetBalance, 0) - NVL(Y.netBalance, 0)) < 0 THEN 0
             ELSE (NVL(B.NetBalance, 0) - NVL(Y.netBalance, 0))
                END) / v_Cost NPAIncrease  ,
             (CASE 
                   WHEN (NVL(B.NetBalance, 0) - NVL(Y.netBalance, 0)) >= 0 THEN 0
             ELSE (NVL(B.NetBalance, 0) - NVL(Y.netBalance, 0))
                END) / v_Cost NPADecrease  ,
             (CASE 
                   WHEN (NVL(B.TotalProvision, 0) - NVL(Y.TotalProvision, 0)) < 0 THEN 0
             ELSE (NVL(B.TotalProvision, 0) - NVL(Y.TotalProvision, 0))
                END) / v_Cost ProvisionIncrease  ,
             (CASE 
                   WHEN (NVL(B.TotalProvision, 0) - NVL(Y.TotalProvision, 0)) >= 0 THEN 0
             ELSE (NVL(B.TotalProvision, 0) - NVL(Y.TotalProvision, 0))
                END) / v_Cost ProvisionDecrease  ,
             (CASE 
                   WHEN ((NVL(B.NetBalance, 0) - NVL(B.TotalProvision, 0)) - NVL(Y.NetNPA, 0)) < 0 THEN 0
             ELSE ((NVL(B.NetBalance, 0) - NVL(B.TotalProvision, 0)) - NVL(Y.NetNPA, 0))
                END) / v_Cost NetNPAIncrease  ,
             (CASE 
                   WHEN ((NVL(B.NetBalance, 0) - NVL(B.TotalProvision, 0)) - NVL(Y.NetNPA, 0)) >= 0 THEN 0
             ELSE ((NVL(B.NetBalance, 0) - NVL(B.TotalProvision, 0)) - NVL(Y.NetNPA, 0))
                END) / v_Cost NetNPAnDecrease  
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               AND A.EffectiveFromTimeKey <= v_TimeKey
               AND A.EffectiveToTimeKey >= v_TimeKey
               AND B.EffectiveFromTimeKey <= v_TimeKey
               AND B.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DIMSOURCEDB src   ON B.SourceAlt_Key = src.SourceAlt_Key
               AND src.EffectiveFromTimeKey <= v_TimeKey
               AND src.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimProduct PD   ON PD.ProductAlt_Key = B.ProductAlt_Key
               AND PD.EffectiveFromTimeKey <= v_TimeKey
               AND PD.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
               AND A2.EffectiveFromTimeKey <= v_TimeKey
               AND A2.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveFromTimeKey <= v_TimeKey
               AND S.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
               AND X.EffectiveFromTimeKey <= v_TimeKey
               AND X.EffectiveToTimeKey >= v_TimeKey
               LEFT JOIN ( SELECT A.CustomerEntityID ,
                                  NVL(NetBalance, 0) NetBalance  ,
                                  NVL(SecuredAmt, 0) SecuredAmt  ,
                                  NVL(UnSecuredAmt, 0) UnSecuredAmt  ,
                                  NVL(TotalProvision, 0) TotalProvision  ,
                                  NVL(Provsecured, 0) Provsecured  ,
                                  NVL(ProvUnsecured, 0) ProvUnsecured  ,
                                  (NVL(NetBalance, 0) - NVL(totalprovision, 0)) NetNPA  
                           FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
                                  JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
                            WHERE  B.EffectiveFromTimeKey <= v_LastQtrDateKey
                                     AND B.EffectiveToTimeKey >= v_LastQtrDateKey
                                     AND A.EffectiveFromTimeKey <= v_LastQtrDateKey
                                     AND A.EffectiveToTimeKey >= v_LastQtrDateKey ) Y   ON A.CustomerEntityID = Y.CustomerEntityID
               AND B.FinalAssetClassAlt_Key > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_029_04122023" TO "ADF_CDR_RBL_STGDB";
