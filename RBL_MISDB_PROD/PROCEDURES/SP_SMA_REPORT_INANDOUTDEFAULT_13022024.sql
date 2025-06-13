--------------------------------------------------------
--  DDL for Procedure SP_SMA_REPORT_INANDOUTDEFAULT_13022024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" 
AS
   ---------------------------------------Overdue Bill & PC Start--------------------------------------------------------
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
   v_PROCESSDATE VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  TIMEKEY = v_TIMEKEY );
   v_PrvDayTimekey NUMBER(10,0) := ( SELECT timekey - 1 
     FROM Automate_Advances 
    WHERE  EXT_FLG = 'Y' );
   v_cursor SYS_REFCURSOR;

 --accountwise
BEGIN

   -----------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempACCOUNTCAL_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempACCOUNTCAL_2 ';
   END IF;
   DELETE FROM tt_TempACCOUNTCAL_2;
   UTILS.IDENTITY_RESET('tt_TempACCOUNTCAL_2');

   INSERT INTO tt_TempACCOUNTCAL_2 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNTCAL 
   	 WHERE  FinalAssetClassAlt_Key = 1 );
   -------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_ACCOUNT_MOVEMENT_HISTORY_9') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_ACCOUNT_MOVEMENT_HISTORY_9 ';
   END IF;
   DELETE FROM tt_ACCOUNT_MOVEMENT_HISTORY_9;
   UTILS.IDENTITY_RESET('tt_ACCOUNT_MOVEMENT_HISTORY_9');

   INSERT INTO tt_ACCOUNT_MOVEMENT_HISTORY_9 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.ACCOUNT_MOVEMENT_HISTORY I
   	 WHERE  I.EffectiveFromTimeKey <= v_TIMEKEY
              AND I.EffectiveToTimeKey >= v_TIMEKEY );
   ------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempDPD_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempDPD_3 ';
   END IF;
   DELETE FROM tt_TempDPD_3;
   UTILS.IDENTITY_RESET('tt_TempDPD_3');

   INSERT INTO tt_TempDPD_3 ( 
   	SELECT b.UcifEntityID ,
           b.UCIF_ID ,
           b.CustomerEntityID ,
           b.RefCustomerID ,
           b.CustomerAcID ,
           b.Asset_Norm ,
           A.* 
   	  FROM tt_TempACCOUNTCAL_2 b
             LEFT JOIN PRO_RBL_MISDB_PROD.Accountcal_hist_DPD a   ON a.AccountEntityid = b.AccountEntityID
             AND a.TimeKey = v_Timekey );
   --where         b.FinalAssetClassAlt_Key=1

   EXECUTE IMMEDIATE ' ALTER TABLE tt_TempDPD_3 
      ADD ( [DPD_UCIF_ID NUMBER(10,0) , MAX_DPD_1 NUMBER(10,0) ] ) ';
   UPDATE tt_TempDPD_3
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
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMP_35 ';
   END IF;
   DELETE FROM tt_TEMP_35;
   UTILS.IDENTITY_RESET('tt_TEMP_35');

   INSERT INTO tt_TEMP_35 ( 
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
           b.REFPERIODOVERDUE NPA_Norms  
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN tt_TempACCOUNTCAL_2 B   ON A.CustomerEntityID = B.CustomerEntityID
           --and isnull(b.WriteOffAmount,0)=0

             LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
             AND ( src.EffectiveFromTimeKey <= v_Timekey
             AND src.EffectiveToTimeKey >= v_TimeKey )
             LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
             AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
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
   DELETE tt_TEMP_35

    WHERE  Scheme_Type = 'ODA'
             AND NPA_Norms = 91

             --AND           GREATEST(ISNULL(DPD_Overdrawn,0),ISNULL([DPD_No Credit],0)-60,ISNULL([DPD_Stock Statement expiry],0)-90,ISNULL([DPD_Limit Expiry],0)-90) <=0
             AND NVL(DPD_Overdrawn, 0) <= 0
             AND NVL(DPD_No_Credit, 0) - 60 <= 0
             AND NVL(DPD_Stock_Statement_expiry, 0) - 90 <= 0
             AND NVL(DPD_Limit_Expiry, 0) - 90 <= 0;
   DELETE tt_TEMP_35

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
   IF utils.object_id('TEMPDB..tt_TEMP_353') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3_5 ';
   END IF;
   DELETE FROM tt_temp3_5;
   UTILS.IDENTITY_RESET('tt_temp3_5');

   INSERT INTO tt_temp3_5 SELECT RefSystemAcid ,
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
        FROM AdvFacBillDetail 

      --where RefSystemAcid='0070AACB0100029'
      WHERE  EffectiveFromTimeKey <= v_Timekey
               AND EffectiveToTimeKey >= v_Timekey
               AND NVL(BALANCE, 0) > 0
               AND (CASE 
                         WHEN NVL(BILLDUEDT, '1900-01-01') > NVL(BillExtendedDueDt, '1900-01-01') THEN BillDueDt
             ELSE BillExtendedDueDt
                END) <= v_Date
        ORDER BY BillDueDt;
   IF utils.object_id('TEMPDB..tt_PC_OVERDUE_40') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_PC_OVERDUE_40 ';
   END IF;
   DELETE FROM tt_PC_OVERDUE_40;
   UTILS.IDENTITY_RESET('tt_PC_OVERDUE_40');

   INSERT INTO tt_PC_OVERDUE_40 ( 
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
   	  FROM RBL_MISDB_PROD.AdvFacPCDetail 
   	 WHERE  EFFECTIVEFROMTIMEKEY <= v_Timekey
              AND EFFECTIVETOTIMEKEY >= v_Timekey
              AND NVL(BALANCE, 0) > 0
              AND (CASE 
                        WHEN NVL(PCDueDt, '1900-01-01') > NVL(PCExtendedDueDt, '1900-01-01') THEN PCDueDt
            ELSE PCExtendedDueDt
               END) <= v_Date );
   ------------------------------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Final_Output_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_Output_3 ';
   END IF;
   DELETE FROM tt_Final_Output_3;
   UTILS.IDENTITY_RESET('tt_Final_Output_3');

   INSERT INTO tt_Final_Output_3 ( 
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
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN 0
                    ELSE A."Overdue Amount"
                       END Overdue_Amount  ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A."Overdue Date"
                       END Overdue_Date  ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN 0
                    ELSE A."Interest Overdue"
                       END Interest_Overdue  ,
                    CASE 
                         WHEN A."Scheme Type" = 'ODA'
                           AND A."NPA Norms" = 91 THEN ' '
                    ELSE A."Interest Overdue Date"
                       END Interest_Overdue_Date  ,
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
             FROM tt_TEMP_35 a
                    LEFT JOIN tt_temp3_5 b   ON a.Account_No_ = b.RefSystemAcid
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
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Overdue_Amount
                       END Overdue_Amount  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Overdue_Date
                       END Overdue_Date  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Interest_Overdue
                       END Interest_Overdue  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Interest_Overdue_Date
                       END Interest_Overdue_Date  ,
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
             FROM tt_TEMP_35 a
                    LEFT JOIN tt_PC_OVERDUE_40 b   ON a.Account_No_ = b.RefSystemAcid
              WHERE  Scheme_Type = 'PCA'
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
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Overdue_Amount
                       END Overdue_Amount  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Overdue_Date
                       END Overdue_Date  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Overdue
                       END DPD_Overdue  ,
                    Principal_Overdue ,
                    Principal_Overdue_Date ,
                    DPD_Principal_Overdue ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN 0
                    ELSE a.Interest_Overdue
                       END Interest_Overdue  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.Interest_Overdue_Date
                       END Interest_Overdue_Date  ,
                    CASE 
                         WHEN a.Scheme_Type = 'ODA'
                           AND a.NPA_Norms = 91 THEN ' '
                    ELSE a.DPD_Interest_Overdue
                       END DPD_Interest_Overdue  ,
                    Other_OverDue ,
                    Other_OverDue_Date ,
                    DPD_Other_Overdue ,
                    Bill_PC_Overdue_Amount ,
                    Overdue_Bill_PC_ID ,
                    Bill_PC_Overdue_Date ,
                    DPD_Bill_PC ,
                    Asset_Classification ,
                    NPA_Norms 
             FROM tt_TEMP_35 a
              WHERE  ( Scheme_Type NOT IN ( 'PCA','FBA' )

                       OR Scheme_Type IS NULL ) ) BB );
   IF utils.object_id('TEMPDB..#TEMPSCF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPSCF_3 ';
   END IF;
   DELETE FROM tt_TEMPSCF_3;
   UTILS.IDENTITY_RESET('tt_TEMPSCF_3');

   INSERT INTO tt_TEMPSCF_3 ( 
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
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode IN ( '777','780' )
                 THEN 'Retail'
                WHEN SourceName = 'VisionPlus'
                  AND b.ProductCode NOT IN ( '777','780' )
                 THEN 'Credit Card'
           ELSE AcBuRevisedSegmentCode
              END Business_Segment  ,
           DPD_Max Account_DPD  ,
           b.Balance Outstanding  ,
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
           b.REFPERIODOVERDUE NPA_Norms  
   	  FROM PRO_RBL_MISDB_PROD.CUSTOMERCAL A
             JOIN tt_TempACCOUNTCAL_2 B   ON A.CustomerEntityID = B.CustomerEntityID
           --and isnull(b.WriteOffAmount,0)=0

             JOIN CurDat_RBL_MISDB_PROD.AdvFacBillDetail FB   ON b.AccountEntityID = FB.AccountEntityId
             AND FB.BillNatureAlt_Key = 9
             LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
             AND ( src.EffectiveFromTimeKey <= v_Timekey
             AND src.EffectiveToTimeKey >= v_TimeKey )
             LEFT JOIN DimProduct PD   ON PD.EffectiveToTimeKey = 49999
             AND PD.ProductAlt_Key = b.PRODUCTALT_KEY
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
   DELETE tt_TEMPSCF_3

    WHERE  Scheme_Type = 'ODA'
             AND NPA_Norms = 91

             --AND           GREATEST(ISNULL(DPD_Overdue,0),ISNULL([DPD_Limit Expiry],0)-90) <=0
             AND NVL(DPD_Overdue, 0) <= 0
             AND NVL(DPD_Limit_Expiry, 0) - 90 <= 0;
   ---------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TEMP_353SCF') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_temp3SCF_3 ';
   END IF;
   DELETE FROM tt_temp3SCF_3;
   UTILS.IDENTITY_RESET('tt_temp3SCF_3');

   INSERT INTO tt_temp3SCF_3 SELECT RefSystemAcid ,
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
        FROM AdvFacBillDetail 

      --where RefSystemAcid='0070AACB0100029'
      WHERE  EffectiveFromTimeKey <= v_Timekey
               AND EffectiveToTimeKey >= v_Timekey
               AND NVL(BALANCE, 0) > 0
               AND BillNatureAlt_Key = 9
               AND (CASE 
                         WHEN NVL(BILLDUEDT, '9999-01-01') < NVL(InterestOverdueDate, '9999-01-01') THEN BillDueDt
             ELSE InterestOverdueDate
                END) <= v_Date
        ORDER BY BillDueDt;
   -----------------------------------------------------------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_Final_Output_3SCF') IS NOT NULL THEN
    -----------------------------------------------------------------------------------------------------------------------------
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_Final_OutputSCF_3 ';
   END IF;
   DELETE FROM tt_Final_OutputSCF_3;
   UTILS.IDENTITY_RESET('tt_Final_OutputSCF_3');

   INSERT INTO tt_Final_OutputSCF_3 ( 
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
                    DPD_No_Credit ,
                    Current_quarter_credit ,
                    Current_quarter_interest ,
                    Interest_Not_Serviced ,
                    A."Overdue Amount" ,
                    A."Overdue Date" ,
                    A.DPD_Overdue ,
                    b.princOverDue_Amount Principal_Overdue  ,
                    b.princOverDueDate Principal_Overdue_Date  ,
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
                    OverdueInterest1 Interest_Overdue  ,
                    InterestOverdueDate1 Interest_Overdue_Date  ,
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
   	  FROM tt_TEMPSCF_3 a
             LEFT JOIN tt_temp3SCF_3 b   ON a.Account_No_ = b.RefSystemAcid );
   EXECUTE IMMEDIATE ' TRUNCATE TABLE OverdueReportPhase2 ';
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
              A.Asset_Norm ,
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
              A.DPD_Overdrawn ,
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
              DPD_No_Credit ,
              Current_quarter_credit ,
              Current_quarter_interest ,
              Interest_Not_Serviced ,
              Overdue_Amount ,
              CASE 
                   WHEN ( Overdue_Date IS NULL
                     OR Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Overdue_Date
                 END Overdue_Date  ,
              A.DPD_Overdue ,
              Principal_Overdue ,
              CASE 
                   WHEN ( Principal_Overdue_Date IS NULL
                     OR Principal_Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Principal_Overdue_Date
                 END Principal_Overdue_Date  ,
              DPD_Principal_Overdue ,
              Interest_Overdue ,
              CASE 
                   WHEN ( Interest_Overdue_Date IS NULL
                     OR Interest_Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Interest_Overdue_Date
                 END Interest_Overdue_Date  ,
              DPD_Interest_Overdue ,
              Other_OverDue ,
              CASE 
                   WHEN ( Other_OverDue_Date IS NULL
                     OR Other_OverDue_Date = '01-01-1900' ) THEN ' '
              ELSE Other_OverDue_Date
                 END Other_OverDue_Date  ,
              DPD_Other_Overdue ,
              Bill_PC_Overdue_Amount ,
              Overdue_Bill_PC_ID ,
              CASE 
                   WHEN UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105) = '01-01-1900' THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105)
                 END Bill_PC_Overdue_Date  ,
              DPD_Bill_PC ,
              Asset_Classification ,
              NPA_Norms 
       FROM tt_Final_Output_3 a
              JOIN tt_TempDPD_3 b   ON a.Account_No_ = b.CustomerAcID

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
              a.Asset_Norm ,
              Segment_Description ,
              Business_Segment ,
              b.MAX_DPD_1 Account_DPD  ,
              Outstanding ,
              Principal_Outstanding ,
              Drawing_Power ,
              Sanction_Limit ,
              OverDrawn_Amount ,
              a.DPD_Overdrawn ,
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
              DPD_No_Credit ,
              Current_quarter_credit ,
              Current_quarter_interest ,
              Interest_Not_Serviced ,
              CASE 
                   WHEN NVL(Principal_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Principal_Overdue
                 END + CASE 
                            WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Overdue_Amount  ,
              CASE 
                   WHEN ( Overdue_Date IS NULL
                     OR Overdue_Date = '01-01-1900' ) THEN ' '
              ELSE Overdue_Date
                 END Overdue_Date  ,
              a.DPD_Overdue ,
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
              CASE 
                   WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Interest_Overdue  ,
              CASE 
                   WHEN ( UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105) IS NULL
                     OR UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105) = '01-01-1900'
                     OR Interest_Overdue_Date > v_DATE ) THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Interest_Overdue_Date,30,p_style=>105)
                 END Interest_Overdue_Date  ,
              DPD_Interest_Overdue ,
              Other_OverDue ,
              CASE 
                   WHEN ( Other_OverDue_Date IS NULL
                     OR Other_OverDue_Date = '01-01-1900' ) THEN ' '
              ELSE Other_OverDue_Date
                 END Other_OverDue_Date  ,
              DPD_Other_Overdue ,
              CASE 
                   WHEN NVL(Principal_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Principal_Overdue
                 END + CASE 
                            WHEN NVL(Interest_Overdue_Date, '1900-01-01') > v_Date THEN 0
              ELSE Interest_Overdue
                 END Bill_PC_Overdue_Amount  ,
              Overdue_Bill_PC_ID ,
              CASE 
                   WHEN UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105) = '01-01-1900' THEN ' '
              ELSE UTILS.CONVERT_TO_NVARCHAR2(Bill_PC_Overdue_Date,30,p_style=>105)
                 END Bill_PC_Overdue_Date  ,
              DPD_Bill_PC ,
              Asset_Classification ,
              NPA_Norms 
       FROM tt_Final_OutputSCF_3 a
              LEFT JOIN tt_TempDPD_3 b   ON a.Account_No_ = b.CustomerAcID );
   ---------------------------------------Overdue Bill & PC END--------------------------------------------------------
   ---------------------------------------Investment Start--------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempInvestment_3') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempInvestment_3 ';
   END IF;
   DELETE FROM tt_TempInvestment_3;
   UTILS.IDENTITY_RESET('tt_TempInvestment_3');

   INSERT INTO tt_TempInvestment_3 ( 
   	SELECT DISTINCT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Process_Date  ,
                    B.BRANCHCODE ,
                    ISSUERID ,
                    ISSUERNAME ,
                    REF_TXN_SYS_CUST_ID ,
                    ISSUER_CATEGORY_CODE ,
                    UCIFID ,
                    PANNO ,
                    SUBSTR(INVID, 1, INSTR(INVID, '_') - 1) INVID  ,
                    b.ISIN ,
                    I.InstrumentTypeName ,
                    INSTRNAME ,
                    b.INVESTMENTNATURE ,
                    EXPOSURETYPE ,
                    MATURITYDT ,
                    HOLDINGNATURE ,
                    BOOKTYPE ,
                    BOOKVALUE ,
                    MTMVALUE ,
                    INTEREST_DIVIDENDDUEDATE ,
                    INTEREST_DIVIDENDDUEAMOUNT ,
                    DPD ,
                    FLGDEG ,
                    DEGREASON ,
                    (CASE 
                          WHEN AC.AssetClassShortName <> 'STD' THEN 'N'
                    ELSE FLGUPG
                       END) FLGUPG  ,
                    (CASE 
                          WHEN AC.AssetClassShortName <> 'STD' THEN NULL
                    ELSE UPGDATE
                       END) UPGDATE  ,
                    TOTALPROVISON ,
                    AC.AssetClassShortName ASSETCLASS  ,
                    C.PartialRedumptionDueDate ,
                    c.PartialRedumptionSettledY_N ,
                    c.NPIDt ,
                    c.BalanceSheetDate ,
                    c.ListedShares ,
                    c.DPD_BS_Date ,
                    c.BookValueINR ,
                    C.DPD_DivOverdue ,
                    C.DPD_Maturity ,
                    C.PartialRedumptionDPD 
   	  FROM InvestmentIssuerDetail a
             JOIN InvestmentBasicDetail B   ON A.IssuerEntityId = B.IssuerEntityId
             AND a.EffectiveFromTimeKey <= v_TimeKey
             AND a.EffectiveToTimeKey >= v_TimeKey
             AND b.EffectiveFromTimeKey <= v_TimeKey
             AND b.EffectiveToTimeKey >= v_TimeKey
             JOIN InvestmentFinancialDetail c   ON b.InvEntityId = c.InvEntityId
             AND c.EffectiveFromTimeKey <= v_TimeKey
             AND c.EffectiveToTimeKey >= v_TimeKey
             JOIN DimAssetClass AC   ON AC.EffectiveFromTimeKey <= v_TimeKey
             AND C.EffectiveToTimeKey >= v_TimeKey
             AND AC.AssetClassAlt_Key = C.FinalAssetClassAlt_Key
             LEFT JOIN DimInstrumentType I   ON I.EffectiveFromTimeKey <= v_TimeKey
             AND I.EffectiveToTimeKey >= v_TimeKey
             AND B.InstrTypeAlt_Key = I.InstrumentTypeAlt_Key
   	 WHERE  c.FinalAssetClassAlt_Key = 1 );
   ---------------------------------------Investment END--------------------------------------------------------
   ---------------------------------------In & Out Default Start -----------------------------------------------------
   IF utils.object_id('TEMPDB..tt_TempDefault_2') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TempDefault_2 ';
   END IF;
   DELETE FROM tt_TempDefault_2;
   UTILS.IDENTITY_RESET('tt_TempDefault_2');

   INSERT INTO tt_TempDefault_2 ( 
   	SELECT A.AccountEntityID ,
           SMA_Class ,
           SMA_Dt ,
           FlgSMA ,
           DPD_SMA ,
           SMA_Reason ,
           b.DPD_MAX ,
           b.DPD_IntOverdueSince ,
           b.DPD_IntService ,
           b.DPD_NoCredit ,
           b.DPD_OtherOverdueSince ,
           b.DPD_Overdrawn ,
           b.DPD_PrincOverdue ,
           b.DPD_Overdue 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist a
             LEFT JOIN PRO_RBL_MISDB_PROD.Accountcal_hist_DPD b   ON a.AccountEntityID = b.AccountEntityid
   	 WHERE  a.EffectiveFromTimeKey <= v_PrvDayTimekey
              AND a.EffectiveToTimeKey >= v_PrvDayTimekey
              AND b.TimeKey = v_PrvDayTimekey
              AND a.FinalAssetClassAlt_Key = 1 );
   UPDATE tt_TempDefault_2
      SET DPD_MAX = 0
    WHERE  DPD_MAX IS NULL;
   UPDATE tt_TempDefault_2
      SET DPD_IntOverdueSince = 0
    WHERE  DPD_IntOverdueSince IS NULL;
   UPDATE tt_TempDefault_2
      SET DPD_IntService = 0
    WHERE  DPD_IntService IS NULL;
   UPDATE tt_TempDefault_2
      SET DPD_NoCredit = 0
    WHERE  DPD_NoCredit IS NULL;
   UPDATE tt_TempDefault_2
      SET DPD_OtherOverdueSince = 0
    WHERE  DPD_OtherOverdueSince IS NULL;
   UPDATE tt_TempDefault_2
      SET DPD_Overdrawn = 0
    WHERE  DPD_Overdrawn IS NULL;
   UPDATE tt_TempDefault_2
      SET DPD_PrincOverdue = 0
    WHERE  DPD_PrincOverdue IS NULL;
   UPDATE tt_TempDefault_2
      SET DPD_Overdue = 0
    WHERE  DPD_Overdue IS NULL;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 'FDOD'
   FROM A ,tt_TempACCOUNTCAL_2 a
          JOIN DimProduct b   ON a.ProductAlt_Key = b.ProductAlt_Key 
    WHERE a.FinalAssetClassAlt_Key = 1
     AND b.ProductGroup = 'FDSEC') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET a.SMA_Class = 'FDOD';
   UPDATE tt_TempACCOUNTCAL_2
      SET SMA_Class = 'Agri-Loan'
    WHERE  FinalAssetClassAlt_Key = 1
     AND RefPeriodOverdue > 91;
   -----------------------------InDefault----------------------------------------------
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_TempACCOUNTCAL_2 a
               JOIN tt_TempDefault_2 b   ON a.AccountEntityID = b.AccountEntityID
       WHERE  a.SMA_Class IN ( 'SMA_0','SMA_1','SMA_2' )

                AND B.SMA_Class = 'STD' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   -----------------------------OutDefault----------------------------------------------
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_TempACCOUNTCAL_2 a
               JOIN tt_TempDefault_2 b   ON a.AccountEntityID = b.AccountEntityID
       WHERE  B.SMA_Class IN ( 'SMA_0','SMA_1','SMA_2' )

                AND A.SMA_Class = 'STD' ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   ---------------------------------------In & Out Default End--------------------------------------------------------
   ---------------------------------------SMA Report Start-------------------------------------------------------------
   --DECLARE @TIMEKEY INT=(select timekey from Automate_Advances where Ext_flg = 'y')
   --DECLARE @TIMEKEY INT='26479'
   --select * from Automate_Advances where date='2022-06-30'
   ---972953
   ----------======================================DPD Calculation Start===========================================
   --Drop table if exists   #DPD 
   --	IF OBJECT_ID('TEMPDB..#DPD') IS NOT NULL
   --DROP TABLE  #DPD
   --select AccountEntityID,UcifEntityID,CustomerEntityID,CustomerAcID,
   --RefCustomerID,SourceSystemCustomerID,UCIF_ID,IntNotServicedDt,LastCrDate,ContiExcessDt,OverDueSinceDt,ReviewDueDt,StockStDt,
   --RefPeriodIntService,RefPeriodNoCredit,RefPeriodOverDrawn,RefPeriodOverdue,RefPeriodReview,RefPeriodStkStatement,SourceAlt_Key,DebitSinceDt,Asset_Norm
   -- INTO #DPD 
   -- from  PRO.AccountCal_Hist where EffectiveFromTimeKey<=@TimeKey and EffectiveToTimeKey>=@TimeKey
   -- and FinalAssetClassAlt_Key=1 -----added by Prashant for only standard account
   --ALTER Table #DPD
   --ADD DPD_IntService INT,DPD_NoCredit INT,DPD_Overdrawn INT,DPD_Overdue INT,DPD_Renewal INT,DPD_StockStmt INT
   --,DPD_MAX INT,DPD_UCIF_ID INT,DPD_PrincOverdue INT,DPD_IntOverdueSince INT,DPD_OtherOverdueSince INT
   /*
   -----------------------------------

   if @TIMEKEY >26267  ----IMPLEMENTED FROM 2021-12-01 
   	BEGIN
   		UPDATE A SET  A.DPD_IntService =CASE WHEN @TIMEKEY >26384  --28032022 amar - implemmented 90 days summation ccod credit and intt logic
   												THEN	
   													(CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+2  ELSE 0 END)
   												ELSE
   													(CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)+1  ELSE 0 END)
   											END

   	---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)
   					 ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>90)
   													THEN (CASE WHEN  A.LastCrDate IS NOT NULL THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)+1 ELSE 0 END)
   											ELSE 0 END
   					 ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END) 

   					 ,A.DPD_Overdue =  CASE WHEN @TIMEKEY >26372	
   													------ AMAR - CHANGES ON 17032021 AS PER EMAIL BY ASHISH SIR DATED - 17-03-2021 1:59 PM - SUBJECT - Credit Card NPA Computation  -- 
   												THEN (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+1 ELSE 0 END) 
   											ELSE 
   													 (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)+(CASE WHEN SourceAlt_Key=6 THEN 0 ELSE 1 END )  ELSE 0 END) 
   											END
   					 ,A.DPD_Renewal =  (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)  +1    ELSE 0 END)
   					 ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate) +1     ELSE 0 END)
   					 ,A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,Process_Date)+1  ELSE 0 END)			   
                ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  Process_Date)+1       ELSE 0 END)
   			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  Process_Date)+1  ELSE 0 END) 


   		FROM #DPD A 
   	END
   ELSE
   	BEGIN
   		UPDATE A SET  A.DPD_IntService = (CASE WHEN  A.IntNotServicedDt IS NOT NULL THEN DATEDIFF(DAY,A.IntNotServicedDt,@ProcessDate)  ELSE 0 END)			   
   					---             ,A.DPD_NoCredit =  (CASE WHEN  A.LastCrDate IS NOT NULL      THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)       ELSE 0 END)
   					 ,A.DPD_NoCredit = CASE WHEN (DebitSinceDt IS NULL OR DATEDIFF(DAY,DebitSinceDt,@ProcessDate)>90)
   													THEN (CASE WHEN  A.LastCrDate IS NOT NULL THEN DATEDIFF(DAY,A.LastCrDate,  @ProcessDate)  ELSE 0 END)
   											ELSE 0 END
   					 ,A.DPD_Overdrawn= (CASE WHEN   A.ContiExcessDt IS NOT NULL    THEN DATEDIFF(DAY,A.ContiExcessDt,  @ProcessDate) + 1    ELSE 0 END) 
   					 ,A.DPD_Overdue =   (CASE WHEN  A.OverDueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OverDueSinceDt,  @ProcessDate)  ELSE 0 END) 
   					 ,A.DPD_Renewal =   (CASE WHEN  A.ReviewDueDt IS NOT NULL      THEN DATEDIFF(DAY,A.ReviewDueDt, @ProcessDate)      ELSE 0 END)
   					 ,A.DPD_StockStmt= (CASE WHEN  A.StockStDt IS NOT NULL         THEN   DATEDIFF(DAY,A.StockStDt,@ProcessDate)     ELSE 0 END)
   			 ,A.DPD_PrincOverdue = (CASE WHEN  A.PrincOverdueSinceDt IS NOT NULL THEN DATEDIFF(DAY,A.PrincOverdueSinceDt,Process_Date)+1  ELSE 0 END)			   
                ,A.DPD_IntOverdueSince =  (CASE WHEN  A.IntOverdueSinceDt IS NOT NULL      THEN DATEDIFF(DAY,A.IntOverdueSinceDt,  Process_Date)+1       ELSE 0 END)
   			 ,A.DPD_OtherOverdueSince =   (CASE WHEN  A.OtherOverdueSinceDt IS NOT NULL   THEN  DATEDIFF(DAY,A.OtherOverdueSinceDt,  Process_Date)+1  ELSE 0 END) 


   		FROM #DPD A 
   	end
   */
   ----/*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_TempDPD_3
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_TempDPD_3
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_TempDPD_3
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_TempDPD_3
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_TempDPD_3
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_TempDPD_3
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_TempDPD_3 A 
    WHERE NVL(DPD_Overdrawn, 0) <= 30) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET DPD_Overdrawn = 0;
   UPDATE tt_TempDPD_3
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_TempDPD_3
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_TempDPD_3
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   ----	/*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_TempDPD_3 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0, 0, 0, 0, 0
   FROM A ,tt_TempDPD_3 A 
    WHERE Asset_Norm = 'ALWYS_STD') src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET DPD_Overdrawn = 0,
                                DPD_Overdue = 0,
                                DPD_IntService = 0,
                                DPD_NoCredit = 0,
                                DPD_Renewal = 0;
   ----		/*----------------FIND MAX DPD---------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN NVL(A.DPD_Overdrawn, 0) > NVL(A.DPD_Overdue, 0) THEN NVL(A.DPD_Overdrawn, 0)
   ELSE NVL(A.DPD_Overdue, 0)
      END) AS DPD_Max
   FROM A ,tt_TempDPD_3 a 
    WHERE ( NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0 )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   TABLE IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DPD_UCIF_ID_20  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DPD_UCIF_ID_20;
   UTILS.IDENTITY_RESET('tt_DPD_UCIF_ID_20');

   INSERT INTO tt_DPD_UCIF_ID_20 ( 
   	SELECT UCIF_ID ,
           MAX(DPD_MAX)  DPD_UCIF_ID  
   	  FROM tt_TempDPD_3 
   	  GROUP BY UCIF_ID );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.DPD_UCIF_ID
   FROM A ,tt_TempDPD_3 A
          JOIN tt_DPD_UCIF_ID_20 B   ON A.UCIF_ID = B.UCIF_ID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_UCIF_ID = src.DPD_UCIF_ID;
   --Truncate table SMA_OUTPUT
   --Insert into SMA_OUTPUT
   OPEN  v_cursor FOR
      SELECT v_PROCESSDATE Report_Date  ,
             --,ROW_NUMBER()Over(Order by A.UcifEntityId) SrNo
             ---------RefColumns---------
             A.UCIF_ID ,
             A.RefCustomerID CustomerID  ,
             F.CustomerName ,
             A.BranchCode ,
             br.BranchName ,
             br.BranchStateName ,
             br.BranchRegion ,
             A.CustomerAcID ,
             F.PANNO ,
             H.SourceName ,
             A.FacilityType ,
             SchemeType ,
             A.ProductCode ,
             C.ProductName ,
             A.ActSegmentCode Seg_Code  ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus'
                    AND A.ProductCode IN ( '777','780' )
                   THEN 'Retail'
                  WHEN SourceName = 'VisionPlus'
                    AND A.ProductCode NOT IN ( '777','780' )
                   THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END Segment_Description  ,
             CASE 
                  WHEN SourceName = 'FIS' THEN 'FI'
                  WHEN SourceName = 'VisionPlus'
                    AND A.ProductCode IN ( '777','780' )
                   THEN 'Retail'
                  WHEN SourceName = 'VisionPlus'
                    AND A.ProductCode NOT IN ( '777','780' )
                   THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END Business_Segment  ,
             CASE 
                  WHEN AcBuRevisedSegmentCode IN ( 'Retail','WCF','Agri-Retail','FI','MSME','SCF','Credit Card' )
                   THEN 'Retail'
                  WHEN AcBuRevisedSegmentCode IN ( 'CIB','FIG','Agri-Wholesale','MC','CB','SME','Treasury' )
                   THEN 'Wholesale'
             ELSE AcBuRevisedSegmentCode
                END Wholesale_Retail  ,
             CASE 
                  WHEN NVL(A.Balance, 0) <= 0 THEN 0
             ELSE NVL(A.Balance, 0)
                END Balance  ,
             CASE 
                  WHEN NVL(A.PrincOutStd, 0) <= 0 THEN 0
             ELSE NVL(A.PrincOutStd, 0)
                END PrincOutStd  ,
             A.DrawingPower ,
             NVL(A.CurrentLimit, 0) CurrentLimit  ,
             CASE 
                  WHEN SourceName = 'Finacle'
                    AND SchemeType = 'ODA' THEN (CASE 
                                                      WHEN (NVL(A.Balance, 0) - (CASE 
                                                                                      WHEN NVL(A.DrawingPower, 0) < NVL(A.CurrentLimit, 0) THEN NVL(A.DrawingPower, 0)
                                                      ELSE NVL(A.CurrentLimit, 0)
                                                         END)) <= 0 THEN 0
                  ELSE NVL(A.Balance, 0) - (CASE 
                                                 WHEN NVL(A.DrawingPower, 0) < NVL(A.CurrentLimit, 0) THEN NVL(A.DrawingPower, 0)
                  ELSE NVL(A.CurrentLimit, 0)
                     END)
                     END)
             ELSE 0
                END OverDrawn_Amount  ,
             DPD.DPD_Overdrawn ,
             --,a.ContiExcessDt as [Limit/DP Overdrawn Date]
             UTILS.CONVERT_TO_VARCHAR2(A.ContiExcessDt,10,p_style=>103) Limit_DP_Overdrawn_Date  ,
             NVL(A.OverdueAmt, 0) OverdueAmt  ,
             UTILS.CONVERT_TO_VARCHAR2(A.OverDueSinceDt,10,p_style=>103) OverDueSinceDt  ,
             DPD.DPD_Overdue ,
             OP2.Bill_PC_Overdue_Amount ,
             OP2.Overdue_Bill_PC_ID ,
             --,[Bill/PC Overdue Date]
             UTILS.CONVERT_TO_NVARCHAR2(UTILS.CONVERT_TO_VARCHAR2(OP2.Bill_PC_Overdue_Date,200,p_style=>105),10,p_style=>23) Bill_PC_Overdue_Date  ,
             OP2.DPD_Bill_PC ,
             NULL INTEREST_DIVIDENDDUEDATE  ,
             NULL INTEREST_DIVIDENDDUEAMOUNT  ,
             NULL DPD  ,
             NULL PartialRedumptionDueDate  ,
             DPD.DPD_MAX SMA_DPD  ,
             A.FlgSMA AccountFlgSMA  ,
             A.SMA_Dt AccountSMA_Dt  ,
             A.SMA_Class AccountSMA_AssetClass  ,
             A.SMA_Reason SMA_Reason  ,
             DPD.DPD_UCIF_ID ,
             F.FlgSMA UCICFlgSMA  ,
             F.SMA_Dt UCICSMA_Dt  ,
             F.CustMoveDescription UCICSMA_AssetStatus  ,
             F.SMA_Dt SMA_Classification_Date  ,
             NULL in_default_Y_N_  ,
             NULL in_default_date  ,
             NULL out_of_default_Y_N_  ,
             NULL out_of_default_date  ,
             CASE 
                  WHEN A.FlgSMA = 'Y' THEN NULL
             ELSE I.MovementFromDate
                END MovementFromDate  ,
             CASE 
                  WHEN A.FlgSMA = 'Y' THEN NULL
             ELSE I.MovementFromStatus
                END MovementFromStatus  ,
             CASE 
                  WHEN A.FlgSMA = 'Y' THEN NULL
             ELSE I.MovementToStatus
                END MovementToStatus  ,
             A.Asset_Norm ,
             A.REFPERIODOVERDUE NPA_Norms  ,
             NULL Credit_FB_Exposure  ,
             NULL Credit_NFB_Exposure  ,
             NULL Non_SLR  ,
             NULL LER  ,
             NULL Total_Exposure  ,
             NULL Exposure_5crore_above_Flag  ,
             NULL FDOD_Flag  ,
             UTILS.CONVERT_TO_VARCHAR2(A.ReviewDueDt,10,p_style=>103) Limit_Expiry_Date  ,
             DPD.DPD_Renewal DPD_Limit_Expiry  ,
             UTILS.CONVERT_TO_VARCHAR2(A.StockStDt,10,p_style=>103) Stock_Statement_valuation_date  ,
             DPD.DPD_StockStmt ,
             UTILS.CONVERT_TO_VARCHAR2(A.DebitSinceDt,10,p_style=>103) Debit_Balance_Since_Date  ,
             UTILS.CONVERT_TO_VARCHAR2(A.LastCrDate,10,p_style=>103) Last_Credit_Date  ,
             DPD.DPD_NoCredit ,
             A.CurQtrCredit Current_quarter_credit  ,
             A.CurQtrInt Current_quarter_interest  ,
             (CASE 
                   WHEN (CurQtrInt - CurQtrCredit) < 0 THEN 0
             ELSE (CurQtrInt - CurQtrCredit)
                END) Interest_Not_Serviced  ,
             DPD.DPD_IntService DPD_out_of_order  ,
             UTILS.CONVERT_TO_VARCHAR2(A.IntNotServicedDt,10,p_style=>103) CC_OD_Interest_Service  ,
             NVL(A.PrincOverdue, 0) PrincOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(A.PrincOverdueSinceDt,10,p_style=>103) Principal_Overdue_Date  ,
             DPD.DPD_PrincOverdue DPD_Principal_Overdue  ,
             NVL(A.IntOverdue, 0) IntOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(A.IntOverdueSinceDt,10,p_style=>103) Interest_Overdue_Date  ,
             DPD.DPD_IntOverdueSince DPD_Interest_Overdue  ,
             NVL(A.OtherOverdue, 0) OtherOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(A.OtherOverdueSinceDt,10,p_style=>103) Other_OverDue_Date  ,
             DPD.DPD_OtherOverdueSince DPD_Other_Overdue  

        --From Pro.AccountCal_hist A
        FROM tt_TempACCOUNTCAL_2 A
               JOIN DimProduct C   ON C.ProductAlt_Key = A.ProductAlt_Key
               AND A.EFFECTIVEFROMTIMEKEY <= v_TIMEKEY
               AND A.EFFECTIVETOTIMEKEY >= v_TIMEKEY
               AND C.EffectiveFromTimeKey <= v_TIMEKEY
               AND C.EffectiveToTimeKey >= v_TIMEKEY
               JOIN DimAssetClass D   ON D.AssetClassAlt_Key = A.InitialAssetClassAlt_Key
               AND D.EffectiveFromTimeKey <= v_TIMEKEY
               AND D.EffectiveToTimeKey >= v_TIMEKEY
               JOIN DimAssetClass E   ON E.AssetClassAlt_Key = A.FinalAssetClassAlt_Key
               AND E.EffectiveFromTimeKey <= v_TIMEKEY
               AND E.EffectiveToTimeKey >= v_TIMEKEY
             --INNER JOIN Pro.CustomerCal_hist F On F.CustomerEntityId=A.CustomerEntityId

               JOIN PRO_RBL_MISDB_PROD.CUSTOMERCAL F   ON F.CustomerEntityId = A.CustomerEntityId
               AND F.EffectiveFromTimeKey <= v_TIMEKEY
               AND F.EffectiveToTimeKey >= v_TIMEKEY
               JOIN SysDayMatrix G   ON A.EffectiveFromTimekey = G.TimeKey
               JOIN DIMSOURCEDB H   ON H.SourceAlt_Key = A.SourceAlt_Key
               AND H.EffectiveFromTimeKey <= v_TIMEKEY
               AND H.EffectiveToTimeKey >= v_TIMEKEY
               LEFT JOIN tt_TempDPD_3 DPD   ON DPD.AccountEntityid = A.AccountEntityID
               LEFT JOIN tt_ACCOUNT_MOVEMENT_HISTORY_9 I   ON I.CustomerAcID = A.CustomerAcID
               AND I.EffectiveFromTimeKey <= v_TIMEKEY
               AND I.EffectiveToTimeKey >= v_TIMEKEY
               LEFT JOIN DimAcBuSegment S   ON A.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveFromTimeKey <= v_TIMEKEY
               AND S.EffectiveToTimeKey >= v_TIMEKEY
               LEFT JOIN DimBranch BR   ON A.BranchCode = br.BranchCode
               AND br.EffectiveFromTimeKey <= v_TIMEKEY
               AND br.EffectiveToTimeKey >= v_TIMEKEY
               LEFT JOIN OverdueReportPhase2 OP2   ON OP2.Account_No_ = A.CustomerAcID
       WHERE  A.FinalAssetClassAlt_Key = 1
                AND F.FlgSMA = 'Y'
      UNION 

      --order by A.UcifEntityID,A.RefCustomerID

      --select * from investment_data
      SELECT v_PROCESSDATE Report_Date  ,
             --,ROW_NUMBER()Over(Order by A.UcifEntityId) SrNo
             ---------RefColumns---------
             UCIFID UCIF_ID  ,
             REF_TXN_SYS_CUST_ID CustomerID  ,
             b.CustomerName ,
             A.BRANCHCODE ,
             c.BranchName ,
             c.BranchStateName ,
             c.BranchRegion ,
             INVID CustomerAcID  ,
             PANNO ,
             'Calypso' SourceName  ,
             NULL FacilityType  ,
             NULL SchemeType  ,
             NULL ProductCode  ,
             NULL ProductName  ,
             NULL Seg_Code  ,
             --,CASE WHEN SourceName='FIS' THEN 'FI'
             --		  WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
             --		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
             --		else AcBuSegmentDescription end as [Segment Description]
             NULL Segment_Description  ,
             --,CASE WHEN SourceName='FIS' THEN 'FI'  
             --	WHEN SourceName='VisionPlus' and a.ProductCode in ('777','780') THEN 'Retail'
             --		  WHEN SourceName='VisionPlus' and a.ProductCode not in ('777','780') THEN 'Credit Card'
             --  else AcBuRevisedSegmentCode end [Business Segment] 
             NULL Business_Segment  ,
             --,CASE WHEN AcBuRevisedSegmentCode in ('Retail','WCF','Agri-Retail','FI','MSME','SCF','Credit Card')
             --THEN 'Retail'  
             --	WHEN AcBuRevisedSegmentCode in ('CIB','FIG','Agri-Wholesale','MC','CB','SME','Treasury')
             --THEN 'Wholesale' 
             --  else AcBuRevisedSegmentCode end [Wholesale / Retail] 
             NULL Wholesale_Retail  ,
             NULL Balance  ,
             NULL PrincOutStd  ,
             NULL DrawingPower  ,
             NULL CurrentLimit  ,
             --,CASE WHEN SourceName = 'Finacle' AND SchemeType ='ODA' THEN (
             --		CASE WHEN (ISNULL(a.Balance,0) - (	CASE WHEN ISNULL(a.DrawingPower,0)<ISNULL(a.CurrentLimit,0) 
             --											THEN			ISNULL(a.DrawingPower,0) 
             --											ELSE ISNULL(a.CurrentLimit,0)  
             --											END 
             --										)
             --				  )<=0
             --		THEN	0	 
             --		ELSE  
             --		ISNULL(a.Balance,0) - (	CASE WHEN ISNULL(a.DrawingPower,0)<ISNULL(a.CurrentLimit,0) 
             --											THEN			ISNULL(a.DrawingPower,0) 
             --											ELSE ISNULL(a.CurrentLimit,0)  
             --											END 
             --										)
             --END) ELSE 0 END
             NULL OverDrawn_Amount  ,
             NULL DPD_Overdrawn  ,
             --,a.ContiExcessDt as [Limit/DP Overdrawn Date]
             NULL Limit_DP_Overdrawn_Date  ,
             NULL OverdueAmt  ,
             NULL OverDueSinceDt  ,
             NULL DPD_Overdue  ,
             NULL Bill_PC_Overdue_Amount  ,
             NULL Overdue_Bill_PC_ID  ,
             --,[Bill/PC Overdue Date]
             NULL Bill_PC_Overdue_Date  ,
             NULL DPD_Bill_PC  ,
             INTEREST_DIVIDENDDUEDATE ,
             INTEREST_DIVIDENDDUEAMOUNT ,
             DPD ,
             PartialRedumptionDueDate ,
             NULL SMA_DPD  ,
             NULL AccountFlgSMA  ,
             NULL AccountSMA_Dt  ,
             NULL AccountSMA_AssetClass  ,
             NULL SMA_Reason  ,
             NULL DPD_UCIF_ID  ,
             NULL UCICFlgSMA  ,
             NULL UCICSMA_Dt  ,
             NULL UCICSMA_AssetStatus  ,
             NULL SMA_Classification_Date  ,
             NULL in_default_Y_N_  ,
             NULL in_default_date  ,
             NULL out_of_default_Y_N_  ,
             NULL out_of_default_date  ,
             NULL MovementFromDate  ,
             NULL MovementFromStatus  ,
             NULL MovementToStatus  ,
             NULL Asset_Norm  ,
             NULL NPA_Norms  ,
             NULL Credit_FB_Exposure  ,
             NULL Credit_NFB_Exposure  ,
             NULL Non_SLR  ,
             NULL LER  ,
             NULL Total_Exposure  ,
             NULL Exposure_5crore_above_Flag  ,
             NULL FDOD_Flag  ,
             NULL Limit_Expiry_Date  ,
             NULL DPD_Limit_Expiry  ,
             NULL Stock_Statement_valuation_date  ,
             NULL DPD_StockStmt  ,
             NULL Debit_Balance_Since_Date  ,
             NULL Last_Credit_Date  ,
             NULL DPD_NoCredit  ,
             NULL Current_quarter_credit  ,
             NULL Current_quarter_interest  ,
             NULL Interest_Not_Serviced  ,
             NULL DPD_out_of_order  ,
             NULL CC_OD_Interest_Service  ,
             NULL PrincOverdue  ,
             NULL Principal_Overdue_Date  ,
             NULL DPD_Principal_Overdue  ,
             NULL IntOverdue  ,
             NULL Interest_Overdue_Date  ,
             NULL DPD_Interest_Overdue  ,
             NULL OtherOverdue  ,
             NULL Other_OverDue_Date  ,
             NULL DPD_Other_Overdue  
        FROM tt_TempInvestment_3 a
               JOIN CustomerBasicDetail b   ON A.Ref_Txn_Sys_Cust_ID = b.CustomerId
               LEFT JOIN DimBranch c   ON A.BranchCode = c.BranchCode
               AND c.EffectiveFromTimeKey <= v_Timekey
               AND c.EffectiveToTimeKey >= v_Timekey
       WHERE  b.EffectiveFromTimeKey <= v_Timekey
                AND b.EffectiveToTimeKey >= v_Timekey ;
      DBMS_SQL.RETURN_RESULT(v_cursor);--select 
   -- replace(CurrentProcessingDate,'/','-') CurrentProcessingDate
   --,SrNo
   --,BranchCode
   --,BranchName
   --,BranchStateName
   --,SourceName
   --,CustomerID
   --,SourceSystemCustomerID
   --,UCIF_ID
   --,CustomerAcID
   --,PANNO
   --,CustomerName
   --,CustSegmentCode
   --,FacilityType
   --,ProductCode
   --,ProductName
   --,ActSegmentCode
   --,AcBuRevisedSegmentCode
   --,SchemeType
   --,Balance
   --,PrincOutStd
   --,PrincOverdue
   --,IntOverdue
   --,OtherOverdue
   --,OverdueAmt
   --,CurrentLimit
   ----,ContiExcessDt
   --,convert(nvarchar(10),convert(date,ContiExcessDt , 105),23) as ContiExcessDt
   ----,StockStDt
   --,convert(nvarchar(10),convert(date,StockStDt , 105),23) as StockStDt
   ----,LastCrDate
   --,convert(nvarchar(10),convert(date,LastCrDate , 105),23) as LastCrDate
   ----,IntNotServicedDt
   --,convert(nvarchar(10),convert(date,IntNotServicedDt , 105),23) as IntNotServicedDt
   ----,OverDueSinceDt
   --,convert(nvarchar(10),convert(date,OverDueSinceDt , 105),23) as OverDueSinceDt
   ----,ReviewDueDt
   --,convert(nvarchar(10),convert(date,ReviewDueDt , 105),23) as ReviewDueDt
   --,DPD_StockStmt
   --,DPD_NoCredit
   --,DPD_IntService
   --,DPD_Overdrawn
   --,DPD_Overdue
   --,DPD_Renewal
   --,SMA_DPD
   --,AccountFlgSMA
   ----,AccountSMA_Dt
   --,convert(nvarchar(10),convert(date,AccountSMA_Dt , 105),23) as AccountSMA_Dt
   --,AccountSMA_AssetClass
   --,SMA_Reason
   --,DPD_UCIF_ID
   --,UCICFlgSMA
   ----,UCICSMA_Dt
   --,convert(nvarchar(10),convert(date,UCICSMA_Dt , 105),23) as UCICSMA_Dt
   --,UCICSMA_AssetStatus
   ----,MovementFromDate
   --,convert(nvarchar(10),convert(date,MovementFromDate , 105),23) as MovementFromDate
   --,MovementFromStatus
   --,MovementToStatus
   --,Asset_Norm
   --from SMA_OUTPUT
   ---------------------------------------SMA Report END-------------------------------------------------------------

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."SP_SMA_REPORT_INANDOUTDEFAULT_13022024" TO "ADF_CDR_RBL_STGDB";
