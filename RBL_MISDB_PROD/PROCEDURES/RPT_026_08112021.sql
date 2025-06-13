--------------------------------------------------------
--  DDL for Procedure RPT_026_08112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_026_08112021" 
--USE [RBL_MISDB]
 --GO
 --/****** Object:  StoredProcedure [dbo].[Rpt-026]    Script Date: 11/8/2021 1:53:44 PM ******/
 --SET ANSI_NULLS ON
 --GO
 --SET QUOTED_IDENTIFIER ON
 --GO

(
  v_DateFrom IN VARCHAR2,
  v_DateTo IN VARCHAR2,
  v_Cost IN FLOAT
)
AS
   --DECLARE 
   --@DateFrom	AS VARCHAR(15)='01/10/2021',
   --@DateTo		AS VARCHAR(15)='31/10/2021',
   --@Cost    AS FLOAT=1
   v_From1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateFrom))  );
   v_to1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_DateTo))  );
   v_cursor SYS_REFCURSOR;

BEGIN

   ---------------------DEGRADATION  Report----------------------
   ---------------------------======================================DPD CalCULATION  Start===========================================
   IF  --SQLDEV: NOT RECOGNIZED
   IF tt_DPD_17  --SQLDEV: NOT RECOGNIZED
   DELETE FROM tt_DPD_17;
   UTILS.IDENTITY_RESET('tt_DPD_17');

   INSERT INTO tt_DPD_17 ( 
   	SELECT CustomerACID ,
           AccountEntityid ,
           B.SourceSystemCustomerID ,
           B.IntNotServicedDt ,
           UTILS.CONVERT_TO_VARCHAR2(SD.Date_,200) ProcessDate  ,
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
           b.EffectiveFromTimeKey 
   	  FROM PRO_RBL_MISDB_PROD.Accountcal_Hist_before_opt B
             JOIN SysDayMatrix SD   ON B.EffectiveFromTimeKey = SD.TimeKey
             JOIN PRO_RBL_MISDB_PROD.Customercal_Hist_before_opt A   ON A.EffectiveFromTimeKey = SD.TimeKey
             AND A.CustomerEntityID = B.CustomerEntityID
   	 WHERE  UTILS.CONVERT_TO_VARCHAR2(SD.Date_,200) BETWEEN v_From1 AND v_to1 );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD_17 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_PrincOverdue NUMBER(10,0) , DPD_IntOverdueSince NUMBER(10,0) , DPD_OtherOverdueSince NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*---------- CALCULATED ALL DPD---------------------------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, ProcessDate)
   ELSE 0
      END) AS pos_2, (CASE 
   WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, ProcessDate)
   ELSE 0
      END) AS pos_3, (CASE 
   WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, ProcessDate)
   ELSE 0
      END) AS pos_4, (CASE 
   WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, ProcessDate)
   ELSE 0
      END) AS pos_5, (CASE 
   WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, ProcessDate)
   ELSE 0
      END) AS pos_6, (CASE 
   WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, ProcessDate)
   ELSE 0
      END) AS pos_7, (CASE 
   WHEN A.PrincOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.PrincOverdueSinceDt, ProcessDate)
   ELSE 0
      END) AS pos_8, (CASE 
   WHEN A.IntOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.IntOverdueSinceDt, ProcessDate)
   ELSE 0
      END) AS pos_9, (CASE 
   WHEN A.OtherOverdueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OtherOverdueSinceDt, ProcessDate)
   ELSE 0
      END) AS pos_10
   FROM A ,tt_DPD_17 A ) src
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
   UPDATE tt_DPD_17
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_DPD_17
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_DPD_17
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_DPD_17
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_DPD_17
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_DPD_17
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   UPDATE tt_DPD_17
      SET DPD_PrincOverdue = 0
    WHERE  NVL(DPD_PrincOverdue, 0) < 0;
   UPDATE tt_DPD_17
      SET DPD_IntOverdueSince = 0
    WHERE  NVL(DPD_IntOverdueSince, 0) < 0;
   UPDATE tt_DPD_17
      SET DPD_OtherOverdueSince = 0
    WHERE  NVL(DPD_OtherOverdueSince, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_17 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_NoCredit = 0;
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_116') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_116 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_116;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_116');

   INSERT INTO tt_TEMPTABLE_116 ( 
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
   	  FROM tt_DPD_17 A
             JOIN SysDayMatrix SD   ON A.EffectiveFromTimeKey = SD.TimeKey
             JOIN PRO_RBL_MISDB_PROD.Customercal_Hist_before_opt B   ON B.EffectiveFromTimeKey = SD.TimeKey
             AND A.SourceSystemCustomerID = B.SourceSystemCustomerID
   	 WHERE  ( NVL(DPD_IntService, 0) >= NVL(RefPeriodIntService, 0)
              OR NVL(DPD_NoCredit, 0) >= NVL(RefPeriodNoCredit, 0)
              OR NVL(DPD_Overdrawn, 0) >= NVL(RefPeriodOverDrawn, 0)
              OR NVL(DPD_Overdue, 0) >= NVL(RefPeriodOverdue, 0)
              OR NVL(DPD_Renewal, 0) >= NVL(RefPeriodReview, 0)
              OR NVL(DPD_StockStmt, 0) >= NVL(RefPeriodStkStatement, 0) )
              AND ( NVL(B.FlgProcessing, 'N') = 'N' )
              AND UTILS.CONVERT_TO_VARCHAR2(SD.Date_,200) BETWEEN v_From1 AND v_to1 );
   --and A.RefCustomerID<>'0'
   /*--------------INTIAL MAX DPD 0 FOR RE PROCESSING DATA-------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_17 A ) src
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
   FROM A ,tt_DPD_17 A
          JOIN SysDayMatrix SD   ON A.EffectiveFromTimeKey = SD.TimeKey
          JOIN PRO_RBL_MISDB_PROD.Customercal_Hist_before_opt C   ON C.EffectiveFromTimeKey = SD.TimeKey
          AND A.SourceSystemCustomerID = C.SourceSystemCustomerID 
    WHERE ( NVL(C.FlgProcessing, 'N') = 'N' )
     AND ( NVL(A.DPD_IntService, 0) > 0
     OR NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0
     OR NVL(A.DPD_Renewal, 0) > 0
     OR NVL(A.DPD_StockStmt, 0) > 0
     OR NVL(DPD_NoCredit, 0) > 0 )
     AND UTILS.CONVERT_TO_VARCHAR2(SD.Date_,200) BETWEEN v_From1 AND v_to1) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   ------------------------------------------------=========================END===========================
   ---------Degrade Report-------------------
   OPEN  v_cursor FOR
      SELECT --CONVERT(VARCHAR(20),@to1, 103)                  AS  [Process_date] 
             UTILS.CONVERT_TO_VARCHAR2(SD.Date_,20,p_style=>103) Process_date  ,
             A.UCIF_ID UCIC  ,
             A.RefCustomerID CustomerID  ,
             CustomerName ,
             B.BranchCode ,
             BranchName ,
             b.CustomerAcID ,
             SourceName ,
             B.FacilityType ,
             SchemeType ,
             B.ProductCode ,
             ProductName ,
             b.ActSegmentCode ,
             CASE 
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuSegmentDescription
                END AcBuSegmentDescription  ,
             CASE 
                  WHEN SourceName = 'Ganaseva' THEN 'FI'
                  WHEN SourceName = 'VisionPlus' THEN 'Credit Card'
             ELSE AcBuRevisedSegmentCode
                END AcBuRevisedSegmentCode  ,
             DPD_Max ,
             UTILS.CONVERT_TO_VARCHAR2(b.FinalNpaDt,20,p_style=>103) FinalNpaDt  ,
             NVL(b.Balance, 0) / v_Cost Balance  ,
             NVL(b.NetBalance, 0) / v_Cost NetBalance  ,
             NVL(b.DrawingPower, 0) / v_Cost DrawingPower  ,
             NVL(b.CurrentLimit, 0) / v_Cost CurrentLimit  ,
             (CASE 
                   WHEN A.SourceAlt_Key = 1
                     AND SchemeType = 'ODA' THEN (CASE 
                                                       WHEN (NVL(b.Balance, 0) - (CASE 
                                                                                       WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                                                       ELSE NVL(b.CurrentLimit, 0)
                                                          END)) <= 0 THEN 0
                   ELSE (CASE 
                              WHEN NVL(b.DrawingPower, 0) < NVL(b.CurrentLimit, 0) THEN NVL(b.DrawingPower, 0)
                   ELSE NVL(b.CurrentLimit, 0)
                      END)
                      END)
             ELSE 0
                END) / v_COST OverDrawn_Amt  ,
             DPD_Overdrawn ,
             UTILS.CONVERT_TO_VARCHAR2(b.ContiExcessDt,20,p_style=>103) ContiExcessDt  ,
             UTILS.CONVERT_TO_VARCHAR2(b.ReviewDueDt,20,p_style=>103) ReviewDueDt  ,
             DPD_Renewal ,
             UTILS.CONVERT_TO_VARCHAR2(b.StockStDt,20,p_style=>103) StockStDt  ,
             DPD_StockStmt ,
             UTILS.CONVERT_TO_VARCHAR2(b.DebitSinceDt,20,p_style=>103) DebitSinceDt  ,
             UTILS.CONVERT_TO_VARCHAR2(b.LastCrDate,20,p_style=>103) LastCrDate  ,
             DPD_NoCredit ,
             NVL(b.CurQtrCredit, 0) / v_Cost CurQtrCredit  ,
             NVL(b.CurQtrInt, 0) / v_Cost CurQtrInt  ,
             (CASE 
                   WHEN (NVL(b.CurQtrInt, 0) - NVL(b.CurQtrCredit, 0)) < 0 THEN 0
             ELSE (NVL(b.CurQtrInt, 0) - NVL(b.CurQtrCredit, 0))
                END) / v_Cost InterestNotServiced  ,
             DPD_IntService ,
             B.IntNotServicedDt CC_OD_Interest_Service  ,
             (NVL(b.OverdueAmt, 0) / v_Cost) OverdueAmt  ,
             UTILS.CONVERT_TO_VARCHAR2(b.OverDueSinceDt,20,p_style=>103) OverDueSinceDt  ,
             DPD_Overdue ,
             NVL(b.PrincOverdue, 0) / v_Cost PrincOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(b.PrincOverdueSinceDt,20,p_style=>103) PrincOverdueSinceDt  ,
             DPD_PrincOverDue ,
             NVL(b.IntOverdue, 0) / v_Cost IntOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(b.IntOverdueSinceDt,20,p_style=>103) IntOverdueSinceDt  ,
             DPD_IntOverdueSince ,
             NVL(b.OtherOverdue, 0) / v_Cost OtherOverdue  ,
             UTILS.CONVERT_TO_VARCHAR2(b.OtherOverdueSinceDt,20,p_style=>103) OtherOverdueSinceDt  ,
             DPD_OtherOverdueSince ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN b.OverdueAmt
             ELSE 0
                END) Bill_PC_Overdue_Amount  ,
             ' ' Overdue_Bill_PC_ID  ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN UTILS.CONVERT_TO_VARCHAR2(b.OverDueSinceDt,30)
             ELSE ' '
                END) Bill_PC_Overdue_Date  ,
             (CASE 
                   WHEN SchemeType = 'FBA' THEN DPD_Overdue
             ELSE 0
                END) DPD_Bill_PC  ,
             A2.AssetClassName FinalAssetName  ,
             A.DegReason ,
             b.RefPeriodOverdue NPANorms  
        FROM PRO_RBL_MISDB_PROD.Accountcal_Hist_before_opt B
               JOIN SysDayMatrix SD   ON B.EffectiveFromTimeKey = SD.TimeKey
               JOIN PRO_RBL_MISDB_PROD.Customercal_Hist_before_opt A   ON A.EffectiveFromTimeKey = SD.TimeKey
               AND A.CustomerEntityID = B.CustomerEntityID
               LEFT JOIN DIMSOURCEDB src   ON B.SourceAlt_Key = src.SourceAlt_Key
               AND src.EffectiveToTimeKey = 49999
               LEFT JOIN DimProduct PD   ON PD.ProductAlt_Key = B.PRODUCTALT_KEY
               AND PD.EffectiveToTimeKey = 49999
               LEFT JOIN DimAssetClass A2   ON A2.AssetClassAlt_Key = B.FinalAssetClassAlt_Key
               AND A2.EffectiveToTimeKey = 49999
               LEFT JOIN DimAcBuSegment S   ON B.ActSegmentCode = S.AcBuSegmentCode
               AND S.EffectiveToTimeKey = 49999
               LEFT JOIN DimBranch X   ON B.BranchCode = X.BranchCode
               AND X.EffectiveToTimeKey = 49999
               JOIN tt_DPD_17 DPD   ON DPD.AccountEntityID = b.AccountEntityID
               AND dpd.EffectiveFromTimeKey = B.EffectiveFromTimeKey
       WHERE  InitialAssetClassAlt_Key = 1
                AND FinalAssetClassAlt_Key > 1
                AND UTILS.CONVERT_TO_VARCHAR2(SD.Date_,200) BETWEEN v_From1 AND v_to1 ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD_17 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_116 ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_026_08112021" TO "ADF_CDR_RBL_STGDB";
