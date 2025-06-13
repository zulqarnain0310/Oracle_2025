--------------------------------------------------------
--  DDL for Procedure OVERDUEREPORT_FINACLEANDECBF_PHASE2
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_flg = 'Y' );
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
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

   -----------------------------------------------------------------------------------------------------------
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_TempDPD  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_TempDPD;
   UTILS.IDENTITY_RESET('tt_TempDPD');

   INSERT INTO tt_TempDPD ( 
   	SELECT b.UcifEntityID ,
           b.UCIF_ID ,
           b.CustomerEntityID ,
           b.RefCustomerID ,
           b.CustomerAcID ,
           A.* ,
           NULL MAX_DPD_1  
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL b
             LEFT JOIN PRO_RBL_MISDB_PROD.Accountcal_hist_DPD a   ON a.AccountEntityid = b.AccountEntityID
             AND a.TimeKey = v_Timekey
   	 WHERE  b.FinalAssetClassAlt_Key = 1 );
   UPDATE tt_TempDPD
      SET MAX_DPD_1 = (CASE 
                            WHEN ( NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdrawn, 0)
                              AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdue, 0)
                              AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Renewal, 0)
                              AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_StockStmt, 0)
                              AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_PrincOverdue, 0)
                              AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntOverDueSince, 0)
                              AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_NoCredit, 0)
                            WHEN ( NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_NoCredit, 0)
                              AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Overdue, 0)
                              AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Renewal, 0)
                              AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_StockStmt, 0)
                              AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_PrincOverdue, 0)
                              AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntOverDueSince, 0)
                              AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Overdrawn, 0)
                            WHEN ( NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_NoCredit, 0)
                              AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdrawn, 0)
                              AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdue, 0)
                              AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_StockStmt, 0)
                              AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_PrincOverdue, 0)
                              AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntOverDueSince, 0)
                              AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Renewal, 0)
                            WHEN ( NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_NoCredit, 0)
                              AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Overdrawn, 0)
                              AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Renewal, 0)
                              AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_StockStmt, 0)
                              AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_PrincOverdue, 0)
                              AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntOverDueSince, 0)
                              AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Overdue, 0)
                            WHEN ( NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_NoCredit, 0)
                              AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdrawn, 0)
                              AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Renewal, 0)
                              AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdue, 0)
                              AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_PrincOverdue, 0)
                              AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_IntOverDueSince, 0)
                              AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_StockStmt, 0)
                            WHEN ( NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_NoCredit, 0)
                              AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdrawn, 0)
                              AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Renewal, 0)
                              AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_StockStmt, 0)
                              AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdue, 0)
                              AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_IntOverDueSince, 0)
                              AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(DPD_PrincOverdue, 0)
                            WHEN ( NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_NoCredit, 0)
                              AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Overdrawn, 0)
                              AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Renewal, 0)
                              AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_StockStmt, 0)
                              AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Overdue, 0)
                              AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_PrincOverdue, 0)
                              AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_IntOverDueSince, 0)
          ELSE NVL(A.DPD_OtherOverDueSince, 0)
             END);
   --------------------------------------------------------------------------------------------------------------
   --Truncate Table ACL_Report_Automate
   --Insert into ACL_Report_Automate
   IF utils.object_id('TEMPDB..#TEMP') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_31 ';
   END IF;
   DELETE FROM tt_TEMP_31;
   UTILS.IDENTITY_RESET('tt_TEMP_31');

   INSERT INTO tt_TEMP_31 ( 
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

                --WHEN SourceName='VisionPlus' THEN 'Credit Card'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode IN ( '777','780' )
                 THEN 'Retail'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode NOT IN ( '777','780' )
                 THEN 'Credit Card'
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
   	 WHERE  B.FinalAssetClassAlt_Key = 1
              AND B.SourceAlt_Key IN ( 1,3 )

              AND b.DPD_Max > 0
              AND Balance > 0 );
   DELETE tt_TEMP_31

    WHERE  Scheme_Type = 'ODA'
             AND NPA_Norms = 91

             --AND           GREATEST(ISNULL(DPD_Overdrawn,0),ISNULL([DPD_No Credit],0)-60,ISNULL([DPD_Stock Statement expiry],0)-90,ISNULL([DPD_Limit Expiry],0)-90) <=0
             AND NVL(DPD_Overdrawn, 0) <= 0
             AND NVL(DPD_No_Credit, 0) - 60 <= 0
             AND NVL(DPD_Stock_Statement_expiry, 0) - 90 <= 0
             AND NVL(DPD_Limit_Expiry, 0) - 90 <= 0;
   --Delete from   tt_TEMP_31
   --where         [Scheme Type]='ODA'
   --AND           [NPA Norms]=91
   ----AND           CCOD_DPD<=0
   --select [DPD_Limit Expiry],[DPD_Stock Statement expiry],[DPD_No Credit],DPD_Overdrawn,[DPD_Interest Overdue],[DPD_Other Overdue],[DPD_out of order],DPD_Overdue,[DPD_Principal Overdue],
   DELETE tt_TEMP_31

    WHERE  Scheme_Type = 'ODA'
             AND NPA_Norms = 91
             AND ( DPD_Stock_Statement_expiry <= 90
             AND DPD_Limit_Expiry <= 90
             AND NVL(DPD_No_Credit, 0) <= 60 )
             AND ( NVL(DPD_Overdrawn, 0) = 0
             AND NVL(DPD_Interest_Overdue, 0) = 0
             AND NVL(DPD_Other_Overdue, 0) = 0
             AND NVL(DPD_Overdrawn, 0) = 0
             AND NVL(DPD_Overdue, 0) = 0
             AND NVL(DPD_Principal_Overdue, 0) = 0 );
   IF utils.object_id('TEMPDB..tt_TEMP_313') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3_3 ';
   END IF;
   DELETE FROM tt_temp3_3;
   UTILS.IDENTITY_RESET('tt_temp3_3');

   INSERT INTO tt_temp3_3 SELECT RefSystemAcid ,
                                 OverDueSinceDt ,
                                 BillRefNo ,
                                 BillDueDt ,
                                 BillExtendedDueDt ,
                                 Balance ,
                                 CASE 
                                      WHEN NVL(BillDueDt, '1190-01-01') > NVL(BillExtendedDueDt, '1190-01-01') THEN BillDueDt
                                 ELSE BillExtendedDueDt
                                    END BillOverdueDt  ,
                                 CASE 
                                      WHEN CASE 
                                                WHEN NVL(BillDueDt, '1190-01-01') > NVL(BillExtendedDueDt, '1190-01-01') THEN BillDueDt
                                      ELSE BillExtendedDueDt
                                         END IS NOT NULL THEN utils.datediff('DAY', CASE 
                                                                                         WHEN NVL(BillDueDt, '1190-01-01') > NVL(BillExtendedDueDt, '1190-01-01') THEN BillDueDt
                                                                             ELSE BillExtendedDueDt
                                                                                END, v_Date) + 1
                                 ELSE 0
                                    END DPD_Overdue  

        --	 CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+1 ELSE 0 END
        FROM AdvFacBillDetail 

      --where RefSystemAcid='0070AACB0100029'
      WHERE  EffectiveFromTimeKey <= v_Timekey
               AND EffectiveToTimeKey >= v_Timekey
               AND NVL(BALANCE, 0) > 0
               AND (CASE 
                         WHEN NVL(BILLDUEDT, '1900-01-01') > NVL(BillExtendedDueDt, '1900-01-01') THEN BillDueDt
             ELSE BillExtendedDueDt
                END) <= 
             ----)<@PROCESSINGDATE  --  as discussed with Triloki Sir for SMA KIssue - Consider 1 dpd on due date  
             v_Date
        ORDER BY BillDueDt;
   IF utils.object_id('TEMPDB..tt_PC_OVERDUE_38') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PC_OVERDUE_38 ';
   END IF;
   DELETE FROM tt_PC_OVERDUE_38;
   UTILS.IDENTITY_RESET('tt_PC_OVERDUE_38');

   INSERT INTO tt_PC_OVERDUE_38 ( 
   	SELECT RefSystemAcid ,
           OverDueSinceDt ,
           PCRefNo ,
           PCDueDt ,
           PCExtendedDueDt ,
           BALANCE ,
           CASE 
                WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
           ELSE PCExtendedDueDt
              END PCOVERDUEDUEDT  ,
           -- CASE WHEN  PCOVERDUEDUEDT IS NOT NULL   THEN  DATEDIFF(DAY,PCOVERDUEDUEDT,  '2022-09-13')+1 ELSE 0 END DPD_Overdue
           CASE 
                WHEN (CASE 
                           WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
                ELSE PCExtendedDueDt
                   END) IS NOT NULL THEN utils.datediff('DAY', (CASE 
                                                                     WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
                                                        ELSE PCExtendedDueDt
                                                           END), v_Date) + 1
           ELSE 0
              END DPD_Overdue  

   	  ---MIN(BILLDUEDT) BILLDUEDT,MIN(BillExtendedDueDt) BillExtendedDueDt   
   	  FROM RBL_MISDB_PROD.AdvFacPCDetail 
   	 WHERE  EFFECTIVEFROMTIMEKEY <= v_Timekey
              AND EFFECTIVETOTIMEKEY >= v_Timekey
              AND NVL(BALANCE, 0) > 0
              AND (CASE 
                        WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
            ELSE PCExtendedDueDt
               END) <= 
            ----- )<=@PROCESSINGDATE  --  as discussed with Triloki Sir for SMA KIssue - Consider 1 dpd on due date  
            v_Date );
   ------------------------------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Final_Output') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_Output ';
   END IF;
   DELETE FROM tt_Final_Output;
   UTILS.IDENTITY_RESET('tt_Final_Output');

   INSERT INTO tt_Final_Output ( 
   	SELECT * 
   	  FROM ( SELECT A."Report date" ,
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
                    Limit_DP_Overdrawn_Date ,
                    Limit_Expiry_Date ,
                    CASE 
                         WHEN DPD_Limit_Expiry <= 90 THEN 0
                    ELSE DPD_Limit_Expiry - 90
                       END DPD_Limit_Expiry  ,
                    Stock_Statement_valuation_date ,
                    CASE 
                         WHEN DPD_Stock_Statement_expiry <= 90 THEN 0
                    ELSE DPD_Stock_Statement_expiry - 90
                       END DPD_Stock_Statement_expiry  ,
                    Debit_Balance_Since_Date ,
                    Last_Credit_Date ,
                    --,case when [DPD_No Credit]<=60 then 0 else [DPD_No Credit]-60 end [DPD_No Credit],
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    --[DPD_out of order],
                    --[CC/OD Interest Service],
                    --[Overdue Amount],
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN 0
                    ELSE A."Overdue Amount"
                       END Overdue_Amount  ,
                    --[Overdue Date],
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A."Overdue Date"
                       END Overdue_Date  ,
                    --a.DPD_Overdue,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    --[Interest Overdue],[Interest Overdue Date],[DPD_Interest Overdue],
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN 0
                    ELSE A."Interest Overdue"
                       END Interest_Overdue  ,
                    --[Overdue Date],
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A."Interest Overdue Date"
                       END Interest_Overdue_Date  ,
                    --a.DPD_Overdue,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A."DPD_Interest Overdue"
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    CASE 
                         WHEN NVL(b.Balance, 0) = 0 THEN Bill_PC_Overdue_Amount
                    ELSE Balance
                       END Bill_PC_Overdue_Amount  ,
                    CASE 
                         WHEN NVL(BillRefNo, ' ') = ' ' THEN Overdue_Bill_PC_ID
                    ELSE BillRefNo
                       END Overdue_Bill_PC_ID  ,
                    CASE 
                         WHEN NVL(BillOverdueDt, '1900-01-01') = '1900-01-01' THEN Bill_PC_Overdue_Date
                    ELSE BillOverdueDt
                       END Bill_PC_Overdue_Date  ,
                    CASE 
                         WHEN NVL(b.dpd_Overdue, 0) = 0 THEN DPD_Bill_PC
                    ELSE b.dpd_Overdue
                       END DPD_Bill_PC  ,
                    Asset_Classification ,
                    NPA_Norms 
             FROM tt_TEMP_31 a
                    LEFT JOIN tt_temp3_3 b   ON a.Account_No_ = b.RefSystemAcid
              WHERE  Scheme_Type = 'fba'
             UNION ALL 
             SELECT a.Report_date ,
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
                    Limit_DP_Overdrawn_Date ,
                    Limit_Expiry_Date ,
                    CASE 
                         WHEN DPD_Limit_Expiry <= 90 THEN 0
                    ELSE DPD_Limit_Expiry - 90
                       END col  ,
                    Stock_Statement_valuation_date ,
                    CASE 
                         WHEN DPD_Stock_Statement_expiry <= 90 THEN 0
                    ELSE DPD_Stock_Statement_expiry - 90
                       END col  ,
                    Debit_Balance_Since_Date ,
                    Last_Credit_Date ,
                    --case when [DPD_No Credit]<=60 then 0 else [DPD_No Credit]-60 end [DPD_No Credit],
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    --[DPD_out of order],
                    --[CC/OD Interest Service],[Overdue Amount],
                    --[Overdue Date],a.DPD_Overdue,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Overdue_Amount
                       END Overdue_Amount  ,
                    --[Overdue Date],
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Overdue_Date
                       END Overdue_Date  ,
                    --a.DPD_Overdue,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    --[Interest Overdue],[Interest Overdue Date],[DPD_Interest Overdue],
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Interest_Overdue
                       END Interest_Overdue  ,
                    --[Overdue Date],
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Interest_Overdue_Date
                       END Interest_Overdue_Date  ,
                    --a.DPD_Overdue,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Interest_Overdue
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    CASE 
                         WHEN NVL(b.Balance, 0) = 0 THEN Bill_PC_Overdue_Amount
                    ELSE Balance
                       END Bill_PC_Overdue_Amount  ,
                    CASE 
                         WHEN NVL(PCRefNo, ' ') = ' ' THEN Overdue_Bill_PC_ID
                    ELSE PCRefNo
                       END Overdue_Bill_PC_ID  ,
                    CASE 
                         WHEN NVL(PCOVERDUEDUEDT, '1900-01-01') = '1900-01-01' THEN Bill_PC_Overdue_Date
                    ELSE PCOVERDUEDUEDT
                       END Bill_PC_Overdue_Date  ,
                    CASE 
                         WHEN NVL(b.dpd_Overdue, 0) = 0 THEN DPD_Bill_PC
                    ELSE b.dpd_Overdue
                       END DPD_Bill_PC  ,
                    Asset_Classification ,
                    NPA_Norms 
             FROM tt_TEMP_31 a
                    LEFT JOIN tt_PC_OVERDUE_38 b   ON a.Account_No_ = b.RefSystemAcid
              WHERE  Scheme_Type = 'PCA'
             UNION 
             --CASE WHEN  PCOVERDUEDUEDT IS NOT NULL   THEN  DATEDIFF(DAY,PCOVERDUEDUEDT,  '2022-09-13')+1 ELSE 0 END DPD_Overdue
             ALL 
             SELECT a.Report_date ,
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
                    Limit_DP_Overdrawn_Date ,
                    Limit_Expiry_Date ,
                    CASE 
                         WHEN DPD_Limit_Expiry <= 90 THEN 0
                    ELSE DPD_Limit_Expiry - 90
                       END col  ,
                    Stock_Statement_valuation_date ,
                    CASE 
                         WHEN DPD_Stock_Statement_expiry <= 90 THEN 0
                    ELSE DPD_Stock_Statement_expiry - 90
                       END col  ,
                    --[DPD_Stock Statement expiry],
                    Debit_Balance_Since_Date ,
                    Last_Credit_Date ,
                    --case when [DPD_No Credit]<=60 then 0 else [DPD_No Credit]-60 end [DPD_No Credit],
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    --[DPD_out of order],
                    --[CC/OD Interest Service],
                    --[Overdue Amount],[Overdue Date],a.DPD_Overdue,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Overdue_Amount
                       END Overdue_Amount  ,
                    --[Overdue Date],
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Overdue_Date
                       END Overdue_Date  ,
                    --a.DPD_Overdue,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    --[Interest Overdue],[Interest Overdue Date],[DPD_Interest Overdue],
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Interest_Overdue
                       END Interest_Overdue  ,
                    --[Overdue Date],
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Interest_Overdue_Date
                       END Interest_Overdue_Date  ,
                    --a.DPD_Overdue,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Interest_Overdue
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    --case when isnull(b.Balance,0)=0 then [Bill/PC Overdue Amount] else Balance end [Bill/PC Overdue Amount],
                    Bill_PC_Overdue_Amount ,
                    -- case when isnull(BillRefNo,'')='' then [Overdue Bill/PC ID] else BillRefNo end [Overdue Bill/PC ID], 
                    Overdue_Bill_PC_ID ,
                    -- case when isnull(BillOverdueDt,'1900-01-01')='1900-01-01' then [Bill/PC Overdue Date] else BillOverdueDt end [Bill/PC Overdue Date] ,
                    Bill_PC_Overdue_Date ,
                    -- case when isnull(b.dpd_Overdue,0)=0 then [DPD Bill/PC] else b.dpd_Overdue end as [DPD Bill/PC],
                    DPD_Bill_PC ,
                    Asset_Classification ,
                    NPA_Norms 
             FROM tt_TEMP_31 a
              WHERE  ( Scheme_Type NOT IN ( 'PCA','FBA' )

                       OR Scheme_Type IS NULL ) ) BB );
   IF utils.object_id('TEMPDB..#TEMPSCF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPSCF ';
   END IF;
   DELETE FROM tt_TEMPSCF;
   UTILS.IDENTITY_RESET('tt_TEMPSCF');

   INSERT INTO tt_TEMPSCF ( 
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

                --WHEN SourceName='VisionPlus' THEN 'Credit Card'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode IN ( '777','780' )
                 THEN 'Retail'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode NOT IN ( '777','780' )
                 THEN 'Credit Card'
           ELSE AcBuRevisedSegmentCode
              END Business_Segment  ,
           DPD_Max Account_DPD  ,
           --,FinalNpaDt as [NPA Date]
           b.Balance Outstanding  ,
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
           UTILS.CONVERT_TO_NVARCHAR2(b.OverDueSinceDt,30,p_style=>105) Overdue_Date  ,
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
                  THEN UTILS.CONVERT_TO_NVARCHAR2(b.OverDueSinceDt,30,p_style=>105)
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

             JOIN CurDat_RBL_MISDB_PROD.AdvFacBillDetail FB   ON b.AccountEntityID = FB.AccountEntityId
             AND FB.BillNatureAlt_Key = 9
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
   	 WHERE  B.FinalAssetClassAlt_Key = 1
              AND B.SourceAlt_Key = 1
              AND b.DPD_Max > 0
              AND b.Balance > 0 );
   --and CustomerAcID='609001005504'
   DELETE tt_TEMPSCF

    WHERE  Scheme_Type = 'ODA'
             AND NPA_Norms = 91

             --AND           GREATEST(ISNULL(DPD_Overdue,0),ISNULL([DPD_Limit Expiry],0)-90) <=0
             AND NVL(DPD_Overdue, 0) <= 0
             AND NVL(DPD_Limit_Expiry, 0) - 90 <= 0;
   ---------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_313SCF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3SCF ';
   END IF;
   DELETE FROM tt_temp3SCF;
   UTILS.IDENTITY_RESET('tt_temp3SCF');

   INSERT INTO tt_temp3SCF SELECT RefSystemAcid ,
                                  OverDueSinceDt ,
                                  BillRefNo ,
                                  BillDueDt ,
                                  BillExtendedDueDt ,
                                  Balance ,
                                  CASE 
                                       WHEN NVL(BillDueDt, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
                                  ELSE InterestOverdueDate
                                     END BillOverdueDt  ,
                                  CASE 
                                       WHEN CASE 
                                                 WHEN NVL(BillDueDt, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
                                       ELSE InterestOverdueDate
                                          END IS NOT NULL THEN utils.datediff('DAY', CASE 
                                                                                          WHEN NVL(BillDueDt, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
                                                                              ELSE InterestOverdueDate
                                                                                 END, v_Date) + 1
                                  ELSE 0
                                     END DPD_Overdue  ,
                                  ReviewDuedate ,
                                  OverdueInterest OverdueInterest1  ,
                                  InterestOverdueDate InterestOverdueDate1  ,
                                  BillDueDt princOverDueDate  ,
                                  Balance - OverdueInterest princOverDue_Amount  

        --	 CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+1 ELSE 0 END
        FROM AdvFacBillDetail 

      --where RefSystemAcid='0070AACB0100029'
      WHERE  EffectiveFromTimeKey <= v_Timekey
               AND EffectiveToTimeKey >= v_Timekey
               AND NVL(BALANCE, 0) > 0
               AND BillNatureAlt_Key = 9
               AND (CASE 
                         WHEN NVL(BILLDUEDT, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
             ELSE InterestOverdueDate
                END) <= 
             ----)<@PROCESSINGDATE  --  as discussed with Triloki Sir for SMA KIssue - Consider 1 dpd on due date  
             v_Date
        ORDER BY BillDueDt;
   --SELECT * FROM tt_TEMP_313SCF
   -----------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Final_OutputSCF') IS NOT NULL THEN
    --Update tt_Final_OutputSCF
   --set    [Interest Overdue Date]=null
   --where  [Interest Overdue Date] >@Date
   --Update tt_Final_OutputSCF
   --set    [Principal Overdue Date]=null
   --where  [Principal Overdue Date] >@Date
   -----------------------------------------------------------------------------------------------------------------------------
   --IF OBJECT_ID('TEMPDB..#OverdueReportPhase2') IS NOT NULL  
   --    DROP TABLE #OverdueReportPhase2 
   --select * into #OverdueReportPhase2 from OverdueReportPhase2 where 1=2
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_OutputSCF ';
   END IF;
   DELETE FROM tt_Final_OutputSCF;
   UTILS.IDENTITY_RESET('tt_Final_OutputSCF');

   INSERT INTO tt_Final_OutputSCF ( 
   	SELECT DISTINCT A."Report date" ,
                    UCIC ,
                    CIF_ID ,
                    Borrower_Name ,
                    Branch_Code ,
                    Branch_Name ,
                    Account_No_ ,
                    'SCF' Source_System  ,
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
                    Limit_DP_Overdrawn_Date ,
                    B.ReviewDuedate Limit_Expiry_Date  ,
                    CASE 
                         WHEN DPD_Limit_Expiry <= 90 THEN 0
                    ELSE DPD_Limit_Expiry - 90
                       END DPD_Limit_Expiry  ,
                    Stock_Statement_valuation_date ,
                    CASE 
                         WHEN DPD_Stock_Statement_expiry <= 90 THEN 0
                    ELSE DPD_Stock_Statement_expiry - 90
                       END DPD_Stock_Statement_expiry  ,
                    Debit_Balance_Since_Date ,
                    Last_Credit_Date ,
                    --,case when [DPD_No Credit]<=60 then 0 else [DPD_No Credit]-60 end [DPD_No Credit],
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    --[DPD_out of order],
                    --[CC/OD Interest Service],
                    --[Overdue Amount],
                    --case when a.[Scheme Type]='ODA' and a.[NPA Norms]=91 then 0 else a.[Overdue Amount] end [Overdue Amount],
                    A."Overdue Amount" ,
                    --[Overdue Date],
                    --case when a.[Scheme Type]='ODA' and a.[NPA Norms]=91 then '' else a.[Overdue Date] end [Overdue Date],
                    A."Overdue Date" ,
                    --a.DPD_Overdue,
                    --case when a.[Scheme Type]='ODA' and a.[NPA Norms]=91 then '' else a.DPD_Overdue end DPD_Overdue,
                    A.DPD_Overdue ,
                    b.princOverDue_Amount Principal_Overdue  ,
                    b.princOverDueDate Principal_Overdue_Date  ,
                    --[DPD_Principal Overdue],
                    CASE 
                         WHEN CASE 
                                   WHEN B.princOverDueDate IS NOT NULL THEN utils.datediff('DAY', princOverDueDate, v_Date) + 1
                         ELSE 0
                            END < 0 THEN 0
                    ELSE CASE 
                              WHEN B.princOverDueDate IS NOT NULL THEN utils.datediff('DAY', princOverDueDate, v_Date) + 1
                    ELSE 0
                       END
                       END DPD_Principal_Overdue  ,
                    --[Interest Overdue],[Interest Overdue Date],[DPD_Interest Overdue],
                    --case when a.[Scheme Type]='ODA' and a.[NPA Norms]=91 then 0 else a.[Interest Overdue] end [Interest Overdue],
                    OverdueInterest1 Interest_Overdue  ,
                    --[Overdue Date],
                    InterestOverdueDate1 Interest_Overdue_Date  ,
                    --case when a.[Scheme Type]='ODA' and a.[NPA Norms]=91 then '' else a.[Interest Overdue Date] end [Interest Overdue Date],
                    --a.DPD_Overdue,
                    --case when a.[Scheme Type]='ODA' and a.[NPA Norms]=91 then '' else a.[DPD_Interest Overdue] end [DPD_Interest Overdue],
                    CASE 
                         WHEN CASE 
                                   WHEN B.InterestOverdueDate1 IS NOT NULL THEN utils.datediff('DAY', InterestOverdueDate1, v_Date) + 1
                         ELSE 0
                            END < 0 THEN 0
                    ELSE CASE 
                              WHEN B.InterestOverdueDate1 IS NOT NULL THEN utils.datediff('DAY', InterestOverdueDate1, v_Date) + 1
                    ELSE 0
                       END
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    CASE 
                         WHEN NVL(b.Balance, 0) = 0 THEN Bill_PC_Overdue_Amount
                    ELSE Balance
                       END Bill_PC_Overdue_Amount  ,
                    CASE 
                         WHEN NVL(BillRefNo, ' ') = ' ' THEN Overdue_Bill_PC_ID
                    ELSE BillRefNo
                       END Overdue_Bill_PC_ID  ,
                    CASE 
                         WHEN NVL(BillOverdueDt, '1900-01-01') = '1900-01-01' THEN Bill_PC_Overdue_Date
                    ELSE BillOverdueDt
                       END Bill_PC_Overdue_Date  ,
                    CASE 
                         WHEN NVL(b.dpd_Overdue, 0) = 0 THEN DPD_Bill_PC
                    ELSE b.dpd_Overdue
                       END DPD_Bill_PC  ,
                    Asset_Classification ,
                    NPA_Norms 
   	  FROM tt_TEMPSCF a
             LEFT JOIN tt_temp3SCF b   ON a.Account_No_ = b.RefSystemAcid );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE OverdueReportPhase2 ';
   --ALTER TABLE #OverdueReportPhase2 ALTER COLUMN  [Overdue Bill/PC ID] VARCHAR(40)
   INSERT INTO OverdueReportPhase2
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
              --GREATEST(ISNULL(DPD_Overdrawn,0),ISNULL([DPD_No Credit],0),ISNULL([DPD_Stock Statement expiry],0),ISNULL([DPD_Limit Expiry],0),isnull(DPD_Overdue,0),
              --  isnull([DPD_Principal Overdue],0),isnull([DPD_Interest Overdue],0),isnull([DPD_Other Overdue],0)) [Account DPD]
              b.MAX_DPD_1 Account_DPD  ,
              Outstanding ,
              Principal_Outstanding ,
              Drawing_Power ,
              Sanction_Limit ,
              OverDrawn_Amount ,
              DPD_Overdrawn ,
              CASE 
                   WHEN ( Limit_DP_Overdrawn_Date IS NULL
                     OR Limit_DP_Overdrawn_Date = '01-01-1900' ) THEN ' '
              ELSE Limit_DP_Overdrawn_Date
                 END Limit_DP_Overdrawn_Date  ,
              CASE 
                   WHEN ( Limit_Expiry_Date IS NULL
                     OR Limit_Expiry_Date = '01-01-1900' ) THEN ' '
              ELSE Limit_Expiry_Date
                 END Limit_Expiry_Date  ,
              DPD_Limit_Expiry ,
              CASE 
                   WHEN ( Stock_Statement_valuation_date IS NULL
                     OR Stock_Statement_valuation_date = '01-01-1900' ) THEN ' '
              ELSE Stock_Statement_valuation_date
                 END Stock_Statement_valuation_date  ,
              DPD_Stock_Statement_expiry ,
              --[DPD_Stock Statement expiry],
              CASE 
                   WHEN ( Debit_Balance_Since_Date IS NULL
                     OR Debit_Balance_Since_Date = '01-01-1900' ) THEN ' '
              ELSE Debit_Balance_Since_Date
                 END Debit_Balance_Since_Date  ,
              CASE 
                   WHEN ( Last_Credit_Date IS NULL
                     OR Last_Credit_Date = '01-01-1900' ) THEN ' '
              ELSE Last_Credit_Date
                 END Last_Credit_Date  ,
              --case when [DPD_No Credit]<=60 then 0 else [DPD_No Credit]-60 end [DPD_No Credit],
              DPD_No_Credit ,
              Current_quarter_credit ,
              Current_quarter_interest ,
              Interest_Not_Serviced ,
              --[DPD_out of order],
              --[CC/OD Interest Service],
              --[Overdue Amount],[Overdue Date],a.DPD_Overdue,
              Overdue_Amount ,
              --[Overdue Date],
              CASE 
                   WHEN ( Overdue_Date IS NULL
                     OR Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Overdue_Date
                 END Overdue_Date  ,
              --a.DPD_Overdue,
              DPD_Overdue ,
              Principal_Overdue ,
              CASE 
                   WHEN ( Principal_Overdue_Date IS NULL
                     OR Principal_Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Principal_Overdue_Date
                 END Principal_Overdue_Date  ,
              DPD_Principal_Overdue ,
              --[Interest Overdue],[Interest Overdue Date],[DPD_Interest Overdue],
              Interest_Overdue ,
              --[Overdue Date],
              CASE 
                   WHEN ( Interest_Overdue_Date IS NULL
                     OR Interest_Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Interest_Overdue_Date
                 END Interest_Overdue_Date  ,
              --a.DPD_Overdue,
              DPD_Interest_Overdue ,
              Other_OverDue ,
              CASE 
                   WHEN ( Other_OverDue_Date IS NULL
                     OR Other_OverDue_Date = '01-01-1900' ) THEN ' '
              ELSE Other_OverDue_Date
                 END Other_OverDue_Date  ,
              DPD_Other_Overdue ,
              --case when isnull(b.Balance,0)=0 then [Bill/PC Overdue Amount] else Balance end [Bill/PC Overdue Amount],
              Bill_PC_Overdue_Amount ,
              -- case when isnull(BillRefNo,'')='' then [Overdue Bill/PC ID] else BillRefNo end [Overdue Bill/PC ID], 
              Overdue_Bill_PC_ID ,
              -- case when isnull(BillOverdueDt,'1900-01-01')='1900-01-01' then [Bill/PC Overdue Date] else BillOverdueDt end [Bill/PC Overdue Date] ,
              CASE 
                   WHEN UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105) = '01-01-1900' THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105)
                 END Bill_PC_Overdue_Date  ,
              -- case when isnull(b.dpd_Overdue,0)=0 then [DPD Bill/PC] else b.dpd_Overdue end as [DPD Bill/PC],
              DPD_Bill_PC ,
              Asset_Classification ,
              NPA_Norms 
       FROM tt_Final_Output a
              JOIN tt_TempDPD b   ON a.Account_No_ = b.CustomerAcID

       --where [Account No.]='609000715329'

       --where GREATEST(ISNULL(DPD_Overdrawn,0),ISNULL([DPD_No Credit],0),ISNULL([DPD_Stock Statement expiry],0),ISNULL([DPD_Limit Expiry],0),isnull(DPD_Overdue,0),

       -- isnull([DPD_Principal Overdue],0),isnull([DPD_Interest Overdue],0),isnull([DPD_Other Overdue],0))>0
       WHERE  b.MAX_DPD_1 > 0
       UNION 
       SELECT Report_date ,
              UCIC ,
              CIF_ID ,
              Borrower_Name ,
              Branch_Code ,
              Branch_Name ,
              Account_No_ ,
              'SCF' Source_System  ,
              Facility ,
              Scheme_Type ,
              Scheme_Code ,
              Scheme_Description ,
              Seg_Code ,
              Asset_Norm ,
              Segment_Description ,
              Business_Segment ,
              --GREATEST(ISNULL(DPD_Overdrawn,0),ISNULL([DPD_No Credit],0),ISNULL([DPD_Stock Statement expiry],0),ISNULL([DPD_Limit Expiry],0),isnull(DPD_Overdue,0),
              --  isnull([DPD_Principal Overdue],0),isnull([DPD_Interest Overdue],0),isnull([DPD_Other Overdue],0)) [Account DPD]
              b.MAX_DPD_1 Account_DPD  ,
              Outstanding ,
              Principal_Outstanding ,
              Drawing_Power ,
              Sanction_Limit ,
              OverDrawn_Amount ,
              DPD_Overdrawn ,
              CASE 
                   WHEN ( Limit_DP_Overdrawn_Date IS NULL
                     OR Limit_DP_Overdrawn_Date = '01-01-1900' ) THEN ' '
              ELSE Limit_DP_Overdrawn_Date
                 END Limit_DP_Overdrawn_Date  ,
              CASE 
                   WHEN ( UTILS.CONVERT_TO_NVARCHAR2(Limit_Expiry_Date,30,p_style=>105) IS NULL
                     OR UTILS.CONVERT_TO_NVARCHAR2(Limit_Expiry_Date,30,p_style=>105) = '01-01-1900' ) THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Limit_Expiry_Date,30,p_style=>105)
                 END Limit_Expiry_Date  ,
              DPD_Limit_Expiry ,
              CASE 
                   WHEN ( Stock_Statement_valuation_date IS NULL
                     OR Stock_Statement_valuation_date = '01-01-1900' ) THEN ' '
              ELSE Stock_Statement_valuation_date
                 END Stock_Statement_valuation_date  ,
              DPD_Stock_Statement_expiry ,
              --[DPD_Stock Statement expiry],
              CASE 
                   WHEN ( Debit_Balance_Since_Date IS NULL
                     OR Debit_Balance_Since_Date = '01-01-1900' ) THEN ' '
              ELSE Debit_Balance_Since_Date
                 END Debit_Balance_Since_Date  ,
              CASE 
                   WHEN ( Last_Credit_Date IS NULL
                     OR Last_Credit_Date = '01-01-1900' ) THEN ' '
              ELSE Last_Credit_Date
                 END Last_Credit_Date  ,
              --case when [DPD_No Credit]<=60 then 0 else [DPD_No Credit]-60 end [DPD_No Credit],
              DPD_No_Credit ,
              Current_quarter_credit ,
              Current_quarter_interest ,
              Interest_Not_Serviced ,
              --[DPD_out of order],
              --[CC/OD Interest Service],
              --[Overdue Amount],[Overdue Date],a.DPD_Overdue,
              CASE 
                   WHEN NVL(Principal_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Principal_Overdue
                 END + CASE 
                            WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Overdue_Amount  ,
              --[Overdue Date],
              CASE 
                   WHEN ( Overdue_Date IS NULL
                     OR Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Overdue_Date
                 END Overdue_Date  ,
              --a.DPD_Overdue,
              DPD_Overdue ,
              CASE 
                   WHEN NVL(Principal_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Principal_Overdue
                 END Principal_Overdue  ,
              CASE 
                   WHEN ( UTILS.CONVERT_TO_NVARCHAR2(Principal_Overdue_Date,30,p_style=>105) IS NULL
                     OR UTILS.CONVERT_TO_NVARCHAR2(Principal_Overdue_Date,30,p_style=>105) = '01-01-1900'
                     OR Principal_Overdue_Date > v_DATE ) THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Principal_Overdue_Date,30,p_style=>105)
                 END Principal_Overdue_Date  ,
              DPD_Principal_Overdue ,
              --[Interest Overdue],[Interest Overdue Date],[DPD_Interest Overdue],
              --[Interest Overdue],
              CASE 
                   WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Interest_Overdue  ,
              --[Overdue Date],
              CASE 
                   WHEN ( UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105) IS NULL
                     OR UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105) = '01-01-1900'
                     OR Interest_Overdue_Date > v_DATE ) THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105)
                 END Interest_Overdue_Date  ,
              --a.DPD_Overdue,
              DPD_Interest_Overdue ,
              Other_OverDue ,
              CASE 
                   WHEN ( Other_OverDue_Date IS NULL
                     OR Other_OverDue_Date = '01-01-1900' ) THEN ' '
              ELSE Other_OverDue_Date
                 END Other_OverDue_Date  ,
              DPD_Other_Overdue ,
              --case when isnull(b.Balance,0)=0 then [Bill/PC Overdue Amount] else Balance end [Bill/PC Overdue Amount],
              CASE 
                   WHEN NVL(Principal_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Principal_Overdue
                 END + CASE 
                            WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Bill_PC_Overdue_Amount  ,
              -- case when isnull(BillRefNo,'')='' then [Overdue Bill/PC ID] else BillRefNo end [Overdue Bill/PC ID], 
              Overdue_Bill_PC_ID ,
              -- case when isnull(BillOverdueDt,'1900-01-01')='1900-01-01' then [Bill/PC Overdue Date] else BillOverdueDt end [Bill/PC Overdue Date] ,
              CASE 
                   WHEN UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105) = '01-01-1900' THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105)
                 END Bill_PC_Overdue_Date  ,
              -- case when isnull(b.dpd_Overdue,0)=0 then [DPD Bill/PC] else b.dpd_Overdue end as [DPD Bill/PC],
              DPD_Bill_PC ,
              Asset_Classification ,
              NPA_Norms 
       FROM tt_Final_OutputSCF a
              LEFT JOIN tt_TempDPD b   ON a.Account_No_ = b.CustomerAcID );
   OPEN  v_cursor FOR
      SELECT REPLACE(Report_date, '/', '-') Report_date  ,
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
             NPA_Norms 
        FROM OverdueReportPhase2  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--SELECT DISTINCT LEN([Overdue Bill/PC ID]) FROM  tt_Final_OutputSCF
   --	 SELECT DISTINCT LEN([Overdue Bill/PC ID]) FROM  tt_Final_Output
   --SELECT [Source System],COUNT(*) FROM #OverdueReportPhase2
   --GROUP BY [Source System]
   --SELECT [Source System],COUNT(*) FROM OverdueReportPhase2
   --GROUP BY [Source System]
   --SELECT * FROM #OverdueReportPhase2

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."OVERDUEREPORT_FINACLEANDECBF_PHASE2" TO "ADF_CDR_RBL_STGDB";
