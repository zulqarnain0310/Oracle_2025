--------------------------------------------------------
--  DDL for Procedure RPT_032_25112021
--------------------------------------------------------
set define off;

  CREATE OR REPLACE EDITIONABLE PROCEDURE "RBL_MISDB_PROD"."RPT_032_25112021" 
(
  v_FromDate IN VARCHAR2,
  v_ToDate IN VARCHAR2,
  v_BranchCode IN VARCHAR2,
  v_CustomerID IN VARCHAR2,
  v_AccountID IN VARCHAR2,
  v_Cost IN FLOAT
)
AS
   --DECLARE  @FromDate  VARCHAR(20) ='10/08/2021'  
   --        ,@ToDate  VARCHAR(20) ='13/08/2021'   
   --        ,@BranchCode AS VARCHAR(MAX)='<ALL>'   
   --		,@CustomerID AS VARCHAR(100)='D2588312' 
   --		,@AccountID  AS VARCHAR(MAX)='2224210080000005'
   --		,@Cost AS FLOAT=1
   -----------------------------------------------------------------------------------------------------
   v_FromDate1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_FromDate))  );
   v_ToDate1 VARCHAR2(200) := ( SELECT Rdate 
     FROM TABLE(DateConvert(v_ToDate))  );
   v_FromTimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM SysDayMatrix 
    WHERE  DATE_ = v_FromDate1 );
   v_ToTimeKey NUMBER(10,0) := ( SELECT TimeKey 
     FROM SysDayMatrix 
    WHERE  DATE_ = v_ToDate1 );
   ---------------------------------------------------------------------------------------------------------
   v_ProcessDate VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  Timekey = v_FromTimeKey );
   v_ProcessDate1 VARCHAR2(200) := ( SELECT DATE_ 
     FROM SysDayMatrix 
    WHERE  Timekey = v_ToTimeKey );
   ------------------------------------------------------------------------
   v_cursor SYS_REFCURSOR;

BEGIN

   ---------------------------======================================From Date DPD CalCULATION  Start===========================================
   IF utils.object_id('tempdb..tt_DPD_24') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD_24 ';
   END IF;
   DELETE FROM tt_DPD_24;
   UTILS.IDENTITY_RESET('tt_DPD_24');

   INSERT INTO tt_DPD_24 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_FromTimeKey
              AND EffectiveToTimeKey >= v_FromTimeKey
              AND RefCustomerID = v_CustomerID );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD_24 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*---------- CALCULATED ALL DPD---------------------------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_ProcessDate)
   ELSE 0
      END) AS pos_2, (CASE 
   WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, v_ProcessDate)
   ELSE 0
      END) AS pos_3, (CASE 
   WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, v_ProcessDate)
   ELSE 0
      END) AS pos_4, (CASE 
   WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_ProcessDate)
   ELSE 0
      END) AS pos_5, (CASE 
   WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, v_ProcessDate)
   ELSE 0
      END) AS pos_6, (CASE 
   WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, v_ProcessDate)
   ELSE 0
      END) AS pos_7
   FROM A ,tt_DPD_24 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_IntService = pos_2,
                                A.DPD_NoCredit = pos_3,
                                A.DPD_Overdrawn = pos_4,
                                A.DPD_Overdue = pos_5,
                                A.DPD_Renewal = pos_6,
                                A.DPD_StockStmt = pos_7;
   /*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_DPD_24
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_DPD_24
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_DPD_24
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_DPD_24
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_DPD_24
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_DPD_24
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD_24 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_NoCredit = 0;
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_123') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_123 ';
   END IF;
   DELETE FROM tt_TEMPTABLE_123;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE_123');

   INSERT INTO tt_TEMPTABLE_123 ( 
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
   	  FROM tt_DPD_24 A
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.RefCustomerID = B.RefCustomerID
             AND B.EffectiveFromTimeKey <= v_FromTimeKey
             AND B.EffectiveToTimeKey >= v_FromTimeKey
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
   FROM A ,tt_DPD_24 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   /*----------------FIND MAX DPD---------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN ( NVL(A.DPD_IntService, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_IntService, 0)
   WHEN ( NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_NoCredit, 0)
   WHEN ( NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Overdrawn, 0)
   WHEN ( NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Renewal, 0)
   WHEN ( NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Overdue, 0)
   ELSE NVL(A.DPD_StockStmt, 0)
      END) AS DPD_Max
   FROM A ,tt_DPD_24 A
          JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON C.RefCustomerID = A.RefCustomerID
          AND C.EffectiveFromTimeKey <= v_FromTimeKey
          AND C.EffectiveToTimeKey >= v_FromTimeKey 
    WHERE ( NVL(C.FlgProcessing, 'N') = 'N' )
     AND ( NVL(A.DPD_IntService, 0) > 0
     OR NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0
     OR NVL(A.DPD_Renewal, 0) > 0
     OR NVL(A.DPD_StockStmt, 0) > 0
     OR NVL(DPD_NoCredit, 0) > 0 )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   ------------------------------------------------=========================END===========================
   ---------------------------======================================To Date DPD CalCULATION  Start===========================================
   IF utils.object_id('tempdb..tt_DPD_241') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD1_5 ';
   END IF;
   DELETE FROM tt_DPD1_5;
   UTILS.IDENTITY_RESET('tt_DPD1_5');

   INSERT INTO tt_DPD1_5 ( 
   	SELECT * 
   	  FROM PRO_RBL_MISDB_PROD.AccountCal_Hist 
   	 WHERE  EffectiveFromTimeKey <= v_ToTimeKey
              AND EffectiveToTimeKey >= v_ToTimeKey
              AND RefCustomerID = v_CustomerID );

   EXECUTE IMMEDIATE ' ALTER TABLE tt_DPD1_5 
      ADD ( [DPD_IntService NUMBER(10,0) , DPD_NoCredit NUMBER(10,0) , DPD_Overdrawn NUMBER(10,0) , DPD_Overdue NUMBER(10,0) , DPD_Renewal NUMBER(10,0) , DPD_StockStmt NUMBER(10,0) , DPD_MAX NUMBER(10,0) ] ) ';
   /*---------- CALCULATED ALL DPD---------------------------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN A.IntNotServicedDt IS NOT NULL THEN utils.datediff('DAY', A.IntNotServicedDt, v_ProcessDate1)
   ELSE 0
      END) AS pos_2, (CASE 
   WHEN A.LastCrDate IS NOT NULL THEN utils.datediff('DAY', A.LastCrDate, v_ProcessDate1)
   ELSE 0
      END) AS pos_3, (CASE 
   WHEN A.ContiExcessDt IS NOT NULL THEN utils.datediff('DAY', A.ContiExcessDt, v_ProcessDate1)
   ELSE 0
      END) AS pos_4, (CASE 
   WHEN A.OverDueSinceDt IS NOT NULL THEN utils.datediff('DAY', A.OverDueSinceDt, v_ProcessDate1)
   ELSE 0
      END) AS pos_5, (CASE 
   WHEN A.ReviewDueDt IS NOT NULL THEN utils.datediff('DAY', A.ReviewDueDt, v_ProcessDate1)
   ELSE 0
      END) AS pos_6, (CASE 
   WHEN A.StockStDt IS NOT NULL THEN utils.datediff('DAY', A.StockStDt, v_ProcessDate1)
   ELSE 0
      END) AS pos_7
   FROM A ,tt_DPD1_5 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_IntService = pos_2,
                                A.DPD_NoCredit = pos_3,
                                A.DPD_Overdrawn = pos_4,
                                A.DPD_Overdue = pos_5,
                                A.DPD_Renewal = pos_6,
                                A.DPD_StockStmt = pos_7;
   /*--------------IF ANY DPD IS NEGATIVE THEN ZERO---------------------------------*/
   UPDATE tt_DPD_24
      SET DPD_IntService = 0
    WHERE  NVL(DPD_IntService, 0) < 0;
   UPDATE tt_DPD1_5
      SET DPD_NoCredit = 0
    WHERE  NVL(DPD_NoCredit, 0) < 0;
   UPDATE tt_DPD1_5
      SET DPD_Overdrawn = 0
    WHERE  NVL(DPD_Overdrawn, 0) < 0;
   UPDATE tt_DPD1_5
      SET DPD_Overdue = 0
    WHERE  NVL(DPD_Overdue, 0) < 0;
   UPDATE tt_DPD1_5
      SET DPD_Renewal = 0
    WHERE  NVL(DPD_Renewal, 0) < 0;
   UPDATE tt_DPD1_5
      SET DPD_StockStmt = 0
    WHERE  NVL(DPD_StockStmt, 0) < 0;
   /*------------DPD IS ZERO FOR ALL ACCOUNT DUE TO LASTCRDATE ------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, 0
   FROM A ,tt_DPD1_5 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_NoCredit = 0;
   /* CALCULATE MAX DPD */
   IF utils.object_id('TEMPDB..tt_TEMPTABLE_1231') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE1_7 ';
   END IF;
   DELETE FROM tt_TEMPTABLE1_7;
   UTILS.IDENTITY_RESET('tt_TEMPTABLE1_7');

   INSERT INTO tt_TEMPTABLE1_7 ( 
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
   	  FROM tt_DPD1_5 A
             JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist B   ON A.RefCustomerID = B.RefCustomerID
             AND B.EffectiveFromTimeKey <= v_ToTimeKey
             AND B.EffectiveToTimeKey >= v_ToTimeKey
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
   FROM A ,tt_DPD1_5 A ) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = 0;
   /*----------------FIND MAX DPD---------------------------------------*/
   MERGE INTO A 
   USING (SELECT A.ROWID row_id, (CASE 
   WHEN ( NVL(A.DPD_IntService, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_IntService, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_IntService, 0)
   WHEN ( NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_NoCredit, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_NoCredit, 0)
   WHEN ( NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdrawn, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Overdrawn, 0)
   WHEN ( NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_Overdue, 0)
     AND NVL(A.DPD_Renewal, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Renewal, 0)
   WHEN ( NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_NoCredit, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_IntService, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Overdrawn, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_Renewal, 0)
     AND NVL(A.DPD_Overdue, 0) >= NVL(A.DPD_StockStmt, 0) ) THEN NVL(A.DPD_Overdue, 0)
   ELSE NVL(A.DPD_StockStmt, 0)
      END) AS DPD_Max
   FROM A ,tt_DPD1_5 A
          JOIN PRO_RBL_MISDB_PROD.CustomerCal_Hist C   ON C.RefCustomerID = A.RefCustomerID
          AND C.EffectiveFromTimeKey <= v_ToTimeKey
          AND C.EffectiveToTimeKey >= v_ToTimeKey 
    WHERE ( NVL(C.FlgProcessing, 'N') = 'N' )
     AND ( NVL(A.DPD_IntService, 0) > 0
     OR NVL(A.DPD_Overdrawn, 0) > 0
     OR NVL(A.DPD_Overdue, 0) > 0
     OR NVL(A.DPD_Renewal, 0) > 0
     OR NVL(A.DPD_StockStmt, 0) > 0
     OR NVL(DPD_NoCredit, 0) > 0 )) src
   ON ( A.ROWID = src.row_id )
   WHEN MATCHED THEN UPDATE SET A.DPD_Max = src.DPD_Max;
   ---------------------------------------------------------------END----------------------------------
   ---------------------------------------------------------------------------------
   IF utils.object_id('TEMPDB..tt_DATA_13') IS NOT NULL THEN
    EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DATA_13 ';
   END IF;
   DELETE FROM tt_DATA_13;
   UTILS.IDENTITY_RESET('tt_DATA_13');

   INSERT INTO tt_DATA_13 ( 
   	SELECT UCIF_ID ,
           RefCustomerID ,
           CustomerAcId ,
           CustomerName ,
           NVL(AcBuSegmentDescription, 'NA') Segment  ,
           NVL(GLCode, 'NA') GLCode  ,
           NVL(ProductCode, 'NA') ProductCode  ,
           NVL(ProductName, 'NA') ProductName  ,
           NPADate ,
           NVL(Restructure, 'NA') Restructure  ,
           NVL(PUI, 'NA') PUI  ,
           NVL(FacilityType, 'NA') FacilityType  ,
           SUM(NVL(DFVAmt, 0))  DFVAmt  ,
           AssetClass ,
           'NA' Asset_Sub_Class  ,
           DPD_Max ,
           SUM(NVL(Balance, 0))  Balance  ,
           SUM(NVL(Unserviedint, 0))  Unserviedint  ,
           SUM(NVL(CashMarginHeldwithBank, 0))  CashMarginHeldwithBank  ,
           SUM(NVL(RealisableValueofSecurity, 0))  RealisableValueofSecurity  ,
           SUM(NVL(RetainbaleportionofECGC_CGTMSE, 0))  RetainbaleportionofECGC_CGTMSE  ,
           SUM(NVL(WriteOffAmount, 0))  WriteOffAmount  ,
           SUM(NVL(Provsecured, 0))  Provsecured  ,
           SUM(NVL(ProvUnsecured, 0))  ProvUnsecured  ,
           SUM(NVL(TotalProvision, 0))  TotalProvision  ,
           SUM(NVL(PropertionateValueOfSec, 0))  PropertionateValueOfSec  ,
           SUM(NVL(UsedValueOfSec, 0))  UsedValueOfSec  ,
           SUM(NVL(AddlProvision, 0))  AddlProvision  ,
           SUM(NVL(ProvDFV, 0))  ProvDFV  ,
           SUM(NVL(RestructureProvision, 0))  RestructureProvision  ,
           Flag ,
           SUM(NVL(SecuredAmt, 0))  SecuredAmt  ,
           SUM(NVL(UnSecuredAmt, 0))  UnSecuredAmt  ,
           SUM(NVL(PrincOutStd, 0))  PrincOutStd  ,
           SUM(NVL(NetBalance, 0))  NetBalance  
   	  FROM ( SELECT Cust.UCIF_ID ,
                    Cust.RefCustomerID ,
                    ACCOUNT.CustomerAcId ,
                    Cust.CustomerName ,
                    DS.AcBuSegmentDescription ,
                    DGL.GLCode ,
                    DP.ProductCode ,
                    DP.ProductName ,
                    UTILS.CONVERT_TO_VARCHAR2(ACCOUNT.FinalNpaDt,20,p_style=>103) NPADate  ,
                    CASE 
                         WHEN NVL(ACCOUNT.FlgRestructure, ' ') = 'Y' THEN 'Yes'
                         WHEN NVL(ACCOUNT.FlgRestructure, 'N') = 'N' THEN 'No'   END Restructure  ,
                    CASE 
                         WHEN NVL(ACCOUNT.PUI, ' ') = 'Y' THEN 'Yes'
                         WHEN NVL(ACCOUNT.PUI, 'N') = 'N' THEN 'No'   END PUI  ,
                    ACCOUNT.FacilityType ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.DFVAmt, 0) / v_Cost,30,2) DFVAmt  ,
                    DA.AssetClassShortName AssetClass  ,
                    DPD_Max ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.Balance, 0) / v_cost,30,2) Balance  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.unserviedint, 0) / v_cost,30,2) Unserviedint  ,
                    UTILS.CONVERT_TO_NUMBER(0,30,2) CashMarginHeldwithBank  ,
                    UTILS.CONVERT_TO_NUMBER(0,30,2) RealisableValueofSecurity  ,
                    UTILS.CONVERT_TO_NUMBER(0,30,2) RetainbaleportionofECGC_CGTMSE  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.WriteOffAmount, 0) / v_cost,30,2) WriteOffAmount  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.Provsecured, 0) / v_cost,30,2) Provsecured  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.ProvUnsecured, 0) / v_cost,30,2) ProvUnsecured  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.TotalProvision, 0) / v_cost,30,2) TotalProvision  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.apprRV, 0) / v_cost,30,2) PropertionateValueOfSec  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.UsedRV, 0) / v_cost,30,2) UsedValueOfSec  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.AddlProvision, 0) / v_cost,30,2) AddlProvision  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.ProvDFV, 0) / v_cost,30,2) ProvDFV  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACRCH.RestructureProvision, 0) / v_Cost,30,2) RestructureProvision  ,
                    'FD' Flag  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(Account.SecuredAmt, 0) / v_cost,30,2) SecuredAmt  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(Account.UnSecuredAmt, 0) / v_cost,30,2) UnSecuredAmt  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(Account.PrincOutStd, 0) / v_cost,30,2) PrincOutStd  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(Account.NetBalance, 0) / v_cost,30,2) NetBalance  
             FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist CUST
                    JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist ACCOUNT   ON ACCOUNT.RefCustomerID = CUST.RefCustomerID
                    AND ACCOUNT.EffectiveFromTimeKey <= v_FromTimeKey
                    AND ACCOUNT.EffectiveToTimeKey >= v_FromTimeKey
                    AND CUST.EffectiveFromTimeKey <= v_FromTimeKey
                    AND CUST.EffectiveToTimeKey >= v_FromTimeKey
                    JOIN tt_DPD_24 DPD   ON ACCOUNT.CustomerAcID = DPD.CustomerAcID
                    AND ACCOUNT.RefCustomerID = DPD.RefCustomerID
                    AND ACCOUNT.BranchCode = DPD.BranchCode
                    LEFT JOIN AdvAcBasicDetail ACBD   ON ACCOUNT.CustomerAcID = ACBD.CustomerAcID
                    AND ACBD.EffectiveFromTimeKey <= v_FromTimeKey
                    AND ACBD.EffectiveToTimeKey >= v_FromTimeKey
                    JOIN DimBranch DB   ON ACCOUNT.BranchCode = DB.BranchCode
                    AND DB.EffectiveFromTimeKey <= v_FromTimeKey
                    AND DB.EffectiveToTimeKey >= v_FromTimeKey
                    JOIN DimProduct DP   ON ACCOUNT.ProductAlt_Key = DP.ProductAlt_Key
                    AND DP.EffectiveFromTimeKey <= v_FromTimeKey
                    AND DP.EffectiveToTimeKey >= v_FromTimeKey
                    LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal_Hist ACRCH   ON ACCOUNT.AccountEntityId = ACRCH.AccountEntityId
                    AND ACRCH.EffectiveFromTimeKey <= v_FromTimeKey
                    AND ACRCH.EffectiveToTimeKey >= v_FromTimeKey
                    JOIN DimAssetClass DA   ON ACCOUNT.FinalAssetClassAlt_Key = DA.AssetClassAlt_Key
                    AND DA.EffectiveFromTimeKey <= v_FromTimeKey
                    AND DA.EffectiveToTimeKey >= v_FromTimeKey
                    LEFT JOIN DimGL DGL   ON ACBD.GLAlt_Key = DGL.GLAlt_Key
                    AND DGL.EffectiveFromTimeKey <= v_FromTimeKey
                    AND DGL.EffectiveToTimeKey >= v_FromTimeKey
                    LEFT JOIN DimAcBuSegment DS   ON ACCOUNT.ActSegmentCode = DS.AcBuSegmentCode
                    AND DS.EffectiveFromTimeKey <= v_FromTimeKey
                    AND DS.EffectiveToTimeKey >= v_FromTimeKey
              WHERE ----ISNULL(DA.AssetClassShortNameEnum,'') <> 'STD' AND
               DB.BranchCode IN ( SELECT * 
                                  FROM TABLE(SPLIT(v_BranchCode, ','))  )

                 AND CUST.RefCustomerID = v_CustomerID
                 AND ACCOUNT.CustomerACID IN ( SELECT * 
                                               FROM TABLE(SPLIT(v_AccountID, ','))  )

             UNION ALL 
             SELECT CUST.UCIF_ID ,
                    CUST.RefCustomerID ,
                    ACCOUNT.CustomerAcId ,
                    CUST.CustomerName ,
                    DS.AcBuSegmentDescription ,
                    DGL.GLCode ,
                    DP.ProductCode ,
                    DP.ProductName ,
                    UTILS.CONVERT_TO_VARCHAR2(ACCOUNT.FinalNpaDt,20,p_style=>103) NPADate  ,
                    CASE 
                         WHEN NVL(ACCOUNT.FlgRestructure, ' ') = 'Y' THEN 'Yes'
                         WHEN NVL(ACCOUNT.FlgRestructure, 'N') = 'N' THEN 'No'   END Restructure  ,
                    CASE 
                         WHEN NVL(ACCOUNT.PUI, ' ') = 'Y' THEN 'Yes'
                         WHEN NVL(ACCOUNT.PUI, 'N') = 'N' THEN 'No'   END PUI  ,
                    ACCOUNT.FacilityType ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.DFVAmt, 0) / v_Cost,30,2) DFVAmt  ,
                    DA.AssetClassShortName AssetClass  ,
                    DPD_Max ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.Balance, 0) / v_cost,30,2) Balance  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.unserviedint, 0) / v_cost,30,2) Unserviedint  ,
                    UTILS.CONVERT_TO_NUMBER(0,30,2) CashMarginHeldwithBank  ,
                    UTILS.CONVERT_TO_NUMBER(0,30,2) RealisableValueofSecurity  ,
                    UTILS.CONVERT_TO_NUMBER(0,30,2) RetainbaleportionofECGC_CGTMSE  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.WriteOffAmount, 0) / v_cost,30,2) WriteOffAmount  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.Provsecured, 0) / v_cost,30,2) Provsecured  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.ProvUnsecured, 0) / v_cost,30,2) ProvUnsecured  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.TotalProvision, 0) / v_cost,30,2) TotalProvision  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.apprRV, 0) / v_cost,30,2) PropertionateValueOfSec  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.UsedRV, 0) / v_cost,30,2) UsedValueOfSec  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.AddlProvision, 0) / v_cost,30,2) AddlProvision  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACCOUNT.ProvDFV, 0) / v_cost,30,2) ProvDFV  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(ACRCH.RestructureProvision, 0) / v_Cost,30,2) RestructureProvision  ,
                    'TD' Flag  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(Account.SecuredAmt, 0) / v_cost,30,2) SecuredAmt  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(Account.UnSecuredAmt, 0) / v_cost,30,2) UnSecuredAmt  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(Account.PrincOutStd, 0) / v_cost,30,2) PrincOutStd  ,
                    UTILS.CONVERT_TO_NUMBER(NVL(Account.NetBalance, 0) / v_cost,30,2) NetBalance  
             FROM PRO_RBL_MISDB_PROD.CustomerCal_Hist CUST
                    JOIN PRO_RBL_MISDB_PROD.AccountCal_Hist ACCOUNT   ON ACCOUNT.RefCustomerID = CUST.RefCustomerID
                    AND ACCOUNT.EffectiveFromTimeKey <= v_ToTimeKey
                    AND ACCOUNT.EffectiveToTimeKey >= v_ToTimeKey
                    AND CUST.EffectiveFromTimeKey <= v_ToTimeKey
                    AND CUST.EffectiveToTimeKey >= v_ToTimeKey
                    JOIN tt_DPD1_5 DPD   ON ACCOUNT.CustomerAcID = DPD.CustomerAcID
                    AND ACCOUNT.RefCustomerID = DPD.RefCustomerID
                    AND ACCOUNT.BranchCode = DPD.BranchCode
                    LEFT JOIN AdvAcBasicDetail ACBD   ON ACCOUNT.CustomerAcID = ACBD.CustomerAcID
                    AND ACBD.EffectiveFromTimeKey <= v_ToTimeKey
                    AND ACBD.EffectiveToTimeKey >= v_ToTimeKey
                    JOIN DimBranch DB   ON ACCOUNT.BranchCode = DB.BranchCode
                    AND DB.EffectiveFromTimeKey <= v_ToTimeKey
                    AND DB.EffectiveToTimeKey >= v_ToTimeKey
                    JOIN DimProduct DP   ON ACCOUNT.ProductAlt_Key = DP.ProductAlt_Key
                    AND DP.EffectiveFromTimeKey <= v_ToTimeKey
                    AND DP.EffectiveToTimeKey >= v_ToTimeKey
                    LEFT JOIN PRO_RBL_MISDB_PROD.AdvAcRestructureCal_Hist ACRCH   ON ACCOUNT.AccountEntityId = ACRCH.AccountEntityId
                    AND ACRCH.EffectiveFromTimeKey <= v_ToTimeKey
                    AND ACRCH.EffectiveToTimeKey >= v_ToTimeKey
                    JOIN DimAssetClass DA   ON ACCOUNT.FinalAssetClassAlt_Key = DA.AssetClassAlt_Key
                    AND DA.EffectiveFromTimeKey <= v_ToTimeKey
                    AND DA.EffectiveToTimeKey >= v_ToTimeKey
                    LEFT JOIN DimGL DGL   ON ACBD.GLAlt_Key = DGL.GLAlt_Key
                    AND DGL.EffectiveFromTimeKey <= v_ToTimeKey
                    AND DGL.EffectiveToTimeKey >= v_ToTimeKey
                    LEFT JOIN DimAcBuSegment DS   ON ACCOUNT.ActSegmentCode = DS.AcBuSegmentCode
                    AND DS.EffectiveFromTimeKey <= v_FromTimeKey
                    AND DS.EffectiveToTimeKey >= v_FromTimeKey
              WHERE ----ISNULL(DA.AssetClassShortNameEnum,'') <> 'STD' AND
               DB.BranchCode IN ( SELECT * 
                                  FROM TABLE(SPLIT(v_BranchCode, ','))  )

                 AND CUST.RefCustomerID = v_CustomerID
                 AND ACCOUNT.CustomerACID IN ( SELECT * 
                                               FROM TABLE(SPLIT(v_AccountID, ','))  )
            ) DATA

   	--WHERE Asset_Sub_Class IS NOT NULL
   	GROUP BY UCIF_ID,RefCustomerID,CustomerAcId,CustomerName,GLCode,ProductCode,ProductName,NPADate,Restructure,PUI,FacilityType
             --Asset_Sub_Class,
             ,AssetClass,DPD_Max,Flag,AcBuSegmentDescription );
   OPEN  v_cursor FOR
      SELECT PivotTable.UCIF_ID,
             MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT D.UCIF_ID ,
                  , 
                   aggregate
             FROM tt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvttt_DATA_13 ( SELECT PivotTable.CustomerACID,
               MAX( DECODE( , , PivotTable.aggregate, NULL) ) "Pivot Column"                                
        FROM ( 
           SELECT CustomerACID ,
                  , 
                   aggregate
             FROM 
            GROUP BY CustomerACID,
       ) PivotTable 
       GROUP BY PivotTable.CustomerACID ) Pvt
            GROUP BY D.UCIF_ID,
       ) PivotTable 
       GROUP BY PivotTable.UCIF_ID ;
      DBMS_SQL.RETURN_RESULT(v_cursor);
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD_24 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DPD1_5 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE_123 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_TEMPTABLE1_7 ';
   EXECUTE IMMEDIATE ' TRUNCATE TABLE tt_DATA_13 ';

EXCEPTION WHEN OTHERS THEN utils.handleerror(SQLCODE,SQLERRM);
END;

/

  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "QPI_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "DWH_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "MAIN_PRO";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "BS_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ACL_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ROLE_LOCAL_RBL_MISDB_PROD_ORACLE";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "PREMOC_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "QPI_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ALERT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "DWH_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "MAIN_PRO";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "D2KMNTR_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "CURDAT_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "BS_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ACL_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ETL_MAIN_RBL_MISDB_PROD";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "DATAUPLOAD_RBL_MISDB_PROD";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ROLE_ALL_DB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "CC_CDR_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "RBL_BI_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "BSG_READ_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "STD_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "RBL_TEMPDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "STG_FIN_RBL_STGDB";
  GRANT EXECUTE ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ADF_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ROLE_ALL_DB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "CC_CDR_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "RBL_BI_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "BSG_READ_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "STD_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ETL_TEMP_RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "RBL_TEMPDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "STG_FIN_RBL_STGDB";
  GRANT DEBUG ON "RBL_MISDB_PROD"."RPT_032_25112021" TO "ADF_CDR_RBL_STGDB";
