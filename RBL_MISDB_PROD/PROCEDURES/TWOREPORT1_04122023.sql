--------------------------------------------------------
--  DDL for Procedure TWOREPORT1_04122023
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."TWOREPORT1_04122023" 
AS
   --DECLARE @Date date = 
   --(select Date from Automate_Advances where Ext_flg = 'Y')
   --DECLARE @Timekey int = 
   --(@timekey)
   --DECLARE @LastQtrTimekey int = (select LastQtrDateKey from SysDayMatrix  where Timekey in (@timekey))
   --DECLARE @LastQtrDate date = (select LastQtrDate from SysDayMatrix  where Timekey in (@timekey))
   --DECLARE @CurQtrDate Date = (select CurQtrDate from SysDayMatrix  where Timekey in (@timekey))
   --DECLARE @LastMonthTimekey int = (select LastMonthDateKey from SysDayMatrix  where Timekey in (@timekey))
   --DECLARE @LastMonthDate date = (select LastMonthDate from SysDayMatrix  where Timekey in (@timekey))
   v_Date VARCHAR2(200) := ('2021-10-14 00:00:00.000');
   v_Timekey NUMBER(10,0) := ( SELECT Timekey 
     FROM Automate_Advances 
    WHERE  Date_ = v_date );
   --select @timekey
   v_LastQtrTimekey NUMBER(10,0) := ( SELECT LastQtrDateKey 
     FROM SysDayMatrix 
    WHERE  Timekey IN ( v_timekey )
    );
   v_LastQtrDate VARCHAR2(200) := ( SELECT LastQtrDate 
     FROM SysDayMatrix 
    WHERE  Timekey IN ( v_timekey )
    );
   v_CurQtrDate VARCHAR2(200) := ( SELECT CurQtrDate 
     FROM SysDayMatrix 
    WHERE  Timekey IN ( v_timekey )
    );
   v_LastMonthTimekey NUMBER(10,0) := ( SELECT LastMonthDateKey 
     FROM SysDayMatrix 
    WHERE  Timekey IN ( v_timekey )
    );
   v_LastMonthDate VARCHAR2(200) := ( SELECT LastMonthDate 
     FROM SysDayMatrix 
    WHERE  Timekey IN ( v_timekey )
    );
   v_cursor SYS_REFCURSOR;

BEGIN

   ----------------------------------------
   DELETE FROM tt_A_43;
   UTILS.IDENTITY_RESET('tt_A_43');

   INSERT INTO tt_A_43 ( 
   	SELECT DISTINCT CustomerAcID ,
                    FinalNpaDt ,
                    SMA_Class 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  CustomerAcID IN ( SELECT b.CustomerAcID 
                              FROM ExceptionFinalStatusType Z
                                     LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON Z.ACID = B.CustomerACID
                                     AND Z.EffectiveToTimeKey = 49999
                                     LEFT JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
                                     LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
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
                                     LEFT JOIN ( SELECT AcID CustomerACID  ,
                                                        Amount WriteOffAmt  ,
                                                        StatusDate WriteOffDt  
                                                 FROM ExceptionFinalStatusType 
                                                  WHERE  UTILS.CONVERT_TO_VARCHAR2(StatusDate,200) <= v_LastQtrDate
                                                           AND EffectiveToTimeKey = 49999 ) Y   ON B.CustomerAcID = Y.CustomerACID

                              --LEFT JOIN tt_DPD_55  DPD ON DPD.AccountEntityID=b.AccountEntityID AND dpd.EffectiveFromTimeKey = B.EffectiveFromTimeKey
                              WHERE  NVL(Y.writeoffAmt, 0) != 0
                                       AND FinalNpaDt IS NULL
                                       AND A.EffectiveFromTimeKey <= v_Timekey
                                       AND A.EffectiveToTimeKey >= v_Timekey
                                       AND B.EffectiveFromTimeKey <= v_Timekey
                                       AND B.EffectiveToTimeKey >= v_Timekey )

              AND finalNPAdT IS NOT NULL );
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DPD_55  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DPD_55;
   UTILS.IDENTITY_RESET('tt_DPD_55');

   INSERT INTO tt_DPD_55 ( 
   	SELECT CustomerACID ,
           AccountEntityid ,
           B.SourceSystemCustomerID ,
           B.IntNotServicedDt ,
           ('2021-10-14 00:00:00.000') Process_Date  ,
           LastCrDate ,
           ContiExcessDt ,
           OverDueSinceDt ,
           ReviewDueDt ,
           StockStDt ,
           PrincOverdueSinceDt ,
           IntOverdueSinceDt ,
           OtherOverdueSinceDt ,
           RefPeriodIntService ,
           RefPeriodNoCredit ,
           RefPeriodOverDrawn ,
           RefPeriodOverdue ,
           RefPeriodReview ,
           RefPeriodStkStatement ,
           A.DegDate ,
           b.EffectiveFromTimeKey ,
           b.EffectiveToTimeKey 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist B
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
   	 WHERE  A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey
              AND B.EffectiveFromTimeKey <= v_Timekey
              AND B.EffectiveToTimeKey >= v_Timekey );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD_55 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*---------- CALCULATED ALL DPD---------------------------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, Process_Date)
   ELSE 0
      END) AS pos_2, (CASE 
   WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, Process_Date)
   ELSE 0
      END) AS pos_3, (CASE 
   WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, Process_Date)
   ELSE 0
      END) AS pos_4, (CASE 
   WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, Process_Date)
   ELSE 0
      END) AS pos_5, (CASE 
   WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, Process_Date)
   ELSE 0
      END) AS pos_6, (CASE 
   WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, Process_Date)
   ELSE 0
      END) AS pos_7, (CASE 
   WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, Process_Date)
   ELSE 0
      END) AS pos_8, (CASE 
   WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, Process_Date)
   ELSE 0
      END) AS pos_9, (CASE 
   WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, Process_Date)
   ELSE 0
      END) AS pos_10
   FROM A ,tt_DPD_55 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_IntService = pos_2,
                                A.DPD_NoCredit = pos_3,
                                A.DPD_Overdrawn = pos_4,
                                A.DPD_Overdue = pos_5,
                                A.DPD_Renewal = pos_6,
                                A.DPD_StockStmt = pos_7,
                                A.DPD_PrincOverdue = pos_8,
                                A.DPD_IntOverdueSince = pos_9,
                                A.DPD_OtherOverdueSince = pos_10;
   /*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_DPD_55
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_DPD_55
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_DPD_55
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_DPD_55
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_DPD_55
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_DPD_55
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_DPD_55
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE tt_DPD_55
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE tt_DPD_55
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_55 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_NoCredit = 0;
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_149') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_149 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_149;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_149');

   INSERT INTO tt_TEMPTABLE_149 ( 
   	SELECT A.CustomerAcID ,
           CASE 
                WHEN NVL(A.DPD_IntService, 0) >= NVL(A.RefPeriodIntService, 0) THEN A.DPD_IntService
           ELSE 0
              END DPD_IntService  ,
           CASE 
                WHEN NVL(A.DPD_NoCredit, 0) >= NVL(A.RefPeriodNoCredit, 0) THEN A.DPD_NoCredit
           ELSE 0
              END DPD_NoCredit  ,
           CASE 
                WHEN NVL(A.DPD_Overdrawn, 0) >= NVL(A.RefPeriodOverDrawn, 0) THEN A.DPD_Overdrawn
           ELSE 0
              END DPD_Overdrawn  ,
           CASE 
                WHEN NVL(A.DPD_Overdue, 0) >= NVL(A.RefPeriodOverdue, 0) THEN A.DPD_Overdue
           ELSE 0
              END DPD_Overdue  ,
           CASE 
                WHEN NVL(A.DPD_Renewal, 0) >= NVL(A.RefPeriodReview, 0) THEN A.DPD_Renewal
           ELSE 0
              END DPD_Renewal  ,
           CASE 
                WHEN NVL(A.DPD_StockStmt, 0) >= NVL(A.RefPeriodStkStatement, 0) THEN A.DPD_StockStmt
           ELSE 0
              END DPD_StockStmt  

   	  --FROM PRO.ACCOUNTCAL A inner join pro.CustomerCal B on a.RefCustomerID=b.RefCustomerID
   	  FROM tt_DPD_55 A
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID
   	 WHERE  ( NVL(DPD_IntService, 0) >= NVL(RefPeriodIntService, 0)
              OR NVL(DPD_NoCredit, 0) >= NVL(RefPeriodNoCredit, 0)
              OR NVL(DPD_Overdrawn, 0) >= NVL(RefPeriodOverDrawn, 0)
              OR NVL(DPD_Overdue, 0) >= NVL(RefPeriodOverdue, 0)
              OR NVL(DPD_Renewal, 0) >= NVL(RefPeriodReview, 0)
              OR NVL(DPD_StockStmt, 0) >= NVL(RefPeriodStkStatement, 0) )
              AND ( NVL(B.FlgProcessing, 'N') = 'N' )
              AND B.EffectiveFromTimeKey <= v_Timekey
              AND B.EffectiveToTimeKey >= v_Timekey );
   --and A.RefCustomerID<>'0'
   /*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_55 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   --inner join PRO.CUSTOMERCAL B on A.RefCustomerID=B.RefCustomerID
   --WHERE  isnull(B.FlgProcessing,'N')='N'  
   /*----------------FIND MAX DPD---------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN ( NVL(A.DPD_IntService, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_IntService, 0)
   WHEN ( NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_NoCredit, 0)
   WHEN ( NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Overdrawn, 0)
   WHEN ( NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Renewal, 0)
   WHEN ( NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_Overdue, 0)
   WHEN ( NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_StockStmt, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_StockStmt, 0)
   WHEN ( NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_IntOverDueSince, 0)
     AND NVL(A.DPD_PrincOverdue, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(DPD_PrincOverdue, 0)
   WHEN ( NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_StockStmt, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_PrincOverdue, 0)
     AND NVL(A.DPD_IntOverDueSince, 0) >= NVL(A.DPD_OtherOverDueSince, 0) ) THEN NVL(A.DPD_IntOverDueSince, 0)
   ELSE NVL(A.DPD_OtherOverDueSince, 0)
      END) AS DPD_Max
   FROM A ,tt_DPD_55 a
        --INNER JOIN PRO.CUSTOMERCAL C ON C.RefCustomerID=a.RefCustomerID

          JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON C.SourceSystemCustomerID = a.SourceSystemCustomerID 
    WHERE ( NVL(C.FlgProcessing, 'N') = 'N' )
     AND ( NVL(A.DPD_IntService, 0) > 0
     OR NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0
     OR NVL(A.DPD_Renewal, 0) > 0
     OR NVL(A.DPD_StockStmt, 0) > 0
     OR NVL(DPD_NoCredit, 0) > 0 )
     AND C.EffectiveFromTimeKey <= v_Timekey
     AND C.EffectiveToTimeKey >= v_Timekey) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   DELETE FROM tt_TWOReport_17;
   UTILS.IDENTITY_RESET('tt_TWOReport_17');

   INSERT INTO tt_TWOReport_17 ( 
   	SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_date  ,
           A.UCIF_ID UCIC  ,
           A.RefCustomerID CIF_ID  ,
           REPLACE(A.CustomerName, ',', ' ') Customer_Name  ,
           B.BranchCode Branch_Code  ,
           REPLACE(BranchName, ',', ' ') Branch_Name  ,
           B.CustomerAcID Account_No_  ,
           SchemeType Scheme_Type  ,
           B.ProductCode Scheme_Code  ,
           ProductName Scheme_Description  ,
           ActSegmentCode Account_Segment_Code  ,
           CASE 
                WHEN SourceName = 'Ganaseva' THEN 'FI'
                WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
           ELSE AcBuSegmentDescription
              END Account_Segment_Description  ,
           B.FacilityType Facility  ,
           ProductGroup Nature_of_Facility  ,
           NVL(Y.WriteOffAmt, 0) Opening_Balance  ,
           (CASE 
                 WHEN NVL(Y.WriteOffAmt, 0) = 0 THEN NVL(B.PrincOutStd, 0)
           ELSE 0
              END) Addition  ,
           (CASE 
                 WHEN NVL(Y.WriteOffAmt, 0) > 0 THEN (CASE 
                                                           WHEN NVL(B.PrincOutStd, 0) - NVL(Y.WriteOffAmt, 0) < 0 THEN 0
                 ELSE NVL(B.PrincOutStd, 0) - NVL(Y.WriteOffAmt, 0)
                    END)
           ELSE 0
              END) Increase_In_Balance  ,
           ' ' Cash_Recovery  ,
           ' ' Recovery_from_NPA_Sale  ,
           0 Write_off  ,
           NVL(B.PrincOutStd, 0) Closing_Balance_POS ,---As requested by Sitaram sir 14/10/2021

           (CASE 
                 WHEN NVL(Y.WriteOffAmt, 0) - NVL(B.PrincOutStd, 0) < 0 THEN 0
           ELSE NVL(Y.WriteOffAmt, 0) - NVL(B.PrincOutStd, 0)
              END) Reduction_in_Balance  ,
           ( SELECT CurQtrDate 
             FROM SysDayMatrix 
            WHERE  Timekey IN ( v_timekey )
            ) Reporting_Period  ,
           NVL(DPD_Max, 0) DPD ,---As requested by Sitaram sir

           FinalNpaDt NPA_Date ,---As requested by Sitaram sir

           a2.AssetClassName Asset_Classification  ,
           Z.StatusDate Date_of_Technical_Write_off  ,
           SourceName Host_System  ,
           CASE 
                WHEN SourceName = 'Ganaseva' THEN 'FI'
                WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
           ELSE AcBuRevisedSegmentCode
              END Business_Segment  
   	  FROM ExceptionFinalStatusType Z
             LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON Z.ACID = B.CustomerACID
             AND z.EffectiveToTimeKey = 49999
             LEFT JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
             AND a.EffectiveFromTimeKey = b.EffectiveFromTimeKey
             LEFT JOIN DIMSOURCEDB src   ON b.SourceAlt_Key = src.SourceAlt_Key
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
             LEFT JOIN ( SELECT ACID CustomerAcID  ,
                                Amount WriteOffAmt  ,
                                StatusDate WriteOffDt  
                         FROM ExceptionFinalStatusType 
                          WHERE  UTILS.CONVERT_TO_VARCHAR2(StatusDate,200) <= v_LastQtrDate
                                   AND EffectiveToTimeKey = 49999 ) Y   ON B.CustomerAcID = Y.CustomerAcID
             LEFT JOIN tt_DPD_55 DPD   ON DPD.AccountEntityID = b.AccountEntityID
             AND dpd.EffectiveFromTimeKey = B.EffectiveFromTimeKey
   	 WHERE  NVL(Y.writeoffAmt, 0) != 0

              --and FinalNpaDt is not NULL
              AND A.EffectiveFromTimeKey <= v_Timekey
              AND A.EffectiveToTimeKey >= v_Timekey
              AND B.EffectiveFromTimeKey <= v_Timekey
              AND B.EffectiveToTimeKey >= v_Timekey );
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.FinalNpaDt, (CASE 
   WHEN B.SMA_Class = 'SUB' THEN 'SUB-STANDARD'
   WHEN B.SMA_Class = 'DB1' THEN 'DOUBTFUL I'
   WHEN B.SMA_Class = 'DB2' THEN 'DOUBTFUL II'
   WHEN B.SMA_Class = 'DB3' THEN 'DOUBTFUL III'
   ELSE B.SMA_Class
      END) AS pos_3
   FROM A ,tt_TWOReport_17 A
          JOIN tt_A_43 B   ON A.Account_No_ = B.CustomerACID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.NPA_Date = src.FinalNpaDt,
                                A.Asset_Classification = pos_3;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, UTILS.CONVERT_TO_VARCHAR2(B.NPA_date1,200,p_style=>105) AS pos_2, B.Assets_Class
   FROM A ,tt_TWOReport_17 A
          JOIN TWO_653 B   ON A.Account_No_ = B.Account_No# 
    WHERE A.NPA_Date IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.NPA_Date = pos_2,
                                A.Asset_Classification = src.Assets_Class;
   UPDATE tt_TWOReport_17
      SET Asset_Classification = (CASE 
                                       WHEN Asset_Classification = 'SUB' THEN 'SUB-STANDARD'
                                       WHEN Asset_Classification = 'DB1' THEN 'DOUBTFUL I'
                                       WHEN Asset_Classification = 'DB2' THEN 'DOUBTFUL II'
                                       WHEN Asset_Classification = 'DB3' THEN 'DOUBTFUL III'
          ELSE Asset_Classification
             END);
   OPEN  v_cursor FOR
      SELECT * 
        FROM tt_TWOReport_17  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT1_04122023" TO "ADF_CDR_RBL_STGDB";
