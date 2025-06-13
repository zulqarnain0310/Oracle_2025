--------------------------------------------------------
--  DDL for Procedure TWOREPORT_POSTMOC_NEW
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" 
AS
   v_Date VARCHAR2(200) := ( SELECT Date_ 
     FROM Automate_Advances 
    WHERE  Ext_Flg = 'Y' );
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
--@Date date

BEGIN

   ----------------------------------------
   DELETE FROM tt_ExceptionFinalStatusType_23;
   UTILS.IDENTITY_RESET('tt_ExceptionFinalStatusType_23');

   INSERT INTO tt_ExceptionFinalStatusType_23 ( 
   	SELECT A.* 
   	  FROM ExceptionFinalStatusType A
             JOIN ( SELECT DISTINCT CustomerAcID 
                    FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
                     WHERE  EffectiveToTimeKey > v_LastQtrTimekey ) B   ON A.ACID = B.CustomerAcID );
   DELETE FROM tt_DimCustomer_23;
   UTILS.IDENTITY_RESET('tt_DimCustomer_23');

   INSERT INTO tt_DimCustomer_23 ( 
   	SELECT DISTINCT UCIF_ID ,
                    A.CustomerID ,
                    CustomerName 
   	  FROM CustomerBasicDetail A
             JOIN ( SELECT DISTINCT CustomerID ,
                                    MAX(EffectiveTotimekey)  Timekey  
                    FROM CustomerBasicDetail 
                     WHERE  CustomerID IN ( SELECT DISTINCT CustomerId 
                                            FROM tt_ExceptionFinalStatusType_23  )

                      GROUP BY CustomerID ) B   ON A.CustomerId = B.CustomerId
             AND A.EffectiveToTimeKey = B.Timekey
   	 WHERE  A.CustomerId IN ( SELECT DISTINCT CustomerId 
                              FROM tt_ExceptionFinalStatusType_23  )
    );
   DELETE FROM tt_A_54;
   UTILS.IDENTITY_RESET('tt_A_54');

   INSERT INTO tt_A_54 ( 
   	SELECT DISTINCT CustomerAcID ,
                    FinalNpaDt ,
                    SMA_Class 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_Timekey
              AND EffectiveToTimeKey >= v_Timekey
              AND CustomerAcID IN ( SELECT b.CustomerAcID 
                                    FROM tt_ExceptionFinalStatusType_23 Z
                                           LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON Z.ACID = B.CustomerACID
                                           AND B.EffectiveFromTimeKey <= v_Timekey
                                           AND B.EffectiveToTimeKey >= v_Timekey
                                           LEFT JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
                                           AND A.EffectiveFromTimeKey <= v_Timekey
                                           AND A.EffectiveToTimeKey >= v_Timekey
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
                                                       FROM tt_ExceptionFinalStatusType_23  ) Y   ON Z.ACID = Y.CustomerACID
                                     WHERE  NVL(Y.writeoffAmt, 0) != 0 )


              --and FinalNpaDt is  NULL
              AND finalNPAdT IS NOT NULL );
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DPD_66  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DPD_66;
   UTILS.IDENTITY_RESET('tt_DPD_66');

   INSERT INTO tt_DPD_66 ( 
   	SELECT CustomerACID ,
           AccountEntityid ,
           B.SourceSystemCustomerID ,
           B.IntNotServicedDt ,
           ( SELECT Date_ 
             FROM Automate_Advances 
            WHERE  Ext_Flg = 'Y' ) Process_Date  ,
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

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD_66 
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
   FROM A ,tt_DPD_66 A ) src
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
   UPDATE tt_DPD_66
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_DPD_66
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_DPD_66
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_DPD_66
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_DPD_66
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_DPD_66
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_DPD_66
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE tt_DPD_66
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE tt_DPD_66
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_66 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_NoCredit = 0;
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_160') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_160 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_160;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_160');

   INSERT INTO tt_TEMPTABLE_160 ( 
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
   	  FROM tt_DPD_66 A
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
   FROM A ,tt_DPD_66 A ) src
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
   FROM A ,tt_DPD_66 a
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
   DELETE FROM tt_TWOReport_28;
   UTILS.IDENTITY_RESET('tt_TWOReport_28');

   INSERT INTO tt_TWOReport_28 ( 
   	SELECT UTILS.CONVERT_TO_NVARCHAR2(v_Date,30,p_style=>105) Report_date  ,
           XYZ.UCIF_ID UCIC  ,
           Z.CustomerID CIF_ID  ,
           REPLACE(XYZ.CustomerName, ',', ' ') Customer_Name  ,
           B.BranchCode Branch_Code  ,
           REPLACE(BranchName, ',', ' ') Branch_Name  ,
           Z.ACID Account_No_  ,
           SchemeType Scheme_Type  ,
           B.ProductCode Scheme_Code  ,
           ProductName Scheme_Description  ,
           ActSegmentCode Account_Segment_Code  ,
           CASE 
                WHEN SourceName = 'FIS' THEN 'FI'
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

           --,a2.AssetClassName as [Asset Classification]
           a2.AssetClassSubGroup Asset_Classification ,---added by Prashant---02052024---

           Z.StatusDate Date_of_Technical_Write_off  ,
           SourceName Host_System  ,
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
              END Business_Segment  
   	  FROM tt_ExceptionFinalStatusType_23 Z
             LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON Z.ACID = B.CustomerACID
             AND B.EffectiveFromTimeKey <= v_Timekey
             AND B.EffectiveToTimeKey >= v_Timekey
             LEFT JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
             AND A.EffectiveFromTimeKey <= v_Timekey
             AND A.EffectiveToTimeKey >= v_Timekey
             LEFT JOIN tt_DimCustomer_23 xyz   ON Z.CustomerID = xyz.CustomerId
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
                         FROM tt_ExceptionFinalStatusType_23  ) Y   ON Z.ACID = Y.CustomerAcID
             LEFT JOIN tt_DPD_66 DPD   ON DPD.AccountEntityID = b.AccountEntityID
   	 WHERE  NVL(Y.writeoffAmt, 0) != 0
              AND z.EffectiveFromTimeKey <= v_Timekey
              AND z.EffectiveToTimeKey >= v_Timekey );
   --and FinalNpaDt is not NULL
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, B.FinalNpaDt, (CASE 
   WHEN B.SMA_Class = 'SUB' THEN 'SUB-STANDARD'
   WHEN B.SMA_Class = 'DB1' THEN 'DOUBTFUL I'
   WHEN B.SMA_Class = 'DB2' THEN 'DOUBTFUL II'
   WHEN B.SMA_Class = 'DB3' THEN 'DOUBTFUL III'
   WHEN B.SMA_Class = 'Los' THEN 'LOSS'
   ELSE B.SMA_Class
      END) AS pos_3
   FROM A ,tt_TWOReport_28 A
          JOIN tt_A_54 B   ON A.Account_No_ = B.CustomerACID ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.NPA_Date = src.FinalNpaDt,
                                A.Asset_Classification = pos_3;
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, UTILS.CONVERT_TO_VARCHAR2(B.NPA_date1,200,p_style=>105) AS pos_2, B.Assets_Class
   FROM A ,tt_TWOReport_28 A
          JOIN TWO_653 B   ON A.Account_No_ = B.Account_No# 
    WHERE A.NPA_Date IS NULL) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.NPA_Date = pos_2,
                                A.Asset_Classification = src.Assets_Class;
   UPDATE tt_TWOReport_28
      SET Asset_Classification = (CASE 
                                       WHEN Asset_Classification = 'SUB' THEN 'SUB-STANDARD'
                                       WHEN Asset_Classification = 'DB1' THEN 'DOUBTFUL I'
                                       WHEN Asset_Classification = 'DB2' THEN 'DOUBTFUL II'
                                       WHEN Asset_Classification = 'DB3' THEN 'DOUBTFUL III'
                                       WHEN Asset_Classification = 'Los' THEN 'LOSS'
          ELSE Asset_Classification
             END);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE TWOReport_Final_postmoc ';
   INSERT INTO TWOReport_Final_postmoc
     ( SELECT * 
       FROM tt_TWOReport_28 
        WHERE  NPA_Date IS NOT NULL );
   OPEN  v_cursor FOR
      SELECT * 
        FROM TWOReport_Final_postmoc  ;
      DBMS_SQL.RETURN_RESULT(v_cursor);

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."TWOREPORT_POSTMOC_NEW" TO "ADF_CDR_RBL_STGDB";
