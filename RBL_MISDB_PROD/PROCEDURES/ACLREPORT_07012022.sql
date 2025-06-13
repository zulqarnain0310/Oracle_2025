--------------------------------------------------------
--  DDL for Procedure ACLREPORT_07012022
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLREPORT_07012022" 
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
      SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_date  ,
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
             ActSegmentCode Seg_Code  ,
             CASE 
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END Segment_Description  ,
             CASE 
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END Business_Segment  ,
             DPD_Max Account_DPD  ,
             FinalNpaDt NPA_Date  ,
             Balance Outstanding  ,
             NetBalance Principal_Outstanding  ,
             DrawingPower Drawing_Power  ,
             CurrentLimit Sanction_Limit  ,
             CASE 
                  WHEN SourceName = 'Finacle'
                    AND SchemeType = 'ODA' THEN (CASE 
                                                      WHEN (NVL(b.Balance, 0) - (CASE 
                                                                                      WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                                                      ELSE NVL(b.CurrentLimit, 0)
                                                         END)) <= 0 THEN 0
                  ELSE NVL(b.Balance, 0) - (CASE 
                                                 WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                  ELSE NVL(b.CurrentLimit, 0)
                     END)
                     END)
             ELSE 0
                END OverDrawn_Amount  ,
             DPD_Overdrawn ,
             ContiExcessDt Limit_DP_Overdrawn_Date  ,
             ReviewDueDt Limit_Expiry_Date  ,
             DPD_Renewal DPD_Limit_Expiry  ,
             StockStDt Stock_Statement_valuation_date  ,
             DPD_StockStmt DPD_Stock_Statement_expiry  ,
             DebitSinceDt Debit_Balance_Since_Date  ,
             LastCrDate Last_Credit_Date  ,
             DPD_NoCredit DPD_No_Credit  ,
             CurQtrCredit Current_quarter_credit  ,
             CurQtrInt Current_quarter_interest  ,
             (CASE 
                   WHEN (CurQtrInt - CurQtrCredit) < 0 THEN 0
             ELSE (CurQtrInt - CurQtrCredit)
                END) Interest_Not_Serviced  ,
             DPD_IntService DPD_out_of_order  ,
             IntNotServicedDt CC_OD_Interest_Service  ,
             OverdueAmt Overdue_Amount  ,
             OverDueSinceDt Overdue_Date  ,
             DPD_Overdue ,
             PrincOverdue Principal_Overdue  ,
             PrincOverdueSinceDt Principal_Overdue_Date  ,
             DPD_PrincOverdue DPD_Principal_Overdue  ,
             IntOverdue Interest_Overdue  ,
             IntOverdueSinceDt Interest_Overdue_Date  ,
             DPD_IntOverdueSince DPD_Interest_Overdue  ,
             OtherOverdue Other_OverDue  ,
             OtherOverdueSinceDt Other_OverDue_Date  ,
             DPD_OtherOverdueSince DPD_Other_Overdue  ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN OverdueAmt
             ELSE 0
                END) Bill_PC_Overdue_Amount  ,
             ' ' Overdue_Bill_PC_ID  ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN OverDueSinceDt
             ELSE ' '
                END) Bill_PC_Overdue_Date  ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN DPD_Overdue
             ELSE 0
                END) DPD_Bill_PC  ,
             a2.AssetClassName Asset_Classification  ,
             REPLACE(NVL(A.DegReason, b.NPA_Reason), ',', ' ') Degrade_Reason  ,
             b.RefPeriodOverdue NPA_Norms  ,
             CASE 
                  WHEN R.RestructureDt IS NULL THEN 'N'
             ELSE 'Y'
                END RestructureFlag  ,
             R.RestructureDt ,
             R.ProvPerOnRestrucure RestructureProvision  ,
             DR.ParameterShortNameEnum Restructure_Type  ,
             B.MOC_Dt ,
             B.MOCReason ,
             CASE 
                  WHEN B.MOC_Dt IS NULL THEN 'N'
             ELSE 'Y'
                END MOC_Flag  ,
             CASE 
                  WHEN B.NPA_Reason LIKE '%w/o%' THEN 'N'
             ELSE 'Y'
                END Writeoff_flag  
        FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
               JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
               AND NVL(b.WriteOffAmount, 0) = 0
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
               LEFT JOIN ( SELECT DISTINCT AccountEntityId ,
                                           RestructureTypeAlt_Key ,
                                           RestructureDt ,
                                           RefCustomerId ,
                                           ProvPerOnRestrucure 
                           FROM CurDat_RBL_MISDB_PROD.AdvAcRestructureDetail 
                            WHERE  EffectiveToTimeKey = 49999 ) R   ON B.AccountEntityID = R.AccountEntityId --and R.EffectiveToTimeKey = 49999

               AND a.RefCustomerID = r.RefCustomerId
               LEFT JOIN DimParameter DR   ON DR.ParameterAlt_Key = R.RestructureTypeAlt_Key
               AND DR.DimParameterName = 'TypeofRestructuring'
               AND DR.EffectiveToTimeKey = 49999
       WHERE  B.FinalAssetClassAlt_Key > 1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_07012022" TO "ADF_CDR_RBL_STGDB";
