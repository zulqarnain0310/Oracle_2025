--------------------------------------------------------
--  DDL for Procedure OVERDUEREPORT_FINACLEANDECBF_05012024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" 
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

   DELETE FROM tt_OverdueReportPhase1_3;
   UTILS.IDENTITY_RESET('tt_OverdueReportPhase1_3');

   INSERT INTO tt_OverdueReportPhase1_3 ( 
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
           B.Asset_Norm ,
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
           DPD_Max Account_DPD  ,
           --,FinalNpaDt as [NPA Date]
           Balance Outstanding  ,
           --,NetBalance as [Principal Outstanding]
           PrincOutStd Principal_Outstanding  ,
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
           UTILS.CONVERT_TO_NVARCHAR2(ContiExcessDt,30,p_style=>105) Limit_DP_Overdrawn_Date  ,
           UTILS.CONVERT_TO_NVARCHAR2(ReviewDueDt,30,p_style=>105) Limit_Expiry_Date  ,
           DPD_Renewal DPD_Limit_Expiry  ,
           UTILS.CONVERT_TO_NVARCHAR2(StockStDt,30,p_style=>105) Stock_Statement_valuation_date  ,
           DPD_StockStmt DPD_Stock_Statement_expiry  ,
           UTILS.CONVERT_TO_NVARCHAR2(DebitSinceDt,30,p_style=>105) Debit_Balance_Since_Date  ,
           UTILS.CONVERT_TO_NVARCHAR2(LastCrDate,30,p_style=>105) Last_Credit_Date  ,
           DPD_NoCredit DPD_No_Credit  ,
           CurQtrCredit Current_quarter_credit  ,
           CurQtrInt Current_quarter_interest  ,
           (CASE 
                 WHEN (CurQtrInt - CurQtrCredit) < 0 THEN 0
           ELSE (CurQtrInt - CurQtrCredit)
              END) Interest_Not_Serviced  ,
           DPD_IntService DPD_out_of_order  ,
           UTILS.CONVERT_TO_NVARCHAR2(IntNotServicedDt,30,p_style=>105) CC_OD_Interest_Service  ,
           OverdueAmt Overdue_Amount  ,
           UTILS.CONVERT_TO_NVARCHAR2(OverDueSinceDt,30,p_style=>105) Overdue_Date  ,
           DPD_Overdue ,
           PrincOverdue Principal_Overdue  ,
           UTILS.CONVERT_TO_NVARCHAR2(PrincOverdueSinceDt,30,p_style=>105) Principal_Overdue_Date  ,
           DPD_PrincOverdue DPD_Principal_Overdue  ,
           IntOverdue Interest_Overdue  ,
           UTILS.CONVERT_TO_NVARCHAR2(IntOverdueSinceDt,30,p_style=>105) Interest_Overdue_Date  ,
           DPD_IntOverdueSince DPD_Interest_Overdue  ,
           OtherOverdue Other_OverDue  ,
           UTILS.CONVERT_TO_NVARCHAR2(OtherOverdueSinceDt,30,p_style=>105) Other_OverDue_Date  ,
           DPD_OtherOverdueSince DPD_Other_Overdue  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN OverdueAmt
           ELSE 0
              END) Bill_PC_Overdue_Amount  ,
           ' ' Overdue_Bill_PC_ID  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN UTILS.CONVERT_TO_NVARCHAR2(OverDueSinceDt,30,p_style=>105)
           ELSE ' '
              END) Bill_PC_Overdue_Date  ,
           (CASE 
                 WHEN SchemeType IN ( 'FBA','PCA' )
                  THEN DPD_Overdue
           ELSE 0
              END) DPD_Bill_PC  ,
           a2.AssetClassName Asset_Classification  ,
           --,REPLACE(isnull(A.DegReason,b.NPA_Reason),',','') as [Degrade Reason]
           b.RefPeriodOverdue NPA_Norms  
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
           --and isnull(b.WriteOffAmount,0)=0

             LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
             AND ( src.EffectiveFromTimeKey <= v_Timekey
             AND src.EffectiveToTimeKey >= v_TimeKey )
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

   	--WHERE  B.FinalAssetClassAlt_Key = 1  
   	WHERE  ( B.SourceAlt_Key NOT IN ( 5,6 )
            )
             AND b.DPD_Max > 0
             AND b.FinalAssetClassAlt_Key = 1 );
   --------------------------------------Earlier Requirement--------------------------------------------
   --where  (B.SourceAlt_Key=3 or (B.ActSegmentCode in ('1402','1410') and b.SourceAlt_Key=1))
   --and   b.DPD_Max >0
   --and   Balance >0
   --------------------------------------------------------------------------------------------------------
   EXECUTE IMMEDIATE ' TRUNCATE TABLE OverdueReportPhase1 ';
   INSERT INTO OverdueReportPhase1
     ( SELECT Report_date ,
              UCIC ,
              CIF_ID ,
              Borrower_Name ,
              Branch_Code ,
              Branch_Name ,
              Account_No_ ,
              Source_System ,
              Facility ,
              Scheme_Type ,
              Scheme_Code ,
              Scheme_Description ,
              Seg_Code ,
              Asset_Norm ,
              Segment_Description ,
              Business_Segment ,
              Account_DPD ,
              Outstanding ,
              Principal_Outstanding ,
              Drawing_Power ,
              Sanction_Limit ,
              OverDrawn_Amount ,
              DPD_Overdrawn ,
              CASE 
                   WHEN Limit_DP_Overdrawn_Date IS NULL THEN ' '
              ELSE Limit_DP_Overdrawn_Date
                 END Limit_DP_Overdrawn_Date  ,
              CASE 
                   WHEN Limit_Expiry_Date IS NULL THEN ' '
              ELSE Limit_Expiry_Date
                 END Limit_Expiry_Date  ,
              DPD_Limit_Expiry ,
              CASE 
                   WHEN Stock_Statement_valuation_date IS NULL THEN ' '
              ELSE Stock_Statement_valuation_date
                 END Stock_Statement_valuation_date  ,
              DPD_Stock_Statement_expiry ,
              CASE 
                   WHEN Debit_Balance_Since_Date IS NULL THEN ' '
              ELSE Debit_Balance_Since_Date
                 END Debit_Balance_Since_Date  ,
              CASE 
                   WHEN Last_Credit_Date IS NULL THEN ' '
              ELSE Last_Credit_Date
                 END Last_Credit_Date  ,
              DPD_No_Credit ,
              Current_quarter_credit ,
              Current_quarter_interest ,
              Interest_Not_Serviced ,
              DPD_out_of_order ,
              CC_OD_Interest_Service ,
              Overdue_Amount ,
              CASE 
                   WHEN Overdue_Date IS NULL THEN ' '
              ELSE Overdue_Date
                 END Overdue_Date  ,
              DPD_Overdue ,
              Principal_Overdue ,
              CASE 
                   WHEN Principal_Overdue_Date IS NULL THEN ' '
              ELSE Principal_Overdue_Date
                 END Principal_Overdue_Date  ,
              DPD_Principal_Overdue ,
              Interest_Overdue ,
              CASE 
                   WHEN Interest_Overdue_Date IS NULL THEN ' '
              ELSE Interest_Overdue_Date
                 END Interest_Overdue_Date  ,
              DPD_Interest_Overdue ,
              Other_OverDue ,
              CASE 
                   WHEN Other_OverDue_Date IS NULL THEN ' '
              ELSE Other_OverDue_Date
                 END Other_OverDue_Date  ,
              DPD_Other_Overdue ,
              Bill_PC_Overdue_Amount ,
              Overdue_Bill_PC_ID ,
              CASE 
                   WHEN Bill_PC_Overdue_Date IS NULL THEN ' '
              ELSE Bill_PC_Overdue_Date
                 END Bill_PC_Overdue_Date  ,
              DPD_Bill_PC ,
              Asset_Classification ,
              NPA_Norms 
       FROM tt_OverdueReportPhase1_3  );
   OPEN  v_cursor FOR
      SELECT * 
        FROM OverdueReportPhase1  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_05012024" TO "ADF_CDR_RBL_STGDB";
