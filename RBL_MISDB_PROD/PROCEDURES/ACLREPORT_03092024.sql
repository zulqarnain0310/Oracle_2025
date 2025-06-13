--------------------------------------------------------
--  DDL for Procedure ACLREPORT_03092024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLREPORT_03092024" 
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

 --26940
BEGIN

   --ADDED BY MANDEEP FOR COBORROWER CHANGES IN ACL REPORT --------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_COBORROWER  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_COBORROWER;
   UTILS.IDENTITY_RESET('tt_COBORROWER');

   INSERT INTO tt_COBORROWER ( 
   	SELECT DISTINCT AccountEntityId ,
                    NPA_UCIC_ID ,
                    Cohort_No 
   	  FROM PRO_RBL_MISDB_PROD.CoBorrowerCal  );
   --WHERE PERC_FinalAssetClass_AltKey>1
   -------------------------------------------------------------------------------------------------
   EXECUTE IMMEDIATE ' TRUNCATE TABLE ACL_Report_Automate ';
   INSERT INTO ACL_Report_Automate
     ( SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_date  ,
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
                   WHEN SourceName = 'FIS' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuSegmentDescription
                 END Segment_Description  ,
              CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'

                   --WHEN SourceName='VisionPlus' THEN 'Credit Card'
                   WHEN SourceName = 'VisionPlus'
                     AND B.ProductCode IN ( '777','780' )
                    THEN 'Retail'
                   WHEN SourceName = 'VisionPlus'
                     AND B.ProductCode NOT IN ( '777','780' )
                    THEN 'Credit Card'
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
                    WHEN SchemeType IN ( 'FBA','PCA' )
                     THEN OverdueAmt
              ELSE 0
                 END) Bill_PC_Overdue_Amount  ,
              ' ' Overdue_Bill_PC_ID  ,
              (CASE 
                    WHEN SchemeType IN ( 'FBA','PCA' )
                     THEN OverDueSinceDt
              ELSE ' '
                 END) Bill_PC_Overdue_Date  ,
              (CASE 
                    WHEN SchemeType IN ( 'FBA','PCA' )
                     THEN DPD_Overdue
              ELSE 0
                 END) DPD_Bill_PC  ,
              --,a2.AssetClassName as [Asset Classification]
              a2.AssetClassSubGroup Asset_Classification ,---added by Prashant---02052024---

              --,REPLACE(isnull(A.DegReason,b.NPA_Reason),',','') as [Degrade Reason]
              --,REPLACE(isnull(B.DegReason,b.NPA_Reason),',','') as [Degrade Reason]
              ----Added by Prashant---19082024----for npa reason issue---
              CASE 
                   WHEN B.InitialAssetClassAlt_Key = B.FinalAssetClassAlt_Key THEN REPLACE(NVL(B.NPA_Reason, b.DegReason), ',', ' ')
              ELSE REPLACE(NVL(B.DegReason, b.NPA_Reason), ',', ' ')
                 END Degrade_Reason  ,
              b.RefPeriodOverdue NPA_Norms  ,
              CASE 
                   WHEN A.FlgErosion <> 'Y' THEN NULL
              ELSE (CASE 
                         WHEN A.SysAssetClassAlt_Key = 6 THEN 'Erosion Loss'
              ELSE 'Erosion D_1'
                 END)
                 END Erosion_Testing  ,
              Cohort_No 
       FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
              JOIN PRO_RBL_MISDB_PROD.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
              AND NVL(b.WriteOffAmount, 0) = 0
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
              LEFT JOIN tt_COBORROWER CB   ON B.AccountEntityID = CB.AccountEntityId
            --WHERE  B.FinalAssetClassAlt_Key > 1  

              LEFT JOIN ExceptionFinalStatusType EF   ON b.CustomerAcID = ef.ACID
              AND EF.StatusType = 'TWO'
              AND ef.EffectiveToTimeKey = 49999
        WHERE  B.FinalAssetClassAlt_Key > 1
                 AND ef.ACID IS NULL );
   OPEN  v_cursor FOR
      SELECT Report_date ,
             UCIC ,
             CIF_ID ,
             Borrower_Name ,
             Branch_Code ,
             Branch_Name ,
             Account_No ,
             Source_System ,
             Facility ,
             Scheme_Type ,
             Scheme_Code ,
             Scheme_Description ,
             Seg_Code ,
             Segment_Description ,
             Business_Segment ,
             Account_DPD ,
             --,[NPA Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(NPA_Date,200,p_style=>105),10,p_style=>23) NPA_Date  ,
             Outstanding ,
             Principal_Outstanding ,
             Drawing_Power ,
             Sanction_Limit ,
             OverDrawn_Amount ,
             DPD_Overdrawn ,
             --,[Limit/DP Overdrawn Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Limit_DP_Overdrawn_Date,200,p_style=>105),10,p_style=>23) Limit_DP_Overdrawn_Date  ,
             --,[Limit Expiry Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Limit_Expiry_Date,200,p_style=>105),10,p_style=>23) Limit_Expiry_Date  ,
             DPD_Limit_Expiry ,
             --,[Stock Statement valuation date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Stock_Statement_valuation_date,200,p_style=>105),10,p_style=>23) Stock_Statement_valuation_date  ,
             DPD_Stock_Statement_expiry ,
             --,[Debit Balance Since Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Debit_Balance_Since_Date,200,p_style=>105),10,p_style=>23) Debit_Balance_Since_Date  ,
             --,[Last Credit Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Last_Credit_Date,200,p_style=>105),10,p_style=>23) Last_Credit_Date  ,
             DPD_No_Credit ,
             Current_quarter_credit ,
             Current_quarter_interest ,
             Interest_Not_Serviced ,
             DPD_out_of_order ,
             CC_OD_Interest_Service ,
             Overdue_Amount ,
             --,[Overdue Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Overdue_Date,200,p_style=>105),10,p_style=>23) Overdue_Date  ,
             DPD_Overdue ,
             Principal_Overdue ,
             --,[Principal Overdue Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Principal_Overdue_Date,200,p_style=>105),10,p_style=>23) Principal_Overdue_Date  ,
             DPD_Principal_Overdue ,
             Interest_Overdue ,
             --,[Interest Overdue Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Interest_Overdue_Date,200,p_style=>105),10,p_style=>23) Interest_Overdue_Date  ,
             DPD_Interest_Overdue ,
             Other_OverDue ,
             --,[Other OverDue Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Other_OverDue_Date,200,p_style=>105),10,p_style=>23) Other_OverDue_Date  ,
             DPD_Other_Overdue ,
             Bill_PC_Overdue_Amount ,
             Overdue_Bill_PC_ID ,
             --,[Bill/PC Overdue Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(Bill_PC_Overdue_Date,200,p_style=>105),10,p_style=>23) Bill_PC_Overdue_Date  ,
             DPD_Bill_PC ,
             Asset_Classification ,
             Degrade_Reason ,
             NPA_Norms ,
             Erosion_Testing ,
             Cohort_No 
        FROM ACL_Report_Automate  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."ACLREPORT_03092024" TO "ADF_CDR_RBL_STGDB";
