--------------------------------------------------------
--  DDL for Procedure ACLREPORT_RDM_15122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_TimeKey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Date_ = v_Date );
   v_LastQtrDateKey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Ext_flg = 'Y' )
    );
   v_cursor SYS_REFCURSOR;

BEGIN

   --select CollateralTypeDescription,CollateralTypeAltKey,EffectiveToTimeKey into #DimCollateralType from  DimCollateralType
   --select ValuationDate,ValuationExpiryDate,SecurityEntityID,EffectiveToTimeKey,currentvalue into #AdvSecurityValueDetail from CurDat.AdvSecurityValueDetail
   ----WHERE EffectiveFromTimeKey <= @TimeKey-1 AND EffectiveToTimeKey >= @TimeKey-1
   --SELECT CollateralCode,SecurityType,CollateralID,Sec_Perf_Flg,AccountEntityId,SecurityEntityID,EffectiveToTimeKey,SecurityAlt_Key INTO #AdvSecurityDetail FROM CurDat.AdvSecurityDetail
   ----WHERE   EffectiveFromTimeKey <= @TimeKey-1 AND EffectiveToTimeKey >= @TimeKey-1
   DELETE FROM tt_CUSTOMERCAL_HIST_2;
   UTILS.IDENTITY_RESET('tt_CUSTOMERCAL_HIST_2');

   INSERT INTO tt_CUSTOMERCAL_HIST_2 ( 
   	SELECT CurntQtrRv ,
           CustomerEntityID 
   	  FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist 
   	 WHERE  SysAssetClassAlt_Key > 1
              AND EffectiveFromTimeKey <= v_TimeKey - 1
              AND EffectiveToTimeKey >= v_TimeKey - 1 );
   DELETE FROM tt_AccountCal_Hist_2;
   UTILS.IDENTITY_RESET('tt_AccountCal_Hist_2');

   INSERT INTO tt_AccountCal_Hist_2 ( 
   	SELECT TotalProvision ,
           AccountEntityID 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  FinalAssetClassAlt_Key > 1
              AND EffectiveFromTimeKey <= v_TimeKey - 1
              AND EffectiveToTimeKey >= v_TimeKey - 1 );
   --Truncate Table  ACL_Report_Automate
   --Insert into ACL_Report_Automate
   OPEN  v_cursor FOR
      SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CIF_ID  ,
             REPLACE(A.CustomerName, ',', ' ') Borrower_Name  ,
             --,'' as [Branch Code]
             --,'' as  [Branch Name]
             CustomerAcID Account_No_  ,
             SourceName Source_System  ,
             --,'' as [Facility]
             SchemeType Scheme_Type  ,
             B.ProductCode Scheme_Code  ,
             ProductName Scheme_Description  ,
             ActSegmentCode Seg_Code  ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END Segment_Description  ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END Business_Segment  ,
             --,'' as [Account DPD]
             FinalNpaDt NPA_Date  ,
             --,'' as [Outstanding]
             NetBalance Principal_Outstanding  ,
             CASE 
                  WHEN B.SecApp = 'S' THEN 'SECURED'
             ELSE 'UNSECURED'
                END Secured_Unsecured  ,
             b.InitialAssetClassAlt_Key Previous_day_asset_classification  ,
             b.FinalAssetClassAlt_Key Current_asset_classification  ,
             ch.CurntQtrRv Previous_day_Customer_Security_Value  ,
             a.CurntQtrRv Current_Customer_Security_Value  ,
             B.SecuredAmt Secured_Outstanding  ,
             B.UnSecuredAmt Unsecured_Outstanding  ,
             ah.TotalProvision Prev_Day_provision  ,
             b.TotalProvision Current_provision  ,
             (b.TotalProvision - ah.TotalProvision) Additional_Provision_due_to_erosion  ,
             CASE 
                  WHEN A.FlgErosion <> 'Y' THEN NULL
             ELSE (CASE 
                        WHEN A.SysAssetClassAlt_Key = 6 THEN 'Erosion Loss'
             ELSE 'Erosion D_1'
                END)
                END Erosion_Flag_D1_L_  ,
             CustomerAcID Linkage_Account_Cust_ID_  ,
             S1.CollateralCode Collateral_Code  ,
             S1.SecurityType Collateral_Type  ,
             S1.CollateralID Security_ID  ,
             S1.Sec_Perf_Flg Security_status_P_U_WIP_blank_  ,
             b.SecurityValue Security_Value  ,
             DC.CollateralTypeDescription Realisable_value_of_immovable_properties  ,
             S2.currentvalue Apportioned_value  ,
             b.UsedRV Eligible_security_value_for_NPA_Provision_computation  ,
             S2.ValuationDate Valuation_date  ,
             S2.ValuationExpiryDate Valuation_expiry_date  ,
             B.StockStDt Stock_audit_date  ,
             A.ErosionDt Erosion_date  

        --,'' as [Drawing Power]

        --,'' as [Sanction Limit]

        --,'' as [OverDrawn Amount]

        --,'' as DPD_Overdrawn 

        --,'' as [Limit/DP Overdrawn Date]

        --,'' as [Limit Expiry Date]

        --,'' as [DPD_Limit Expiry]

        --,'StockStDt' as [Stock Statement valuation date]

        --,'' as [DPD_Stock Statement expiry]

        --,'' as [Debit Balance Since Date]

        --,'' as [Last Credit Date]

        --,'' as [DPD_No Credit]

        --,'' as [Current quarter credit]

        --,'' as [Current quarter interest]

        --,'' as [Interest Not Serviced]

        --,'' as [DPD_out of order]

        --,'' as [CC/OD Interest Service]

        --,'' as [Overdue Amount]

        --,'' as [Overdue Date]

        --,'' as [DPD_Overdue]

        --,'' as [Principal Overdue]

        --,'' as [Principal Overdue Date]

        --,'' as [DPD_Principal Overdue]

        --,'' as [Interest Overdue]

        --,'' as [Interest Overdue Date]

        --,'' as [DPD_Interest Overdue]

        --,'' as [Other OverDue]

        --,'' as [Other OverDue Date]

        --,'' as  [DPD_Other Overdue]

        --,'' as [Bill/PC Overdue Amount]

        --,'' as [Overdue Bill/PC ID]

        --,'' as [Bill/PC Overdue Date]

        --,'' as [DPD Bill/PC]

        --,'' as [Asset Classification]

        --,'' as [Degrade Reason]

        --,'' as [NPA Norms]

        --,'' as [Erosion Testing]
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               AND NVL(b.WriteOffAmount, 0) = 0
               LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
               AND ( src.EffectiveFromTimeKey <= v_Timekey
               AND src.EffectiveToTimeKey >= v_TimeKey )
               LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
               AND PD.ProductAlt_Key = b.ProductAlt_Key
               LEFT JOIN tt_CUSTOMERCAL_HIST_2 CH   ON a.CustomerEntityID = CH.CustomerEntityID
               LEFT JOIN tt_AccountCal_Hist_2 AH   ON b.AccountEntityID = ah.AccountEntityID
               LEFT JOIN RBL_MISDB_PROD.AdvSecurityDetail S1   ON b.AccountEntityID = S1.AccountEntityID
               AND ( S1.EffectiveFromTimeKey <= v_Timekey
               AND S1.EffectiveToTimeKey >= v_TimeKey )
               LEFT JOIN RBL_MISDB_PROD.AdvSecurityValueDetail S2   ON S1.SecurityEntityID = S2.SecurityEntityID
               AND ( S2.EffectiveFromTimeKey <= v_Timekey
               AND S2.EffectiveToTimeKey >= v_TimeKey )
               LEFT JOIN DimCollateralType DC   ON DC.CollateralTypeAltKey = S1.SecurityAlt_Key
               AND DC.EffectiveToTimeKey = 49999
             --left join DimAssetClass a1
              --	on a1.EffectiveToTimeKey=49999
              --	and a1.AssetClassAlt_Key=b.InitialAssetClassAlt_Key
              --left join DimAssetClass a2
              --	on a2.EffectiveToTimeKey=49999
              --	and a2.AssetClassAlt_Key=b.FinalAssetClassAlt_Key

               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 49999

      --LEFT JOIN DimBranch X ON B.BranchCode = X.BranchCode and X.EffectiveToTimeKey = 49999
      WHERE  B.FinalAssetClassAlt_Key > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--select * from ACL_Report_Automate

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_RDM_15122023" TO "ADF_CDR_RBL_STGDB";
