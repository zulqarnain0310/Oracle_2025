--------------------------------------------------------
--  DDL for Procedure ACLREPORT
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."ACLREPORT" 
AS
   v_Date VARCHAR2(200) ;
   v_TimeKey NUMBER(10,0) ;
   v_LastQtrDateKey NUMBER(10,0) ;

 --26940
BEGIN

   SELECT Date_ INTO v_Date 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' ;
   SELECT Timekey INTO v_TimeKey
     FROM Automate_Advances 
    WHERE  Date_ = v_Date ;
   SELECT LastQtrDateKey INTO v_LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  timekey IN ( SELECT Timekey 
                        FROM Automate_Advances 
                         WHERE  Ext_flg = 'Y') ;

   --ADDED BY MANDEEP FOR COBORROWER CHANGES IN ACL REPORT --------------------------------------
  
   DELETE FROM GTT_COBORROWER;
   UTILS.IDENTITY_RESET('GTT_COBORROWER');

   INSERT INTO GTT_COBORROWER ( 
   	SELECT DISTINCT AccountEntityId ,
                    NPA_UCIC_ID ,
                    Cohort_No 
   	  FROM MAIN_PRO.CoBorrowerCal  );
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
              a2.AssetClassName Asset_Classification  ,
              REPLACE(NVL(A.DegReason, b.NPA_Reason), ',', ' ') Degrade_Reason  ,
              b.RefPeriodOverdue NPA_Norms  ,
              CASE 
                   WHEN A.FlgErosion <> 'Y' THEN NULL
              ELSE (CASE 
                         WHEN A.SysAssetClassAlt_Key = 6 THEN 'Erosion Loss'
              ELSE 'Erosion D_1'
                 END)
                 END Erosion_Testing  ,
              Cohort_No 
       FROM MAIN_PRO.CUSTOMERCAL A
              JOIN MAIN_PRO.ACCOUNTCAL B   ON A.CustomerEntityID = B.CustomerEntityID
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
              LEFT JOIN GTT_COBORROWER CB   ON B.AccountEntityID = CB.AccountEntityId
            --WHERE  B.FinalAssetClassAlt_Key > 1  

              LEFT JOIN ExceptionFinalStatusType EF   ON b.CustomerAcID = ef.ACID
              AND EF.StatusType = 'TWO'
              AND ef.EffectiveToTimeKey = 49999
        WHERE  B.FinalAssetClassAlt_Key > 1
                 AND ef.ACID IS NULL );--select 
   --[Report date]
   --,[UCIC]
   --,[CIF ID]
   --,[Borrower Name]
   --,[Branch Code]
   --,[Branch Name]
   --,[Account No.]
   --,[Source System]
   --,[Facility]
   --,[Scheme Type]
   --,[Scheme Code]
   --,[Scheme Description]
   --,[Seg Code]
   --,[Segment Description]
   --,[Business Segment]
   --,[Account DPD]
   ----,[NPA Date]
   --,convert(nvarchar(10),convert(date,[NPA Date] , 105),23) as [NPA Date]
   --,[Outstanding]
   --,[Principal Outstanding]
   --,[Drawing Power]
   --,[Sanction Limit]
   --,[OverDrawn Amount]
   --,[DPD_Overdrawn]
   ----,[Limit/DP Overdrawn Date]
   --,convert(nvarchar(10),convert(date,[Limit/DP Overdrawn Date] , 105),23) as [Limit/DP Overdrawn Date]
   ----,[Limit Expiry Date]
   --,convert(nvarchar(10),convert(date,[Limit Expiry Date] , 105),23) as [Limit Expiry Date]
   --,[DPD_Limit Expiry]
   ----,[Stock Statement valuation date]
   --,convert(nvarchar(10),convert(date,[Stock Statement valuation date] , 105),23) as [Stock Statement valuation date]
   --,[DPD_Stock Statement expiry]
   ----,[Debit Balance Since Date]
   --,convert(nvarchar(10),convert(date,[Debit Balance Since Date] , 105),23) as [Debit Balance Since Date]
   ----,[Last Credit Date]
   --,convert(nvarchar(10),convert(date,[Last Credit Date] , 105),23) as [Last Credit Date]
   --,[DPD_No Credit]
   --,[Current quarter credit]
   --,[Current quarter interest]
   --,[Interest Not Serviced]
   --,[DPD_out of order]
   --,[CC/OD Interest Service]
   --,[Overdue Amount]
   ----,[Overdue Date]
   --,convert(nvarchar(10),convert(date,[Overdue Date] , 105),23) as [Overdue Date]
   --,[DPD_Overdue]
   --,[Principal Overdue]
   ----,[Principal Overdue Date]
   --,convert(nvarchar(10),convert(date,[Principal Overdue Date] , 105),23) as [Principal Overdue Date]
   --,[DPD_Principal Overdue]
   --,[Interest Overdue]
   ----,[Interest Overdue Date]
   --,convert(nvarchar(10),convert(date,[Interest Overdue Date] , 105),23) as [Interest Overdue Date]
   --,[DPD_Interest Overdue]
   --,[Other OverDue]
   ----,[Other OverDue Date]
   --,convert(nvarchar(10),convert(date,[Other OverDue Date] , 105),23) as [Other OverDue Date]
   --,[DPD_Other Overdue]
   --,[Bill/PC Overdue Amount]
   --,[Overdue Bill/PC ID]
   ----,[Bill/PC Overdue Date]
   --,convert(nvarchar(10),convert(date,[Bill/PC Overdue Date] , 105),23) as [Bill/PC Overdue Date]
   --,[DPD Bill/PC]
   --,[Asset Classification]
   --,[Degrade Reason]
   --,[NPA Norms]
   --,[Erosion Testing]
   --,[Cohort_No]
   --from ACL_Report_Automate

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/
