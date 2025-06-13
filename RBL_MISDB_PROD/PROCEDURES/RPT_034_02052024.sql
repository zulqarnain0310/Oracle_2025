--------------------------------------------------------
--  DDL for Procedure RPT_034_02052024
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_034_02052024" /*
Report Name			-  TWO Report As On
Create by			-  KALIK DEV
Date				-  10 NOV 2021
*/
(
  v_TimeKey IN NUMBER,
  v_Cost IN FLOAT
)
AS
   v_cursor SYS_REFCURSOR;

BEGIN

   DECLARE
      --DECLARE 
      --@Timekey INT= 26190,
      --@Cost FLOAT =1
      v_Date VARCHAR2(200) := ( SELECT date_ 
        FROM SysDayMatrix 
       WHERE  TimeKey = v_Timekey );
      v_LastQtrTimekey NUMBER(10,0) := ( SELECT LastQtrDateKey 
        FROM SysDayMatrix 
       WHERE  Timekey IN ( v_Timekey )
       );
      v_LastQtrDate VARCHAR2(200) := ( SELECT LastQtrDate 
        FROM SysDayMatrix 
       WHERE  Timekey IN ( v_Timekey )
       );
      v_CurQtrDate VARCHAR2(200) := ( SELECT CurQtrDate 
        FROM SysDayMatrix 
       WHERE  Timekey IN ( v_Timekey )
       );
      v_LastMonthTimekey NUMBER(10,0) := ( SELECT LastMonthDateKey 
        FROM SysDayMatrix 
       WHERE  Timekey IN ( v_Timekey )
       );
      v_LastMonthDate VARCHAR2(200) := ( SELECT LastMonthDate 
        FROM SysDayMatrix 
       WHERE  Timekey IN ( v_Timekey )
       );

   BEGIN
      ----------------------------------------
      IF utils.object_id('TEMPDB..tt_A_35') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_A_35 ';
      END IF;
      DELETE FROM tt_A_35;
      UTILS.IDENTITY_RESET('tt_A_35');

      INSERT INTO tt_A_35 ( 
      	SELECT DISTINCT CustomerAcID ,
                       FinalNpaDt ,
                       SMA_Class 
      	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
      	 WHERE  CustomerAcID IN ( SELECT B.CustomerAcID 
                                 FROM ExceptionFinalStatusType Z
                                        LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON Z.ACID = B.CustomerACID
                                        AND Z.EffectiveFromTimeKey <= v_Timekey
                                        AND Z.EffectiveToTimeKey >= v_Timekey
                                        LEFT JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
                                        AND A.EffectiveFromTimeKey = B.EffectiveFromTimeKey
                                        LEFT JOIN DIMSOURCEDB src   ON B.SourceAlt_Key = src.SourceAlt_Key
                                        AND src.EffectiveFromTimeKey <= v_Timekey
                                        AND src.EffectiveToTimeKey >= v_Timekey
                                        LEFT JOIN DimProduct PD   ON PD.ProductAlt_Key = B.PRODUCTALT_KEY
                                        AND PD.EffectiveFromTimeKey <= v_Timekey
                                        AND PD.EffectiveToTimeKey >= v_Timekey
                                        LEFT JOIN DimAssetClass A1   ON A1.AssetClassAlt_Key = B.InitialAssetClassAlt_Key
                                        AND A1.EffectiveFromTimeKey <= v_Timekey
                                        AND A1.EffectiveToTimeKey >= v_Timekey
                                        LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
                                        AND A2.EffectiveFromTimeKey <= v_Timekey
                                        AND A2.EffectiveToTimeKey >= v_Timekey
                                        LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
                                        AND S.EffectiveFromTimeKey <= v_Timekey
                                        AND S.EffectiveToTimeKey >= v_Timekey
                                        LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
                                        AND X.EffectiveFromTimeKey <= v_Timekey
                                        AND X.EffectiveToTimeKey >= v_Timekey
                                        LEFT JOIN ( SELECT AcID CustomerACID  ,
                                                           Amount WriteOffAmt  ,
                                                           StatusDate WriteOffDt  
                                                    FROM ExceptionFinalStatusType 
                                                     WHERE  UTILS.CONVERT_TO_VARCHAR2(StatusDate,200) <= v_LastQtrDate
                                                              AND EffectiveToTimeKey = 49999 ) Y   ON B.CustomerAcID = Y.CustomerACID
                                  WHERE  NVL(Y.writeoffAmt, 0) != 0
                                           AND FinalNpaDt IS NULL
                                           AND A.EffectiveFromTimeKey <= v_LastMonthTimekey
                                           AND A.EffectiveToTimeKey >= v_LastMonthTimekey )

                 AND FinalNpaDt IS NOT NULL );
      --------------------------------------------------------
      IF  --SQLDEV: NOT RECOGNIZED
      IF tt_DPD_26  --SQLDEV: NOT RECOGNIZED
      DELETE FROM tt_DPD_26;
      UTILS.IDENTITY_RESET('tt_DPD_26');

      INSERT INTO tt_DPD_26 ( 
      	SELECT CustomerACID ,
              AccountEntityid ,
              B.SourceSystemCustomerID ,
              B.IntNotServicedDt ,
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
              b.EffectiveFromTimeKey 
      	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist B
                JOIN SysDayMatrix SD   ON B.EffectiveFromTimeKey = SD.TimeKey
                JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
                AND A.EffectiveFromTimeKey = SD.TimeKey
      	 WHERE  InitialAssetClassAlt_Key = 1
                 AND FinalAssetClassAlt_Key > 1
                 AND A.EffectiveFromTimeKey <= v_LastMonthTimekey
                 AND A.EffectiveToTimeKey >= v_LastMonthTimekey );
      -----------------------------------

      EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD_26 
         ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
      /*---------- CALCULATED ALL DPD---------------------------------------------------------*/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, (CASE 
      WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_Date)
      ELSE 0
         END) AS pos_2, (CASE 
      WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, v_Date)
      ELSE 0
         END) AS pos_3, (CASE 
      WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, v_Date)
      ELSE 0
         END) AS pos_4, (CASE 
      WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_Date)
      ELSE 0
         END) AS pos_5, (CASE 
      WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, v_Date)
      ELSE 0
         END) AS pos_6, (CASE 
      WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, v_Date)
      ELSE 0
         END) AS pos_7, (CASE 
      WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, v_Date)
      ELSE 0
         END) AS pos_8, (CASE 
      WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, v_Date)
      ELSE 0
         END) AS pos_9, (CASE 
      WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, v_Date)
      ELSE 0
         END) AS pos_10
      FROM A ,tt_DPD_26 A ) src
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
      UPDATE tt_DPD_26
         SET DPD_IntService = 0
       WHERE  NVL(DPD_IntService, 0) < 0;
      UPDATE tt_DPD_26
         SET DPD_NoCredit = 0
       WHERE  NVL(DPD_NoCredit, 0) < 0;
      UPDATE tt_DPD_26
         SET DPD_Overdrawn = 0
       WHERE  NVL(DPD_Overdrawn, 0) < 0;
      UPDATE tt_DPD_26
         SET DPD_Overdue = 0
       WHERE  NVL(DPD_Overdue, 0) < 0;
      UPDATE tt_DPD_26
         SET DPD_Renewal = 0
       WHERE  NVL(DPD_Renewal, 0) < 0;
      UPDATE tt_DPD_26
         SET DPD_StockStmt = 0
       WHERE  NVL(DPD_StockStmt, 0) < 0;
      UPDATE tt_DPD_26
         SET DPD_PrincOverdue = 0
       WHERE  NVL(DPD_PrincOverdue, 0) < 0;
      UPDATE tt_DPD_26
         SET DPD_IntOverdueSince = 0
       WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
      UPDATE tt_DPD_26
         SET DPD_OtherOverdueSince = 0
       WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
      /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, 0
      FROM A ,tt_DPD_26 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_NoCredit = 0;
      /* CALCULATE MAX DPD */
      IF utils.object_id('TEMPDB..tt_TEMPTABLE_125') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_125 ';
      END IF;
      DELETE FROM tt_TEMPTABLE_125;
      UTILS.IDENTITY_RESET('tt_TEMPTABLE_125');

      INSERT INTO tt_TEMPTABLE_125 ( 
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
      	  FROM tt_DPD_26 A
                JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.SourceSystemCustomerID = B.SourceSystemCustomerID
      	 WHERE  ( NVL(DPD_IntService, 0) >= NVL(RefPeriodIntService, 0)
                 OR NVL(DPD_NoCredit, 0) >= NVL(RefPeriodNoCredit, 0)
                 OR NVL(DPD_Overdrawn, 0) >= NVL(RefPeriodOverDrawn, 0)
                 OR NVL(DPD_Overdue, 0) >= NVL(RefPeriodOverdue, 0)
                 OR NVL(DPD_Renewal, 0) >= NVL(RefPeriodReview, 0)
                 OR NVL(DPD_StockStmt, 0) >= NVL(RefPeriodStkStatement, 0) )
                 AND ( NVL(B.FlgProcessing, 'N') = 'N' ) );
      /*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, 0
      FROM A ,tt_DPD_26 A ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
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
      FROM A ,tt_DPD_26 A
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON C.SourceSystemCustomerID = A.SourceSystemCustomerID 
       WHERE ( NVL(C.FlgProcessing, 'N') = 'N' )
        AND ( NVL(A.DPD_IntService, 0) > 0
        OR NVL(A.DPD_Overdrawn, 0) > 0
        OR NVL(A.DPD_Overdue, 0) > 0
        OR NVL(A.DPD_Renewal, 0) > 0
        OR NVL(A.DPD_StockStmt, 0) > 0
        OR NVL(DPD_NoCredit, 0) > 0 )) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
      --------------------------------------------------------------
      IF utils.object_id('TEMPDB..tt_TWOReport_11') IS NOT NULL THEN
       EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TWOReport_11 ';
      END IF;
      DELETE FROM tt_TWOReport_11;
      UTILS.IDENTITY_RESET('tt_TWOReport_11');

      INSERT INTO tt_TWOReport_11 ( 
      	SELECT ( SELECT date_ 
                FROM SysDayMatrix 
               WHERE  TimeKey = v_Timekey ) Report_date  ,
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
                   WHEN SourceName = 'FIS' THEN 'FI'
                   WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
              ELSE AcBuSegmentDescription
                 END Account_Segment_Description  ,
              B.FacilityType Facility  ,
              ProductGroup Nature_of_Facility  ,
              NVL(Y.WriteOffAmt, 0) / v_Cost Opening_Balance  ,
              (CASE 
                    WHEN NVL(Y.WriteOffAmt, 0) = 0 THEN NVL(B.PrincOutStd, 0)
              ELSE 0
                 END) / v_Cost Addition  ,
              (CASE 
                    WHEN NVL(Y.WriteOffAmt, 0) > 0 THEN (CASE 
                                                              WHEN NVL(B.PrincOutStd, 0) - NVL(Y.WriteOffAmt, 0) < 0 THEN 0
                    ELSE NVL(B.PrincOutStd, 0) - NVL(Y.WriteOffAmt, 0)
                       END)
              ELSE 0
                 END) / v_Cost Increase_In_Balance  ,
              0 Cash_Recovery  ,
              0 Recovery_from_NPA_Sale  ,
              0 Write_off  ,
              NVL(B.PrincOutStd, 0) / v_Cost Closing_Balance_POS_as_on_19_10_2021  ,
              (CASE 
                    WHEN NVL(Y.WriteOffAmt, 0) - NVL(B.PrincOutStd, 0) < 0 THEN 0
              ELSE NVL(Y.WriteOffAmt, 0) - NVL(B.PrincOutStd, 0)
                 END) / v_Cost Reduction_in_Balance  ,
              ( SELECT CurQtrDate 
                FROM SysDayMatrix 
               WHERE  Timekey IN ( v_Timekey )
               ) Reporting_Period  ,
              NVL(DPD_Max, 0) DPD_as_on_19_10_2021  ,
              FinalNpaDt NPA_Date_as_on_19_10_2021  ,
              A2.AssetClassName Asset_Classification  ,
              UTILS.CONVERT_TO_VARCHAR2(Z.StatusDate,20,p_style=>103) Date_of_Technical_Write_off  ,
              SourceName Host_System  ,
              CASE 
                   WHEN SourceName = 'FIS' THEN 'FI'

                   -- WHEN SourceName='VisionPlus' 	  THEN 'Credit Card'
                   WHEN SourceName = 'VisionPlus'
                     AND B.ProductCode IN ( '777','780' )
                    THEN 'Retail'
                   WHEN SourceName = 'VisionPlus'
                     AND B.ProductCode NOT IN ( '777','780' )
                    THEN 'Credit Card'
              ELSE AcBuRevisedSegmentCode
                 END Business_Segment  
      	  FROM ExceptionFinalStatusType Z
                LEFT JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist B   ON Z.ACID = B.CustomerACID
                AND Z.EffectiveFromTimeKey <= v_Timekey
                AND Z.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist A   ON A.CustomerEntityID = B.CustomerEntityID
                AND A.EffectiveFromTimeKey = B.EffectiveFromTimeKey
                LEFT JOIN DIMSOURCEDB src   ON B.SourceAlt_Key = src.SourceAlt_Key
                AND src.EffectiveFromTimeKey <= v_Timekey
                AND src.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN DimProduct PD   ON PD.ProductAlt_Key = b.PRODUCTALT_KEY
                AND PD.EffectiveFromTimeKey <= v_Timekey
                AND PD.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN DimAssetClass A1   ON A1.AssetClassAlt_Key = B.InitialAssetClassAlt_Key
                AND A1.EffectiveFromTimeKey <= v_Timekey
                AND A1.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
                AND A2.EffectiveFromTimeKey <= v_Timekey
                AND A2.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
                AND S.EffectiveFromTimeKey <= v_Timekey
                AND S.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
                AND X.EffectiveFromTimeKey <= v_Timekey
                AND X.EffectiveToTimeKey >= v_Timekey
                LEFT JOIN ( SELECT ACID CustomerAcID  ,
                                   Amount WriteOffAmt  ,
                                   StatusDate WriteOffDt  
                            FROM ExceptionFinalStatusType 
                             WHERE  UTILS.CONVERT_TO_VARCHAR2(StatusDate,200) <= v_LastQtrDate
                                      AND EffectiveToTimeKey = 49999 ) Y   ON B.CustomerAcID = Y.CustomerAcID
                LEFT JOIN tt_DPD_26 DPD   ON DPD.AccountEntityID = B.AccountEntityID
                AND DPD.EffectiveFromTimeKey = B.EffectiveFromTimeKey
      	 WHERE  NVL(Y.writeoffAmt, 0) != 0
                 AND A.EffectiveFromTimeKey <= v_LastMonthTimekey
                 AND A.EffectiveToTimeKey >= v_LastMonthTimekey );
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, B.FinalNpaDt, (CASE 
      WHEN B.SMA_Class = 'SUB' THEN 'SUB-STANDARD'
      WHEN B.SMA_Class = 'DB1' THEN 'DOUBTFUL I'
      WHEN B.SMA_Class = 'DB2' THEN 'DOUBTFUL II'
      WHEN B.SMA_Class = 'DB3' THEN 'DOUBTFUL III'
      ELSE B.SMA_Class
         END) AS pos_3
      FROM A ,tt_TWOReport_11 A
             JOIN tt_A_35 B   ON A.Account_No_ = B.CustomerACID ) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.NPA_Date_as_on_19_10_2021 = src.FinalNpaDt,
                                   A.Asset_Classification = pos_3;
      MERGE INTO A 
      USING (SELECT A.ROWID row_id, UTILS.CONVERT_TO_VARCHAR2(B.NPA_date1,200,p_style=>103) AS pos_2, B.Assets_Class
      FROM A ,tt_TWOReport_11 A
             JOIN TWO_653 B   ON A.Account_No_ = B.Account_No# 
       WHERE A.NPA_Date_as_on_19_10_2021 IS NULL) src
      ON ( A.ROWID = src.row_id )
      WHEN MATCHED THEN UPDATE SET A.NPA_Date_as_on_19_10_2021 = pos_2,
                                   A.Asset_Classification = src.Assets_Class;
      UPDATE tt_TWOReport_11
         SET Asset_Classification = (CASE 
                                          WHEN Asset_Classification = 'SUB' THEN 'SUB-STANDARD'
                                          WHEN Asset_Classification = 'DB1' THEN 'DOUBTFUL I'
                                          WHEN Asset_Classification = 'DB2' THEN 'DOUBTFUL II'
                                          WHEN Asset_Classification = 'DB3' THEN 'DOUBTFUL III'
             ELSE Asset_Classification
                END);
      OPEN  v_cursor FOR
         SELECT Report_date ,
                UCIC ,
                CIF_ID ,
                Customer_Name ,
                Branch_Code ,
                Branch_Name ,
                Account_No_ ,
                Scheme_Type ,
                Scheme_Code ,
                Scheme_Description ,
                Account_Segment_Code ,
                Account_Segment_Description ,
                Facility ,
                Nature_of_Facility ,
                Opening_Balance ,
                Addition ,
                Increase_In_Balance ,
                Cash_Recovery ,
                Recovery_from_NPA_Sale ,
                Write_off ,
                Closing_Balance_POS_as_on_19_10_2021 ,
                Reduction_in_Balance ,
                Reporting_Period ,
                DPD_as_on_19_10_2021 ,
                UTILS.CONVERT_TO_VARCHAR2(NPA_Date_as_on_19_10_2021,20,p_style=>103) NPA_Date_as_on_19_10_2021  ,
                Asset_Classification ,
                Date_of_Technical_Write_off ,
                Host_System ,
                Business_Segment 
           FROM tt_TWOReport_11  ;
         DBMS_SQL.RETURN_RESULT(v_cursor);

   END;
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_A_35 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD_26 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_125 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TWOReport_11 ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_034_02052024" TO "ADF_CDR_RBL_STGDB";
