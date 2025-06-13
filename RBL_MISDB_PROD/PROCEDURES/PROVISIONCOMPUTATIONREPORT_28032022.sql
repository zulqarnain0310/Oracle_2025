--------------------------------------------------------
--  DDL for Procedure PROVISIONCOMPUTATIONREPORT_28032022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Ext_flg = 'Y' )
    );
   v_cursor SYS_REFCURSOR;

BEGIN

   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_Date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CIF_ID  ,
             REPLACE(CustomerName, ',', ' ') Borrower_Name  ,
             B.BranchCode Branch_Code  ,
             REPLACE(BranchName, ',', ' ') Branch_Name  ,
             CustomerAcID Account_No_  ,
             SourceName Source_System  ,
             B.FacilityType Facility  ,
             SchemeType Scheme_Type  ,
             B.ProductCode Scheme_Code  ,
             ProductName Scheme_Description  ,
             CASE 
                  WHEN B.SecApp = 'S' THEN 'SECURED'
             ELSE 'UNSECURED'
                END Secured_Unsecured  ,
             ActSegmentCode Seg_Code  ,
             (CASE 
                   WHEN SourceName = 'Ganaseva' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END) Segment_Description  ,
             CASE 
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END Business_Segment  ,
             DPD_Max Account_DPD  ,
             CD Cycle_Past_due  ,
             FinalNpaDt NPA_Date  ,
             A2.AssetClassName Asset_Classification  ,
             REFPERIODOVERDUE NPA_Norms ,--NPANorms as [NPA Norms] 

             B.NetBalance Balance_Outstanding  ,
             CurntQtrRv Customer_Security_Value  ,
             -----,SecurityValue as [Account Security Value]   -- TO BE REMOVED
             ApprRV Security_Value_Appropriated  ,
             B.SecuredAmt Secured_Outstanding  ,
             B.UnSecuredAmt Unsecured_Outstanding  ,
             B.TotalProvision Provision_Total  ,
             B.Provsecured Provision_Secured  ,
             B.ProvUnsecured Provision_Unsecured  ,
             NVL((B.NetBalance - B.TotalProvision), 0) Net_NPA  ,
             UTILS.CONVERT_TO_NUMBER((NVL((B.Provsecured / NULLIF(B.SecuredAmt, 0)) * 100, 0)),5,2) ProvisionSecured_  ,
             UTILS.CONVERT_TO_NUMBER((NVL((B.ProvUnsecured / NULLIF(B.UnSecuredAmt, 0)) * 100, 0)),5,2) ProvisionUnSecured_  ,
             UTILS.CONVERT_TO_NUMBER((NVL((B.TotalProvision / NULLIF(B.NetBalance, 0)) * 100, 0)),5,2) ProvisionTotal_  ,
             NVL(Y.NetBalance, 0) Prev_Qtr_Balance_Outstanding  ,
             NVL(Y.SecuredAmt, 0) Prev_Qtr_Secured_Outstanding  ,
             NVL(Y.UnSecuredAmt, 0) Prev_Qtr_Unsecured_Outstanding  ,
             NVL(Y.TotalProvision, 0) Prev_Qtr_Provision_Total  ,
             NVL(Y.Provsecured, 0) Prev_Qtr_Provision_Secured  ,
             NVL(Y.ProvUnsecured, 0) Prev_Qtr_Provision_Unsecured  ,
             NVL(Y.NetNPA, 0) Prev_Qtr_Net_NPA  ,
             CASE 
                  WHEN NVL((NVL(B.NetBalance, 0) - NVL(Y.netBalance, 0)), 0) < 0 THEN 0
             ELSE NVL((NVL(B.NetBalance, 0) - NVL(Y.netBalance, 0)), 0)
                END NPAIncrease  ,
             CASE 
                  WHEN NVL((B.NetBalance - NVL(Y.netBalance, 0)), 0) >= 0 THEN 0
             ELSE NVL((B.NetBalance - NVL(Y.netBalance, 0)), 0)
                END NPADecrease  ,
             CASE 
                  WHEN NVL((B.TotalProvision - NVL(Y.TotalProvision, 0)), 0) < 0 THEN 0
             ELSE NVL((B.TotalProvision - NVL(Y.TotalProvision, 0)), 0)
                END ProvisionIncrease  ,
             CASE 
                  WHEN NVL((B.TotalProvision - NVL(Y.TotalProvision, 0)), 0) >= 0 THEN 0
             ELSE NVL((B.TotalProvision - NVL(Y.TotalProvision, 0)), 0)
                END ProvisionDecrease  ,
             CASE 
                  WHEN NVL(((B.NetBalance - NVL(B.TotalProvision, 0)) - Y.NetNPA), 0) < 0 THEN 0
             ELSE NVL(((B.NetBalance - NVL(B.TotalProvision, 0)) - NVL(Y.NetNPA, 0)), 0)
                END NetNPAIncrease  ,
             CASE 
                  WHEN NVL(((B.NetBalance - NVL(B.TotalProvision, 0)) - NVL(Y.NetNPA, 0)), 0) >= 0 THEN 0
             ELSE NVL(((B.NetBalance - B.TotalProvision) - NVL(Y.NetNPA, 0)), 0)
                END NetNPAnDecrease  
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               AND NVL(B.WriteOffAmount, 0) = 0
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
               LEFT JOIN DimAssetClass a1   ON a1.EffectiveToTimeKey = 49999
               AND a1.AssetClassAlt_Key = b.InitialAssetClassAlt_Key
               LEFT JOIN DimAssetClass a2   ON a2.EffectiveToTimeKey = 49999
               AND a2.AssetClassAlt_Key = b.FinalAssetClassAlt_Key
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 49999
               LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
               AND X.EffectiveToTimeKey = 49999
               LEFT JOIN ( SELECT A.CustomerEntityID ,
                                  B.AccountEntityID ,
                                  NetBalance ,
                                  SecuredAmt ,
                                  UnSecuredAmt ,
                                  TotalProvision ,
                                  Provsecured ,
                                  ProvUnsecured ,
                                  (NetBalance - totalprovision) NetNPA  
                           FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist A
                                  JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON A.CustomerEntityID = B.CustomerEntityID --AND a.EffectiveFromTimeKey = b.EffectiveFromTimeKey

                            WHERE  B.EffectiveFromTimeKey <= v_LastQtrDateKey
                                     AND b.EffectiveToTimeKey >= v_LastQtrDateKey
                                     AND B.FinalAssetClassAlt_Key > 1
                                     AND A.EffectiveFromTimeKey <= v_LastQtrDateKey
                                     AND A.EffectiveToTimeKey >= v_LastQtrDateKey ) Y   ON B.AccountEntityID = Y.AccountEntityID
       WHERE  B.FinalAssetClassAlt_Key > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."PROVISIONCOMPUTATIONREPORT_28032022" TO "ADF_CDR_RBL_STGDB";
